pageextension 50102 "Sales Order_Ext" extends "Sales Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                Text1: Label 'Please release the current Sales Order in at "%1"';
            begin
                if SalesTruthMgt.IsICSalesHeader(Rec) then Error(Text1, Rec."Sell-to Customer Name");
            end;

            trigger OnAfterAction()
            var
                ICSalesHeader: Record "Sales Header";

                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                PurchaseHeader: Record "Purchase Header";

                ICRec: Record "Sales Header";
                SLrec: Record "Sales Line";
                ISLrec: Record "Sales Line";
                ISOsrec: Record "Sales Header";
                Whship: Record "Warehouse Request";
                TempText: Text[20];
                hasPO: Boolean;
                InventoryICInboxTransaction: Record "IC Inbox Transaction";
                ICPage: Page "IC Inbox Transactions";
            begin
                if SalesTruthMgt.IsRetailSalesHeader(Rec) then begin
                    PurchaseHeader.Get(Rec."Document Type"::Order, Rec."Automate Purch.Doc No.");
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
                SalesLine: Record "Sales Line";
                WarehouseRequest: Record "Warehouse Request";
                TempInteger: Integer;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
            begin
                Rec.Status := Rec.Status::Open;
                Rec.Modify();
                // Rec.RecreateSalesLines('Sell-to Customer');
                SalesLine.SetRange("Document No.", Rec."No.");
                if SalesLine.FindSet() then
                    repeat
                        SalesLine."Location Code" := 'NSW';
                        SalesLine.Modify();
                    until SalesLine.Next() = 0;
                TempInteger := 37;
                // message('OnBeforeActionCreating');
                // ReleaseSalesDoc.PerformManualRelease(Rec);
                Rec.Status := Rec.Status::Released;
                Rec.Modify();
                if WarehouseRequest.get(WarehouseRequest.Type::Outbound, SalesLine."Location Code", TempInteger, WarehouseRequest."Source Subtype"::"1", Rec."No.") then begin
                    // message('Please take a look how it is the 5763');
                    WarehouseRequest."Source Document" := WarehouseRequest."Source Document"::"Sales Order";
                    WarehouseRequest."Source No." := Rec."No.";
                    WarehouseRequest."Source Subtype" := 1;
                    WarehouseRequest."External Document No." := Rec."External Document No.";
                    WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Customer;
                    WarehouseRequest."Destination No." := Rec."Sell-to Customer No.";
                    WarehouseRequest."Shipping Advice" := WarehouseRequest."Shipping Advice"::Partial;
                    WarehouseRequest."Shipment Date" := Rec."Document Date";
                    WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
                    WarehouseRequest."Source Type" := 37;
                    WarehouseRequest."Location Code" := SalesLine."Location Code";
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Modify();
                end
                else begin
                    WarehouseRequest.Init();
                    WarehouseRequest."Source Document" := WarehouseRequest."Source Document"::"Sales Order";
                    WarehouseRequest."Source No." := Rec."No.";
                    WarehouseRequest."Source Subtype" := 1;
                    WarehouseRequest."External Document No." := Rec."External Document No.";
                    WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Customer;
                    WarehouseRequest."Destination No." := Rec."Sell-to Customer No.";
                    WarehouseRequest."Shipping Advice" := WarehouseRequest."Shipping Advice"::Partial;
                    WarehouseRequest."Shipment Date" := Rec."Document Date";
                    WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
                    WarehouseRequest."Source Type" := 37;
                    WarehouseRequest."Location Code" := SalesLine."Location Code";
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Insert();
                    message('WR insert');
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
