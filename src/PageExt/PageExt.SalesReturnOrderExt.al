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
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
    begin
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
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Return Reason Code" = '' then
                    TempBool := false;
            until SalesLine.Next() = 0;
        exit(TempBool);
    end;

    //////////////////////////////////////////////////////////////////////////////////////

}