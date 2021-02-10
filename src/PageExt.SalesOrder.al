pageextension 50103 "Sales Order_Ext" extends "Sales Order"
{
    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                PurchaseHeader: Record "Purchase Header";
                ErrorMessage: Label 'Please releasethe current Sales Order(%1) in Sales Order(%2) at Company(%3)';
                SalesOrder: Text;
                TempText: Text;
            begin
                if Rec.CurrentCompany = 'Test Company' then
                    if Rec."External Document No." <> '' then begin
                        SalesOrder := Rec."External Document No.";
                        SalesOrder[2] := 'S';
                        Error(ErrorMessage, Rec."No.", SalesOrder, Rec."Sell-to Customer Name");
                    end;
                if Rec.CurrentCompany <> 'Test Company' then begin
                    TempText := Rec."No.";
                    TempText[2] := 'P';
                    if PurchaseHeader.Get(Rec."Document Type", TempText) = False then begin
                        PurchaseHeader.Init();
                        PurchaseHeader."Document Type" := Rec."Document Type";
                        PurchaseHeader."No." := TempText;
                        PurchaseHeader.Insert();
                        Rec.UpdatePurchaseHeader(PurchaseHeader);
                        // message('Purchase Order %1 in %2 has created', PurchaseHeader."No.", PurchaseHeader.CurrentCompany);
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
            begin
                if Rec.CurrentCompany <> 'Test Company' then begin
                    TempText := Rec."No.";
                    TempText[2] := 'P';
                    PurchaseHeader.Get(Rec."Document Type"::Order, TempText);
                    Rec.UpdatePurchaseHeader(PurchaseHeader);
                    SORecord.ChangeCompany('Test Company');
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", TempText);
                    if not (SORecord.findset) then
                        // message('should create the SO in the inventory.');
                    if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                    SORecord.ChangeCompany('Test Company');
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", TempText);
                    if (SORecord.findset) then
                        repeat
                            Whship.ChangeCompany('Test Company');
                            Whship.Init();
                            Whship."Source Document" := Whship."Source Document"::"Sales Order";
                            Whship."Source No." := SORecord."No.";
                            Whship."External Document No." := SORecord."External Document No.";
                            Whship."Destination Type" := Whship."Destination Type"::Customer;
                            Whship."Destination No." := SORecord."Sell-to Customer No.";
                            Whship."Shipping Advice" := Whship."Shipping Advice"::Partial;
                            Whship.Insert();
                            ICrec.ChangeCompany('Test Company');
                            // // message('%1, %2',SORecord."Document type", SORecord."No.");
                            ICRec.get(SORecord."Document type", SORecord."No.");
                            // // message('ICREC %1', ICRec."No.");
                            // // message('%1, %2', Rec.Status, ICRec.Status);
                            if Rec.Status = Rec.Status::Released then
                                if ICRec.Status <> Rec.Status then
                                    ReleaseSalesDoc.PerformManualRelease(ICrec);
                            // message('ICrec no %1, status %2', ICRec."No.", icrec.Status);
                            ICrec."Work Description" := Rec."Work Description";
                            Rec.CALCFIELDS("Work Description");
                            ICrec."Work Description" := Rec."Work Description";
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
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in Sales Order(%2) at Company(%3)';
            begin
                if Rec.CurrentCompany = 'Test Company' then
                    if Rec."External Document No." <> '' then begin
                        SalesOrder := Rec."External Document No.";
                        SalesOrder[2] := 'S';
                        Error(ErrorMessage, Rec."No.", SalesOrder, Rec."Sell-to Customer Name");
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
                        SalesLine."Location Code" := 'SMITHFIELD';
                        SalesLine.Modify();
                    until SalesLine.Next() = 0;
                TempInteger := 37;
                // message('OnBeforeActionCreating');
                ReleaseSalesDoc.PerformManualRelease(Rec);
                Rec.Modify();
                if WarehouseRequest.get(WarehouseRequest.Type::Outbound, 'SMITHFIELD', TempInteger, WarehouseRequest."Source Subtype"::"1", Rec."No.") then begin
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
                    WarehouseRequest."Location Code" := 'SMITHFIELD';
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
                    WarehouseRequest."Location Code" := 'SMITHFIELD';
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
        if (Rec.CurrentCompany <> 'Test Company') and (Rec."No." <> '') then begin
            TempText := Rec."No.";
            TempText[2] := 'P';
            // Action 1 PO Update
            if POrecord.Get(Porecord."Document Type"::Order, TempText) then begin
                Rec.UpdatePurchaseHeader(POrecord);
                // message('Your PO has been update.');
            end
            else begin
                POrecord.Init();
                POrecord."Document Type" := Rec."Document Type";
                POrecord."No." := TempText;
                POrecord.Insert();
                Rec.UpdatePurchaseHeader(POrecord);
            end;

            // Action 2 SO
            SORecord.ChangeCompany('Test Company');
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", TempText);
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany('Test Company');
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
                    // // message('ICREC %1', icrec."No.");
                    // // message('%1, %2', Rec.Status, ICRec.Status);
                    ICRec.Status := Rec.Status;
                    // // message('%1,assign %2 ', Rec.Status, ICRec.Status);
                    ICREC.Modify();
                    // // message('Modify %1 the no %2', ICRec.Status, ICrec."No.");
                    TempText := Rec."No.";
                    TempText[2] := 'P';
                    SLrec.SetCurrentKey("Document No.");
                    SLrec.SetRange("Document No.", Rec."No.");
                    ISLrec.ChangeCompany('Test Company');
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
                                    ISLrec."Unit of Measure Code" := 'PCS';
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec."BOM Item" := SLrec."BOM Item";
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    ISLrec.UpdateAmounts();
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
                                    ISLrec."Unit of Measure Code" := 'PCS';
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec."BOM Item" := Slrec."BOM Item";
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    ISLrec.UpdateAmounts();
                                    ISLrec.Insert();
                                end;
                            end;
                        until (SLrec.Next() = 0);
                until (SORecord.next() = 0);
        end;
    end;

    trigger OnAfterGetRecord();
    begin
        if (Rec.CurrentCompany = 'Test Company') and (Rec."External Document No." <> '') then
            Currpage.Editable(false);
    end;
}
