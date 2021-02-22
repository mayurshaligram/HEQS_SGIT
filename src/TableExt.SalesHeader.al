tableextension 50100 "Sales Header_Ext" extends "Sales Header"
{
    trigger OnInsert();
    begin
        Rec."No." := InsStr(Rec."No.", '0S', 1);
        if Rec.CurrentCompany <> 'Test Company' then
            CreatePO();
    end;

    trigger OnAfterModify();
    var
        TempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
        ISLrec: Record "Sales Line";
        SLrec: Record "Sales Line";
        Whship: Record "Warehouse Request";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if rec.CurrentCompany <> 'Test Company' then begin
            TempText := rec."No.";
            TempText[2] := 'P';
            // Action 1 PO Update
            if POrecord.Get(Rec."Document Type", TempText) then begin
                UpdatePurchaseHeader(POrecord);
                // message('Your PO has been update.');
            end
            else begin
                POrecord.Init();
                POrecord."Document Type" := rec."Document Type";
                POrecord."No." := TempText;
                Rec.CALCFIELDS("Work Description");
                PORecord."Work Description" := Rec."Work Description";
                POrecord.Insert();
                rec.UpdatePurchaseHeader(POrecord);
            end;

            // Action 2 SO
            SORecord.ChangeCompany('Test Company');
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", TempText);
            if (SORecord.findset) then
                repeat
                    // Whship.ChangeCompany('Test Company');
                    // Whship."Source Document" := Whship."Source Document"::"Sales Order";
                    // Whship."Source No." := SORecord."No.";
                    // Whship."External Document No." := SORecord."External Document No.";
                    // Whship."Destination Type" := Whship."Destination Type"::Customer;
                    // Whship."Destination No." := SORecord."Sell-to Customer No.";
                    // Whship."Shipping Advice" := Whship."Shipping Advice"::Partial;
                    // Whship."Location Code" := 'SMITHFIELD';
                    // Whship."Source Type" := 37;
                    // Whship."Source Subtype" := 1;
                    // Whship.Type := Whship.Type::Outbound;
                    // Whship."Document Status" := Whship."Document Status"::Released;
                    // Whship."Shipment Date" := System.Today();
                    // // message('%1', Whship.CurrentCompany);
                    // Whship.Insert();
                    ICrec.ChangeCompany('Test Company');
                    // ICRec."Sell-to Customer Name"
                    ICRec.get(SORecord."Document type", SORecord."No.");

                    ICrec."Ship-to Name" := rec."Ship-to Name";
                    ICrec."Ship-to Address" := rec."Ship-to Address";
                    ICrec.Ship := rec.ship;
                    ICrec."Work Description" := rec."Work Description";
                    rec.CALCFIELDS("Work Description");
                    ICrec."Work Description" := rec."Work Description";
                    ICrec."Document Date" := DT2DATE(system.CurrentDateTime);
                    ICrec.Status := rec.Status;
                    ICREC.Modify();
                    TempText := rec."No.";
                    TempText[2] := 'P';
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
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                    ISLrec."Bin Code" := SLrec."Bin Code";
                                    ISLrec."Unit of Measure Code" := 'PCS';
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
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
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec.UpdateAmounts();
                                    ISLrec.Insert();
                                end;
                            end;
                        until (SLrec.Next() = 0);
                // if rec.status = rec.Status::Released then
                //     if ICrec.status <> rec.Status then
                //         ReleaseSalesDoc.PerformManualRelease(ICrec);
                until (SORecord.next() = 0);

        end;
    end;

    trigger OnAfterDelete();
    var
        TempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
    begin
        if rec.CurrentCompany <> 'Test Company' then begin
            // message('onafterdelete');
            TempText := rec."No.";
            TempText[2] := 'P';
            // Action 1 PO 
            if POrecord.Get(Porecord."Document Type"::Order, TempText) then begin
                POrecord.Delete();
                // message('Your PO has been deleted.');
            end;

            // Action 2 SO
            SORecord.ChangeCompany('Test Company');
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", TempText);
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany('Test Company');
                    ICRec.get(SORecord."Document type", SORecord."No.");
                    ICREC.Delete();
                until (SORecord.next() = 0);
        end;
    end;

    procedure loadlines();
    var
        sline: Record "Sales Line";
        Temptext: Text[20];
        pline: Record "Purchase Line";
        pGetFlag: Boolean;
    begin
        sline.SetCurrentKey("Document Type", "Document No.", "Line No.");
        sline.SetRange("Document Type", rec."Document type");
        sline.SetRange("Document No.", rec."No.");
        sline.SetRange("Line No.", 1, 10000);
        if (sline.findset) then
            repeat
                Temptext := sline."Document No.";
                Temptext[2] := 'P';
                pGetFlag := pline.GET(sline."Document Type", Temptext, sline."Line No.");
                pline."Document Type" := sline."Document Type";
                pline."Document No." := Temptext;
                pline."Line No." := sline."Line No.";
                pline.Type := sline.Type;
                pline."No." := sline."No.";
                pline."Description" := sline."Description";
                pline.Quantity := sline.Quantity;
                pline."Location Code" := sline."Location Code";
                pline."Unit of Measure" := sline."Unit of Measure";
                pline."Bin Code" := sline."Bin Code";
                pline."Unit Price (LCY)" := sline."Unit Price";
                pline."Buy-from Vendor No." := 'V00040';
                pline."Unit of Measure Code" := 'PCS';
                if not pGetFlag then begin
                    if not ((pline."Document Type" = pline."Document Type"::Quote) and (pline."Document No." = '') and (pline."No." = '0')) then
                        pline.Insert();
                end else
                    pline.Modify();
            until (sline.next() = 0);
    end;

    procedure returnBeautifulText(): Text;
    var
        mytext: Text;
        myInstream: inStream;
    begin
        rec."Work Description".CreateinStream(myInstream);
        myinstream.Read(mytext, 100);
        Exit(mytext);
    end;

    local procedure CreatePO();
    var
        ToPORecord: Record "Purchase Header";
        TempText: Text[20];
    begin
        TempText := Rec."No.";
        TempText[2] := 'P';
        if ToPORecord.Get(ToPORecord."Document Type"::Order, TempText) then begin
            Error('The PO %1 Already Exist.', ToPORecord."No.");
        end
        else begin
            ToPORecord.Init();
            ToPORecord."Document Type" := Rec."Document Type";
            ToPORecord."No." := TempText;
            ToPORecord.Insert();
            Rec.UpdatePurchaseHeader(ToPORecord);
        end;
    end;

    procedure UpdatePurchaseHeader(PurchaseHeader: Record "Purchase Header");
    begin
        // Fix Setting
        PurchaseHeader."Buy-from Vendor No." := 'V00040';
        PurchaseHeader."Buy-from Vendor Name" := 'HEQSINTERNATIONAL';
        // Update Based on SO
        PurchaseHeader."Document Date" := Rec."Document Date";
        PurchaseHeader."Location Code" := Rec."Location Code";
        PurchaseHeader.Amount := Rec.Amount;
        Rec.CALCFIELDS("Work Description");
        PurchaseHeader."Work Description" := Rec."Work Description";
        PurchaseHeader."Ship-to Address" := Rec."Ship-to Address";
        PurchaseHeader."Ship-to Contact" := Rec."Ship-to Contact";
        PurchaseHeader."Currency Code" := Rec."Currency Code";
        PurchaseHeader."Ship-to Name" := Rec."Ship-to Name";
        PurchaseHeader."Ship-to Address" := Rec."Ship-to Address";
        PurchaseHeader."Send IC Document" := true;
        PurchaseHeader."Posting Date" := Rec."Posting Date";
        PurchaseHeader."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
        PurchaseHeader."Status" := Rec."Status";
        PurchaseHeader.Modify();
    end;
}