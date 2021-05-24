pageextension 50107 "Sales Return Order_Ext" extends "Sales Return Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                Text1: Label 'Please release the current Sales Order in at "%1"';
            begin
                // if SalesTruthMgt.IsICSalesHeader(Rec) then Error(Text1, Rec."Sell-to Customer Name")
            end;

            trigger OnAfterAction()
            var
                ICSalesHeader: Record "Sales Header";
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                PurchaseHeader: Record "Purchase Header";

                HasLineReasonCode: Boolean;
                SalesLine: Record "Sales Line";
            begin
                if SalesTruthMgt.IsRetailSalesHeader(Rec) then begin
                    if Rec."Reason Code" = '' then
                        Error('Please Provide Reason Code for this Return Order.');
                    if ReasonCodeCheck(Rec) = false then
                        Error('Please Provide Reason Code for the item line');
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
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in at Retail Company';
                InventoryCompanyName: Text;
            begin
                InventoryCompanyName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryCompanyName then
                    Error(ErrorMessage, Rec."No.");
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
        modify(Post)
        {
            Visible = isPei;
        }
        modify("Post and &Print")
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
                    SalesTruthMgt.ReturnAutoPost(Rec);
                end;

            }
        }
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

        IsInventoryCompany: Boolean;
        IsPei: Boolean;

    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
        IsPei: Boolean;
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if User."Full Name" = 'Pei Xu' then
            isPei := true;
        IsInventoryCompany := false;
        If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            IsInventoryCompany := true;
        IsICSalesHeader := SalesTruthMgt.IsICSalesHeader(Rec);

        // Temperory Solution
        if IsICSalesHeader then begin
            Currpage.Editable(false);
        end;
    end;

    local procedure ReasonCodeCheck(SalesHeader: Record "Sales Header"): Boolean
    var
        TempBool: Boolean;
        SalesLine: Record "Sales Line";
    begin
        TempBool := true;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Return Reason Code" = '' then
                    TempBool := false;
            until SalesLine.Next() = 0;
        exit(TempBool);
    end;

    //////////////////////////////////////////////////////////////////////////////////////

}