pageextension 50103 "Sales Order_Ext" extends "Sales Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                PurchaseHeader: Record "Purchase Header";
                ErrorMessage: Label 'Please release the current Sales Order(%1) in Sales Order at Retail Company';
                SalesOrder: Text;
                TempText: Text;
                InventoryName: Text;
            begin
                InventoryName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryName then
                    if Rec."External Document No." <> '' then begin
                        Error(ErrorMessage);
                    end;
                if Rec.CurrentCompany <> InventoryName then begin
                    if PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") = False then begin
                        PurchaseHeader.Init();
                        PurchaseHeader."Document Type" := Rec."Document Type";
                        PurchaseHeader."No." := Rec."Automate Purch.Doc No.";
                        PurchaseHeader.Insert();
                        Rec.UpdatePurchaseHeader(PurchaseHeader);
                    end;
                end;
            end;

            trigger OnAfterAction()
            var
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                PurchaseHeader: Record "Purchase Header";
                SORecord: Record "Sales Header";
                ICRec: Record "Sales Header";
                SLrec: Record "Sales Line";
                ISLrec: Record "Sales Line";
                ISOsrec: Record "Sales Header";
                Whship: Record "Warehouse Request";
                TempText: Text[20];
                hasPO: Boolean;
                InventoryName: Text;
                InventoryICInboxTransaction: Record "IC Inbox Transaction";
                ICPage: Page "IC Inbox Transactions";
            begin
                InventoryName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany <> InventoryName then begin
                    PurchaseHeader.Get(Rec."Document Type"::Order, Rec."Automate Purch.Doc No.");
                    Rec.UpdatePurchaseHeader(PurchaseHeader);
                    SORecord.ChangeCompany(InventoryName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if not (SORecord.findset) then
                        if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                    InventoryICInboxTransaction.ChangeCompany(InventoryName);
                    if InventoryICInboxTransaction.FindSet() then
                        repeat
                            InventoryICInboxTransaction."Line Action" := InventoryICInboxTransaction."Line Action"::Accept;
                            InventoryICInboxTransaction.Validate("Line Action", InventoryICInboxTransaction."Line Action"::Accept);
                            InventoryICInboxTransaction.Modify();
                            ICAutomate(InventoryICInboxTransaction);
                        until InventoryICInboxTransaction.Next() = 0;
                    SORecord.ChangeCompany(InventoryName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", PurchaseHeader."No.");
                    if (SORecord.findset) then
                        repeat
                            Whship.ChangeCompany(InventoryName);
                            Whship.Init();
                            Whship."Source Document" := Whship."Source Document"::"Sales Order";
                            Whship."Source No." := SORecord."No.";
                            Whship."External Document No." := SORecord."External Document No.";
                            Whship."Destination Type" := Whship."Destination Type"::Customer;
                            Whship."Destination No." := SORecord."Sell-to Customer No.";
                            Whship."Shipping Advice" := Whship."Shipping Advice"::Partial;
                            Whship.Insert();
                            ICrec.ChangeCompany(InventoryName);
                            ICRec.Get(SORecord."Document type", SORecord."No.");
                            if Rec.Status = Rec.Status::Released then
                                if ICRec.Status <> Rec.Status then
                                    ICRec.Status := Rec.Status;
                            // ReleaseSalesDoc.PerformManualRelease(ICrec);
                            ICrec."Work Description" := Rec."Work Description";
                            Rec.CALCFIELDS("Work Description");
                            ICrec."Work Description" := Rec."Work Description";
                            ICrec.Status := Rec.Status;
                            ICREC.Modify();
                        until (SORecord.next() = 0);
                    // ISL updata
                end;
            end;
        }
        modify(Reopen)
        {
            trigger OnBeforeAction();
            var
                SalesOrder: Text;
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in Sales Order at Retail Company';
                InventoryName: Text;
            begin
                InventoryName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryName then
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
                Rec.RecreateSalesLines('Sell-to Customer');
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
                    // message('WR insert');
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
        // modify()
    }
    var
        InventoryName: Text;

    trigger OnClosePage();
    var
        TempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
        ISLrec: Record "Sales Line";
        SLrec: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        InventoryName := 'HEQS International Pty Ltd';
        if (Rec.CurrentCompany <> InventoryName) and (Rec."No." <> '') then begin
            if POrecord.Get(Porecord."Document Type"::Order, Rec."Automate Purch.Doc No.") then begin
                Rec.UpdatePurchaseHeader(POrecord);
            end;

            // Action 2 SO
            SORecord.ChangeCompany(InventoryName);
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany(InventoryName);
                    ICRec.get(SORecord."Document type", SORecord."No.");
                    if Rec.Status = Rec.Status::Released then
                        if ICrec.status = Rec.Status::Released then
                            ReleaseSalesDoc.PerformManualRelease(ICrec);
                    ICrec."Ship-to Name" := Rec."Ship-to Name";
                    ICrec."Ship-to Address" := Rec."Ship-to Address";
                    ICrec.Ship := Rec.ship;
                    ICrec."Work Description" := Rec."Work Description";
                    Rec.CALCFIELDS("Work Description");
                    ICrec."Work Description" := Rec."Work Description";
                    ICRec.Status := Rec.Status;
                    ICREC.Modify();
                    SLrec.SetCurrentKey("Document No.");
                    SLrec.SetRange("Document No.", Rec."No.");
                    ISLrec.ChangeCompany(InventoryName);
                    if (SLrec.findset) then
                        repeat
                            if SLrec.Type = SLrec.Type::Item then begin
                                if ISLrec.Get(SLrec."Document Type", ICREC."No.", SLrec."Line No.") then begin
                                    // UPdata
                                    ISLrec.Type := SLrec.Type::Item;
                                    ISLrec."No." := SLrec."No.";
                                    ISLrec."Document Type" := SLrec."Document Type";
                                    ISLrec."Document No." := ICREC."No.";
                                    ISLrec.Type := SLrec.Type::Item;
                                    ISLrec."Line No." := SLrec."Line No.";
                                    ISLrec."No." := SLrec."No.";
                                    ISLrec."Description" := SLrec."Description";
                                    ISLrec.Quantity := SLrec.Quantity;
                                    ISLrec."Location Code" := SLrec."Location Code";
                                    ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                    ISLrec."Bin Code" := SLrec."Bin Code";
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec."BOM Item" := SLrec."BOM Item";
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    // ISLrec.UpdateAmounts();
                                    ISLrec.Modify()
                                end
                                else begin
                                    ISLrec.Type := SLrec.Type::Item;
                                    ISLrec."No." := SLrec."No.";
                                    ISLrec."Document Type" := SLrec."Document Type";
                                    ISLrec."Document No." := ICREC."No.";
                                    ISLrec.Type := SLrec.Type::Item;
                                    ISLrec."Line No." := SLrec."Line No.";
                                    ISLrec."No." := SLrec."No.";
                                    ISLrec."Description" := SLrec."Description";
                                    ISLrec.Quantity := SLrec.Quantity;
                                    ISLrec."Location Code" := SLrec."Location Code";
                                    ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                    ISLrec."Bin Code" := SLrec."Bin Code";
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec."BOM Item" := Slrec."BOM Item";
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    // ISLrec.UpdateAmounts();
                                    ISLrec.Insert();
                                end;
                            end;
                        until (SLrec.Next() = 0);
                until (SORecord.next() = 0);
        end;
    end;


    trigger OnAfterGetRecord();
    var
        InventroyName: Text;
    begin
        InventoryName := 'HEQS International Pty Ltd';
        if (Rec.CurrentCompany = InventoryName) and (Rec."External Document No." <> '') then
            Currpage.Editable(false);
    end;

    local procedure ICAutomate(ICInboxTransaction: Record "IC Inbox Transaction");

    begin
        ICInboxTransaction.ChangeCompany('HEQS International Pty Ltd');
        // ICInboxTransaction.TestField("Transaction Source", ICInboxTransaction."Transaction Source"::"Created by Partner");
        // ICInboxTransaction.Validate("Line Action", ICInboxTransaction."Line Action"::Accept);
        // ICInboxTransaction.Modify();

        RunInboxTransactions(ICInboxTransaction);
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
