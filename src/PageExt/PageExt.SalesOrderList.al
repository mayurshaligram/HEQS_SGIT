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
        modify(Release)
        {
            Visible = IsPei;
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
                    Shipped: Boolean;
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SetSelectionFilter(SalesHeader);
                    if SalesHeader.FindSet() then
                        repeat
                            SalesTruthMgt.AutoPost(SalesHeader);
                        until SalesHeader.Next() = 0;
                end;

            }
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        IsPei: Boolean;

    trigger OnOpenPage();
    var
        SalesHeader: Record "Sales Header";
        SalesPostExt: Codeunit "Sales-Post (Yes/No) Ext";
        PurchaseHeader: Record "Purchase Header";

        SessionID: Integer;
        OK: Boolean;
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if User."Full Name" = 'Pei Xu' then IsPei := true;
        if SalesHeader.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            if SalesHeader.FindSet() then
                repeat
                    if SalesHeader."External Document No." <> '' then begin

                        OK := STARTSESSION(SessionId, CODEUNIT::RetailBatchPostShipment);
                        if OK = false then
                            ERROR('The session was not started successfully.');
                        // SalesHeader."External Document No." := '';
                        // SalesHeader.Modify();

                    end;
                until SalesHeader.Next() = 0;
        end;

        IsInventoryCompany := false;
        if Rec.CurrentCompany = InventoryCompanyName then begin
            IsInventoryCompany := true;
        end;

        // Check Empty Auto Purchase Order 
        SalesHeader.Reset();
        if SalesHeader.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            SalesHeader.SetRange("Automate Purch.Doc No.", '');
        if SalesHeader.FindSet() then
            repeat
                PurchaseHeader.Reset();
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                PurchaseHeader.SetRange("Sales Order Ref", SalesHeader."No.");
                if PurchaseHeader.FindSet() then
                    SalesHeader."Automate Purch.Doc No." := PurchaseHeader."No.";
                SalesHeader.Modify();
            until SalesHeader.Next = 0;

        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}