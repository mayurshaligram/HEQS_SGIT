pageextension 50103 "Sales Order_Ext" extends "Sales Order"
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
        addafter("Ship-to Contact")
        {
            field("Ship-to Contact 2"; Rec."Ship-to Contact 2")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contact';
                ToolTip = 'Specifies the name of the contact person at the address that products on the sales document will be shipped to.';
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

        modify("External Document No.")
        {
            Editable = false;
        }
    }

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                Text1: Label 'Please release the current Sales Order in at "%1"';
                Text2: Label 'Please provide the location code for the Sales Line';
                Text3: Label 'Please provide the location code for the Sales Order';
                Text4: Label 'There BOM component Inconsistency for the Sales Line, Please report to administrator.';
                SalesLine: Record "Sales Line";
                MainSalesLine: Record "Sales Line";
                TempLineNo: Integer;
                Item: Record Item;
                BOMComponent: Record "BOM Component";
                BOMSalesLine: Record "Sales Line";
                CorrectMainSalesLine: Record "Sales Line";
                ZoneCode: Record ZoneTable;
            begin
                SalesLine.Reset();
                SalesLine.SetRange("Document No.", Rec."No.");
                SalesLine.SetRange("Document Type", Rec."Document Type");
                SalesLine.SetRange("BOM Item", false);
                if SalesLine.FindSet() then
                    repeat
                        if SalesTruthMgt.IsValideICSalesLine(SalesLine) and (SalesLine."Location Code" = '') then
                            Error(Text2);
                    until Salesline.Next() = 0;
                if Rec."Location Code" = '' then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    if SalesLine.FindSet() then
                        Rec."Location Code" := SalesLine."Location Code";
                    Rec.Modify();
                end;

                // BOM Examination
                if MainSalesLine.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
                    MainsalesLine.SetRange("Document Type", Rec."Document Type");
                    MainSalesLine.SetRange("Document No.", Rec."No.");
                    MainSalesLine.SetRange(Type, MainSalesLine.Type::Item);
                    MainSalesLine.SetRange("BOM Item", false);

                    if MainSalesLine.FindSet() then begin
                        repeat
                            TempLineNo := MainSalesLine."Line No.";
                            Item.Get(MainSalesLine."No.");
                            if Item.Type = Item.Type::Inventory then begin
                                BOMComponent.SetRange("Parent Item No.", Item."No.");
                                if BOMComponent.FindSet() then
                                    repeat
                                        TempLineNo += 10000;
                                        if BOMSalesLine.Get(MainSalesLine."Document Type", MainSalesLine."Document No.", TempLineNo) then
                                            if BOMSalesLine."No." <> BOMComponent."No." then begin
                                                CorrectMainSalesLine := MainSalesLine;
                                                MainSalesLine.Delete(true);
                                                CorrectMainSalesLine.Insert(true);
                                            end;
                                    // if BOMSalesLine.Get(MainSalesLine."Document Type", MainSalesLine."Document No.", TempLineNo) = false then begin
                                    //     CorrectMainSalesLine := MainSalesLine;
                                    //     MainSalesLine.Delete(true);
                                    //     CorrectMainSalesLine.Insert(true);
                                    // end;
                                    until BOMComponent.Next() = 0;
                            end;
                        until MainSalesLine.Next() = 0;
                    end;
                end;

                SalesTruthMgt.RequirFieldTesting(Rec);
                if SalesTruthMgt.IsICSalesHeader(Rec) then Error(Text1, Rec."Sell-to Customer Name");
            end;


            trigger OnAfterAction()
            var
                ICSalesHeader: Record "Sales Header";
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                PurchaseHeader: Record "Purchase Header";
                PurchaseLine: Record "Purchase Line";
                SalesLine: Record "Sales Line";
            begin
                if SalesTruthMgt.IsRetailSalesHeader(Rec) then begin
                    // Keep Purchase Line unit of measure and code same as the sales line

                    PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.");
                    PurchaseLine.SetRange("Document Type", Rec."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if PurchaseLine.FindSet() then
                        repeat
                            SalesLine.Reset();
                            SalesLine.Get(Rec."Document Type", Rec."No.", PurchaseLine."Line No.");
                            if PurchaseLine."Unit of Measure" <> SalesLine."Unit of Measure" then begin
                                PurchaseLine."Unit of Measure" := SalesLine."Unit of Measure";
                                PurchaseLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                                PurchaseLine.Modify();
                            end;
                        until PurchaseLine.Next() = 0;
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
            var
                WhseRequestMgt: Codeunit WhseRequestMgt;
            begin
                WhseRequestMgt.ValidateWhseRequest(Rec);
            end;

            // trigger OnBeforeAction();
            // // var
            // //     WhseShipLine: Record "Warehouse Shipment Line";
            // begin
            //     if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
            //         Message('The message is from the OnBeforeAction');
            //         Rec.Status := Rec.Status::Open;
            //         // WhseShipLine.Reset();
            //         // WhseShipLine.SetRange("Source No.", Rec."No.");
            //         // if WhseShipLine.FindSet() then
            //         //     WhseShipLine.Delete();
            //         Rec.RecreateSalesLinesExt(Rec."Sell-to Customer Name");
            //         Rec.Status := Rec.Status::Released;
            //     end;
            // end;

            trigger OnAfterAction();
            var
                WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
                BOMComponent: Record "BOM Component";
                SalesLine: Record "Sales Line";
            begin
                if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
                    WarehouseShipmentLine.SetRange("Source No.", Rec."No.");
                    if WarehouseShipmentLine.FindSet() then
                        repeat
                            BOMComponent.SetRange("Parent Item No.", WarehouseShipmentLine."Item No.");
                            if BOMComponent.findset() then
                                WarehouseShipmentLine."Pick-up Item" := false
                            else
                                WarehouseShipmentLine."Pick-up Item" := true;
                            WarehouseShipmentLine."Original SO" := Rec.RetailSalesHeader;
                            WarehouseShipmentLine.Modify();

                        until WarehouseShipmentLine.Next() = 0;
                    Rec.Status := Rec.Status::Released;
                    Rec.Modify();
                end;
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
                // Delete Copied BOM line (the original COPY function didn't COPY)
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

                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("BOM Item", false);
                    if SalesLine.FindSet() then
                        repeat
                            if SalesTruthMgt.IsValideICSalesLine(SalesLine) then
                                SalesLine.Modify(true);
                        until SalesLine.Next() = 0;
                end;
            end;
        }
        // modify(Post)
        // {
        //     Visible = false;
        // }
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

                    PostedPurchaseInvoice: Record "Purch. Inv. Header";
                    // Only the Sales Header associated with more then one inventory item sale line could be pass
                    Shipped: Boolean;
                    SalesHeader: Record "Sales Header";
                begin

                    Shipped := false;
                    if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
                        Error(Text1, Rec."Sell-to Customer Name");
                    IsValideIC := false;
                    TempSalesLine.SetRange("Document No.", Rec."No.");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    if TempSalesLine.FindSet() then
                        repeat
                            TempItem.Get(TempSalesLine."No.");
                            if TempItem.Type = TempItem.Type::Inventory then IsValideIC := true;
                            if TempSalesLine."Quantity Shipped" <> 0 then Shipped := true;
                        ////////
                        /// 
                        ///  Test the Sales line  has Quantity to Shpment
                        ///     
                        /// //
                        until TempSalesLine.Next() = 0;

                    if IsValideIC = false then Error('Please Only use the normal Posting');
                    if Shipped = false then Error('This Order has nothing to post');


                    PostedSalesInvoiceHeader.ChangeCompany('HEQS International Pty Ltd');
                    if PostedSalesInvoiceHeader.FindLast() then begin
                        VendorInvoiceNo := PostedSalesInvoiceHeader."No.";

                        TempText := Format(VendorInvoiceNo);
                        TempNum := TempText.Substring(7);
                        Evaluate(TempInteger, TempNum);
                        TempInteger += 1;
                        VendorInvoiceNo := 'INTPSI' + Format(TempInteger);
                    end
                    else
                        VendorInvoiceNo := 'INTPSI100000';

                    PostedPurchaseInvoice.Reset();
                    if PostedPurchaseInvoice.FindLast() then
                        if VendorInvoiceNo = PostedPurchaseInvoice."Vendor Invoice No." then begin
                            VendorInvoiceNo := VendorInvoiceNo + '*';
                        end;


                    PurchaseHeader.Reset();
                    PurchaseHeader.SetRange("Sales Order Ref", Rec."No.");
                    if PurchaseHeader.FindSet() and (VendorInvoiceNo <> '') then begin
                        PurchaseHeader."Due Date" := Rec."Due Date";

                        PurchaseHeader."Gen. Bus. Posting Group" := 'DOMESTIC';
                        PurchaseHeader.Modify();

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

                    SessionId := 51;
                    InventorySalesOrder.Reset();
                    InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
                    InventorySalesOrder.SetRange("Document Type", Rec."Document Type");
                    InventorySalesOrder.SetRange(RetailSalesHeader, Rec."No.");

                    if InventorySalesOrder.FindLast() then
                        StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext Inv",
                                                   'HEQS International Pty Ltd', InventorySalesOrder);

                end;

            }
        }
        addbefore("Create Inventor&y Put-away/Pick")
        {
            action("Quick Fix")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quick Fix';
                Image = PostOrder;
                // Promoted = true;
                // PromotedCategory = Process;
                // Visible = Not IsInventoryCompany;

                trigger OnAction();
                begin
                    SalesTruthMgt.QuickFix(Rec);
                end;
            }
        }
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        IsInventoryCompany: Boolean;

        SalesTruthMgt: Codeunit "Sales Truth Mgt";

        IsPei: Boolean;


    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
        User: Record User;
        TempStatus: Enum "Sales Document Status";
    begin
        IsInventoryCompany := false;
        If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            IsInventoryCompany := true;
        IsICSalesHeader := SalesTruthMgt.IsICSalesHeader(Rec);
        user.Get(Database.UserSecurityId());
        if User."Full Name" = 'Pei Xu' then IsPei := true;
        if IsICSalesHeader then begin
            Currpage.Editable(false);
        end;

        if IsPei then CurrPage.Editable(true);

        if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
            TempStatus := Rec.Status;
            Rec.Status := Rec.Status::Open;
            Rec.Modify();
            SalesTruthMgt.QuickFix(Rec);
            Rec.Status := TempStatus;
            Rec.Modify();
            CurrPage.Update();
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
