pageextension 50106 "Sales Return Order_Ext" extends "Sales Return Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                PurchaseHeader: Record "Purchase Header";
                ErrorMessage: Label 'Please releasethe current Sales Order in at Retail Company';
                SalesOrder: Text;
                TempText: Text;
                InventoryName: Text;
            begin
                InventoryName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryName then
                    if Rec."External Document No." <> '' then begin
                        Error(ErrorMessage, Rec."No.");
                    end;
                if Rec.CurrentCompany <> InventoryName then begin
                    if PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") = False then begin
                        PurchaseHeader.Init();
                        PurchaseHeader."Document Type" := Rec."Document Type";
                        PurchaseHeader."No." := Rec."Automate Purch.Doc No.";
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
                InventoryName: Text;
            begin
                if Rec.CurrentCompany <> InventoryName then begin
                    PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.");
                    Rec.UpdatePurchaseHeader(PurchaseHeader);
                    SORecord.ChangeCompany(InventoryName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if not (SORecord.findset) then
                        // message('should create the SO in the inventory.');
                    if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                    SORecord.ChangeCompany(InventoryName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
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
                            ICRec.Status := Rec.Status;
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
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in at Retail Company';
                InventoryName: Text;
            begin
                InventoryName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryName then
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
        InventoryName: Text;
    begin
        if (Rec.CurrentCompany <> InventoryName) and (Rec."No." <> '') then begin
            // Action 1 PO Update
            if POrecord.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") then begin
                Rec.UpdatePurchaseHeader(POrecord);
                // message('Your PO has been update.');
            end
            else begin
                POrecord.Init();
                POrecord."Document Type" := Rec."Document Type";
                POrecord."No." := Rec."Automate Purch.Doc No.";
                POrecord.Insert();
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
                    // // message('ICREC %1', icrec."No.");
                    // // message('%1, %2', Rec.Status, ICRec.Status);
                    ICRec.Status := Rec.Status;
                    // // message('%1,assign %2 ', Rec.Status, ICRec.Status);
                    ICREC.Modify();
                    // // message('Modify %1 the no %2', ICRec.Status, ICrec."No.");
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
                                    ISLrec."Unit of Measure Code" := ISLrec."Unit of Measure";
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
                                    ISLrec."Unit of Measure Code" := SLrec."Unit of Measure";
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

    //////////////////////////////////////////////////////////////////////////////////////

}