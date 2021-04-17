pageextension 50101 "Sales Order List" extends "Sales Order List"
{

    layout
    {
        addafter("External Document No.")
        {

            field("Your Reference"; Rec."Your Reference")
            {
                Caption = 'Your Reference';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Reference';
                Visible = Not IsInventoryCompany;
            }
        }
        addafter("No.")
        {
            field("Retail SalesHeader"; Rec."RetailSalesHeader")
            {
                Caption = 'Original SO';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the Retail Sales header No';
                Visible = IsInventoryCompany;
            }

            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate PurchOrder No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the automated generated purchorder No';
                Visible = Not IsInventoryCompany;
            }
        }
        addafter(Status)
        {
            field(IsDeliveried; FORMAT(Rec.IsDeliveried))
            {
                Caption = 'IsDeliveried/IsPicked';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the Sales Order has been deliveried.';
                Visible = IsInventoryCompany;
            }
        }

    }
    actions
    {
        modify(Post)
        {
            Visible = false;
        }
        modify(PostAndSend)
        {
            Visible = false;
        }
        modify("Post &Batch")
        {
            Visible = false;
        }
        modify("Preview Posting")
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
                Visible = Not IsInventoryCompany;
                Promoted = true;
                PromotedCategory = Category7;
                // PromotedOnly = true;
                // PromotedIsBig = true;
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
                        if VendorInvoiceNo = PostedPurchaseInvoice."Vendor Invoice No." then
                            Error('The Vendor Invoice No. %1 already in Post Invoice %2', VendorInvoiceNo, PostedPurchaseInvoice."No.");

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
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    trigger OnOpenPage();
    var
        SalesHeader: Record "Sales Header";
        SalesPostExt: Codeunit "Sales-Post (Yes/No) Ext";
    begin
        if SalesHeader.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            if SalesHeader.FindSet() then
                repeat
                    if SalesHeader."External Document No." <> '' then begin
                        SalesPostExt.Run(SalesHeader);
                        SalesHeader."External Document No." := '';
                        SalesHeader.Modify();
                    end;
                until SalesHeader.Next() = 0;
        end;

        IsInventoryCompany := false;
        if Rec.CurrentCompany = InventoryCompanyName then begin
            IsInventoryCompany := true;
        end;

        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}