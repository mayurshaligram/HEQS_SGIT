pageextension 50111 SROListExt extends "Sales Return Order List"
{
    layout
    {
        addafter("No.")
        {
            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate PurchOrder No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the automated generated purch return order no';
                Visible = Not IsInventoryCompany;
            }
        }
    }

    actions
    {
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
                            SalesTruthMgt.ReturnAutoPost(SalesHeader);
                        until SalesHeader.Next() = 0;
                end;

            }
        }
        modify(Release)
        {
            Visible = IsPei;
        }
        modify(Post)
        {
            Visible = false;
        }
        modify("Post and &Print")
        {
            Visible = false;
        }
        modify("Post &Batch")
        {
            Visible = false;
        }
        modify("Post and Email")
        {
            Visible = false;
        }
    }

    var
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        IsPei: Boolean;

    trigger OnOpenPage();
    var
        SalesHeader: Record "Sales Header";
        OK: Boolean;
        SessionID: Integer;
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if User."Full Name" = 'Pei Xu' then IsPei := true;
        IsInventoryCompany := false;
        if Rec.CurrentCompany = InventoryCompanyName then
            IsInventoryCompany := true;
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

        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}