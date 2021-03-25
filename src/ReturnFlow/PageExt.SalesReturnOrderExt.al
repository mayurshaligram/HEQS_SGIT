pageextension 50106 "Sales Return Order_Ext" extends "Sales Return Order"
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
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in at Retail Company';
                InventoryCompanyName: Text;
            begin
                InventoryCompanyName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryCompanyName then
                    Error(ErrorMessage, Rec."No.");
            end;
        }
        // modify("P
        // {
        //     trigger OnAfterAction()
        //     var

        //         RetailPurchaseOrder: Record "Purchase Header";
        //         RetailSalesOrder: Record "Sales Header";
        //         RetailSalesOrderPage: Page "Sales Order";
        //         SessionID: Integer;
        //         Temp: Text;

        //         InventorySalesHeader: Record "Sales Header";
        //         OK: Boolean;
        //         SalesTruthMgt: Codeunit "Sales Truth Mgt";
        //         WarehouseLine: Record "Warehouse Shipment Line";
        //         Continue: Boolean;
        //     begin
        //         Continue := false;
        //         If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
        //             InventorySalesHeader.SetRange("External Document No.", Rec."External Document No.");
        //             InventorySalesHeader.FindSet();

        //             RetailSalesOrder.Reset();
        //             RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //             RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
        //             RetailSalesOrder.FindSet();

        //             InventorySalesHeader."External Document No." := '';
        //             InventorySalesHeader.Modify();

        //             RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
        //             RetailSalesOrder.Modify();

        //             SessionID := 50;
        //             StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);

        //         end;
        //     end;
        // }
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

    //////////////////////////////////////////////////////////////////////////////////////

}