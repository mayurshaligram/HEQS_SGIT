pageextension 50102 "Sales Order_Ext" extends "Sales Order"
{
    layout
    {
        addlast("Shipping and Billing")
        {
            field(Delivery; Rec.Delivery)
            {
                ApplicationArea = Basic, Suite;

                ShowMandatory = true;
                Caption = 'Delivery';
                ToolTip = 'Specifies the Delivery Option';
                Importance = Promoted;
            }
            field(IsScheduled; Rec.IsScheduled)
            {
                ApplicationArea = Basic, Suite;

                Caption = 'IsScheduled';
                ToolTip = 'Specifies the Delivery Option';
                Importance = Promoted;
                Editable = false;
            }
            field(IsDeliveried; Rec.IsDeliveried)
            {
                ApplicationArea = Basic, Suite;

                Caption = 'IsDeliveried';
                ToolTip = 'Specifies whether the sales order has been deliveried';
                Importance = Promoted;
                Editable = false;
            }
            field("Delivery Hour"; Rec."Delivery Hour")
            {
                ApplicationArea = Basic, Suite;

                Caption = 'Delivery Hour';
                ToolTip = 'Specifies the Delivery Hour';
                Importance = Promoted;
                Editable = false;
            }
            field("Ship-to Phone No."; Rec."Ship-to Phone No.")
            {
                ApplicationArea = Basic, Suite;

                Caption = 'Ship-to Phone No.';
                ToolTip = 'Specifies the Phone No.';
                Importance = Promoted;
                Editable = true;
            }


        }

        modify("Promised Delivery Date")
        {
            Editable = false;

            trigger OnBeforeValidate();
            begin
                if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then
                    Error('View Only Please Change the Attribute, at %1 Scheduling Section', SalesTruthMgt.InventoryCompany());
            end;
        }


    }

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                Text1: Label 'Please release the current Sales Order in at "%1"';
            begin
                SalesTruthMgt.RequirFieldTesting(Rec);
                if SalesTruthMgt.IsICSalesHeader(Rec) then Error(Text1, Rec."Sell-to Customer Name");
            end;

            trigger OnAfterAction()
            var
                ICSalesHeader: Record "Sales Header";
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                PurchaseHeader: Record "Purchase Header";
            begin
                if SalesTruthMgt.IsRetailSalesHeader(Rec) then begin
                    PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.");
                    ICSalesHeader.ChangeCompany(InventoryCompanyName);
                    ICSalesHeader.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if ICSalesHeader.Findset() = false then
                        if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                end;
            end;
        }
        modify(Reopen)
        {
            trigger OnBeforeAction();
            var
                SalesOrder: Text;
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in Sales Order at Retail Company';
            begin
                if Rec.CurrentCompany = InventoryCompanyName then
                    if Rec."External Document No." <> '' then begin
                        Error(ErrorMessage, Rec."No.");
                    end;
            end;

            trigger OnAfterAction();
            var
                AssociatedPurchaseHeader: Record "Purchase Header";
                IntercompanySalesHeader: Record "Sales Header";
            begin
                IntercompanySalesHeader.ChangeCompany('HEQS International Pty Ltd');
                IntercompanySalesHeader.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                if IntercompanySalesHeader.FindSet() then begin
                    IntercompanySalesHeader.Status := IntercompanySalesHeader.Status::Open;
                end;
            end;
        }
        modify("Create &Warehouse Shipment")
        {
            trigger OnBeforeAction();
            // var
            //     WhseShipLine: Record "Warehouse Shipment Line";
            begin
                if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
                    Message('The message is from the OnBeforeAction');
                    Rec.Status := Rec.Status::Open;
                    // WhseShipLine.Reset();
                    // WhseShipLine.SetRange("Source No.", Rec."No.");
                    // if WhseShipLine.FindSet() then
                    //     WhseShipLine.Delete();
                    Rec.RecreateSalesLinesExt(Rec."Sell-to Customer Name");
                    Rec.Status := Rec.Status::Released;
                end;
            end;

            trigger OnAfterAction();
            var
                WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
                BOMComponent: Record "BOM Component";
                SalesLine: Record "Sales Line";
            begin
                WarehouseShipmentLine.SetRange("Source No.", Rec."No.");
                if WarehouseShipmentLine.FindSet() then
                    repeat
                        BOMComponent.SetRange("Parent Item No.", WarehouseShipmentLine."Item No.");
                        if BOMComponent.findset() then
                            WarehouseShipmentLine."Pick-up Item" := false
                        else
                            WarehouseShipmentLine."Pick-up Item" := true;
                        WarehouseShipmentLine.Modify();
                    until WarehouseShipmentLine.Next() = 0;
                Rec.Status := Rec.Status::Released;
                Rec.Modify();
            end;
        }
        modify(CopyDocument)
        {
            trigger OnAfterAction();
            var
                Item: Record Item;
                SalesLine: Record "Sales Line";
                BOMSalesLine: Record "Sales Line";
                BOMComponent: Record "BOM Component";
                TempLineNo: Integer;
            begin
                if SalesLine.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("BOM Item", false);

                    if SalesLine.FindSet() then begin
                        repeat
                            TempLineNo := SalesLine."Line No.";
                            Item.Get(SalesLine."No.");
                            if Item.Type = Item.Type::Inventory then begin
                                BOMComponent.SetRange("Parent Item No.", Item."No.");
                                if BOMComponent.FindSet() then
                                    repeat
                                        TempLineNo += 10000;
                                        BOMSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo);
                                        BOMSalesLine."BOM Item" := true;
                                        BOMSalesLine."Main Item Line" := SalesLine."Line No.";
                                        BOMSalesLine.Modify();
                                    until BOMComponent.Next() = 0;
                            end;
                        until SalesLine.Next() = 0;
                    end;
                end;
            end;
        }
        modify(Post)
        {
            Visible = false;
        }
        modify(PostAndSend)
        {
            Visible = false;
        }
        modify(PostAndNew)
        {
            Visible = false;
        }
        modify(PreviewPosting)
        {
            Visible = Not IsInventoryCompany;
        }
        addbefore(Post)
        {
            action("Auto Post Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Auto Post Invoice';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Category6;
                // PromotedOnly = true;
                // PromotedIsBig = true;
                Visible = Not IsInventoryCompany;
                trigger OnAction();
                var
                    SalesLine: Record "Sales Line";
                    WarehouseRequest: Record "Warehouse Request";
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    InventorySalesOrder: Record "Sales Header";
                    SessionId: Integer;
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseLine: Record "Purchase Line";
                    PostedSalesInvoiceHeader: Record "Sales Invoice Header";
                    NoSeries: Record "No. Series";
                    NoSeriesMgt: Codeunit NoSeriesManagement;
                    RetailSalesLine: Record "Sales Line";
                    VendorInvoiceNo: Code[20];
                    TempText: Text[20];
                    TempNum: Text[20];
                    TempInteger: Integer;
                    TempSalesLine: Record "Sales Line";
                    TempItem: Record Item;
                    IsValideIC: Boolean;
                    Text1: Label 'Please only post invoice in the retail company %1';
                // Only the Sales Header associated with more then one inventory item sale line could be pass
                begin
                    if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
                        Error(Text1, Rec."Sell-to Customer Name");
                    IsValideIC := false;
                    TempSalesLine.SetRange("Document No.", Rec."No.");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    if TempSalesLine.FindSet() then
                        repeat
                            TempItem.Get(TempSalesLine."No.");
                            if TempItem.Type = TempItem.Type::Inventory then IsValideIC := true;
                        until TempSalesLine.Next() = 0;

                    if IsValideIC = false then Error('Please Only use the normal Posting');
                    SessionId := 51;

                    InventorySalesOrder.Reset();
                    InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
                    InventorySalesOrder.SetRange("Document Type", Rec."Document Type");
                    InventorySalesOrder.SetRange(RetailSalesHeader, Rec."No.");
                    if InventorySalesOrder.FindLast() then
                        StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext Inv",
                                                   'HEQS International Pty Ltd', InventorySalesOrder);

                    InventorySalesOrder.Reset();
                    PostedSalesInvoiceHeader.ChangeCompany('HEQS International Pty Ltd');
                    PostedSalesInvoiceHeader.FindLast();

                    VendorInvoiceNo := PostedSalesInvoiceHeader."No.";
                    TempText := Format(VendorInvoiceNo);
                    TempNum := TempText.Substring(7);
                    Evaluate(TempInteger, TempNum);
                    TempInteger += 1;
                    VendorInvoiceNo := 'INTPSI' + Format(TempInteger);
                    // InventorySalesOrder.SetRange("External Document No.", PurchaseHeader."No.");
                    PurchaseHeader.Reset();
                    PurchaseHeader.SetRange("Sales Order Ref", Rec."No.");
                    if PurchaseHeader.FindSet() and (VendorInvoiceNo <> '') then begin
                        PurchaseHeader."Due Date" := Rec."Due Date";

                        // PurchaseHeader."Vendor Invoice No." := InventorySalesOrder."No.";
                        PurchaseHeader."Gen. Bus. Posting Group" := 'DOMESTIC';
                        PurchaseHeader.Modify();

                        // RetailSalesLine.SetRange("Document No.", Rec."No.");
                        // if RetailSalesLine.FindSet() then
                        //     repeat
                        //         RetailSalesLine."Quantity Shipped" := RetailSalesLine."Qty. to Ship";
                        //         RetailSalesLine."Qty. to Ship" := 0;
                        //         RetailSalesLine.Modify();
                        //     until RetailSalesLine.Next() = 0;

                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        if PurchaseLine.FindSet() then
                            repeat
                                PurchaseLine."Gen. Bus. Posting Group" := 'DOMESTIC';
                                PurchaseLine.Modify();
                            until PurchaseLine.Next() = 0;

                        NoSeries.ChangeCompany(SalesTruthMgt.InventoryCompany());
                        NoSeries.Get('S-INV+');
                        PurchaseHeader."Vendor Invoice No." := VendorInvoiceNo;
                        PurchaseHeader.Modify();
                        Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", PurchaseHeader);
                    end;


                    Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext Inv", Rec);
                    // Post Purchase Order Invoice
                    // Post Intercompany Sales Order Invoice


                end;

            }
        }
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        IsInventoryCompany: Boolean;

        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
    begin
        IsInventoryCompany := false;
        If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            IsInventoryCompany := true;
        IsICSalesHeader := SalesTruthMgt.IsICSalesHeader(Rec);

        if IsICSalesHeader then begin
            Currpage.Editable(false);
        end;


    end;

    procedure RunInboxTransactions(var ICInboxTransaction: Record "IC Inbox Transaction")
    var
        ICInboxTransactionCopy: Record "IC Inbox Transaction";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        RunReport: Boolean;
    begin
        ICInboxTransaction.ChangeCompany('HEQS International Pty Ltd');
        ICInboxTransactionCopy.ChangeCompany('HEQS International Pty Ltd');

        ICInboxTransactionCopy.Copy(ICInboxTransaction);
        ICInboxTransactionCopy.SetRange("Source Type", ICInboxTransactionCopy."Source Type"::Journal);

        // if not ICInboxTransactionCopy.IsEmpty then
        //     RunReport := true;
        Commit();
        // REPORT.RunModal(REPORT::"Complete IC Inbox Action", RunReport, false, ICInboxTransaction);
    end;
}