pageextension 50103 "Sales Order_Ext" extends "Sales Order"
{
    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                POrec: record "Purchase Header";
                SalesOrder: Text;
                tempText: Text;
                ErrorMessage: Label 'Please release the current Sales Order(%1) in Sales Order(%2) at Company(%3)';
                tempBool: Boolean;
            begin
                if rec.CurrentCompany = 'Test Company' then
                    if rec."External Document No." <> '' then begin
                        SalesOrder := rec."External Document No.";
                        SalesOrder[2] := 'S';
                        Error(ErrorMessage, rec."No.", SalesOrder, rec."Sell-to Customer Name");
                    end;
                if rec.CurrentCompany <> 'Test Company' then begin
                    tempText := rec."No.";
                    tempText[2] := 'P';
                    tempBool := POrec.get(rec."Document Type", tempText);
                    if tempBool then
                        Message('PO %1 has been released again.')
                    else begin
                        POrec.Init();
                        POrec."Document Type" := rec."Document Type";
                        POrec."No." := tempText;
                        POrec.Insert();
                        rec.POupdate(POrec);
                    end;
                end;
                // Ac

            end;

            trigger OnAfterAction()
            var
                pageV: Page "Purchase Order";
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                processRec: Record "Purchase Header";
                tempText: Text[20];
                hasPO: Boolean;
                SORecord: Record "Sales Header";
                ICRec: Record "Sales Header";
                SLrec: Record "Sales Line";
                ISLrec: Record "Sales Line";
                ISOsrec: Record "Sales Header";
            begin
                // Send PO
                if rec.CurrentCompany <> 'Test Company' then begin
                    tempText := rec."No.";
                    tempText[2] := 'P';
                    processRec.Get(rec."Document Type"::Order, tempText);
                    processRec."Document Type" := rec."Document Type";
                    processRec."No." := tempText;
                    processRec."Posting Date" := rec."Posting Date";
                    processRec.Validate("Buy-from IC Partner Code", 'HEQSINTERNATIONAL');
                    processRec.status := rec.Status::Released;
                    processRec.Modify();
                    SORecord.ChangeCompany('Test Company');
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", tempText);
                    if not (SORecord.findset) then
                        if ApprovalsMgmt.PrePostApprovalCheckPurch(processRec) then
                            ICInOutboxMgt.SendPurchDoc(processRec, false);
                    SORecord.ChangeCompany('Test Company');
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", tempText);
                    if (SORecord.findset) then
                        repeat
                            ICrec.ChangeCompany('Test Company');
                            // Message('%1, %2',SORecord."Document type", SORecord."No.");
                            ICRec.get(SORecord."Document type", SORecord."No.");
                            // Message('ICREC %1', ICRec."No.");
                            // Message('%1, %2', rec.Status, ICRec.Status);
                            ICRec.Status := rec.Status;
                            Message('ICrec no %1, status %2', ICRec."No.", icrec.Status);
                            ICrec."Work Description" := rec."Work Description";
                            rec.CALCFIELDS("Work Description");
                            ICrec."Work Description" := rec."Work Description";
                            ICRec."Retail Sales Pending" := (rec.Status = rec.Status::Open);
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
                if rec.CurrentCompany = 'Test Company' then
                    if rec."External Document No." <> '' then begin
                        SalesOrder := rec."External Document No.";
                        SalesOrder[2] := 'S';
                        Error(ErrorMessage, rec."No.", SalesOrder, rec."Sell-to Customer Name");
                    end;
            end;
        }
    }

    trigger OnOpenPage();
    var
        Rrec: Record "Sales Header";
        temptext: Text[20];
    begin
        // if rec.CurrentCompany = 'Test Company' then begin
        //     // if rec."External Document No." <> '' then begin
        //     //     temptext := rec."External Document No.";
        //     //     temptext[2] := 'S';
        //     //     Rrec.ChangeCompany('Priceworth Pty Ltd');
        //     //     Rrec.get(rec."Document Type", temptext);
        //     //     rec.Status := Rrec.status;
        //     //     rec."Ship-to Name" := rrec."Ship-to Name";
        //     //     rec."Ship-to Address" := rrec."Ship-to Address";
        //     //     rec.Ship := rrec.ship;
        //     //     rrec.CalcFields("Work Description");
        //     //     rec."Work Description" := rrec."Work Description";
        //     //     rec."Retail Sales Pending" := Rrec."Retail Sales Pending";
        //     //     rec.Modify();
        //     // end;
        // end;
    end;

    trigger OnClosePage();
    var
        tempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
        ISLrec: Record "Sales Line";
        SLrec: Record "Sales Line";
    begin
        if rec.CurrentCompany <> 'Test Company' then begin
            tempText := rec."No.";
            tempText[2] := 'P';
            // Action 1 PO Update
            if POrecord.Get(Porecord."Document Type"::Order, tempText) then begin
                POupdate(POrecord);
                Message('Your PO has been update.');
            end
            else begin
                POrecord.Init();
                POrecord."Document Type" := rec."Document Type";
                POrecord."No." := tempText;
                POrecord.Insert();
                rec.POupdate(POrecord);
            end;

            // Action 2 SO
            SORecord.ChangeCompany('Test Company');
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", tempText);
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany('Test Company');
                    ICRec.get(SORecord."Document type", SORecord."No.");
                    ICrec.Status := rec.status;
                    ICrec."Ship-to Name" := rec."Ship-to Name";
                    ICrec."Ship-to Address" := rec."Ship-to Address";
                    ICrec.Ship := rec.ship;
                    ICrec."Work Description" := rec."Work Description";
                    rec.CALCFIELDS("Work Description");
                    ICrec."Work Description" := rec."Work Description";
                    ICrec."Retail Sales Pending" := rec."Retail Sales Pending";
                    // Message('ICREC %1', icrec."No.");
                    // Message('%1, %2', rec.Status, ICRec.Status);
                    ICRec.Status := rec.Status;
                    // Message('%1,assign %2 ', rec.Status, ICRec.Status);
                    ICREC.Modify();
                    // Message('Modify %1 the no %2', ICRec.Status, ICrec."No.");
                    tempText := rec."No.";
                    tempText[2] := 'P';
                    SLrec.SetCurrentKey("Document No.");
                    SLrec.SetRange("Document No.", rec."No.");
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
                                    Message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
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
                                    Message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec.Insert();
                                end;
                            end;
                        until (SLrec.Next() = 0);
                until (SORecord.next() = 0);
        end;
    end;

    local procedure updataISOFromRSO();
    begin
        Message('updataISOFromRSO');
    end;
}