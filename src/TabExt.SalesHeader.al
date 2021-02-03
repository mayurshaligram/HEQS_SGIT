tableextension 50100 "Sales Header_Ext" extends "Sales Header"
{
    trigger OnInsert();
    var
        POrecord: Record "Purchase Header";
        tempText: Text[20];
    begin
        rec."No." := insstr(rec."No.", '0S', 1);
        tempText := rec."No.";
        tempText[2] := 'P';
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
    end;

    trigger OnAfterModify();
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

    trigger OnAfterDelete();
    var
        tempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
    begin
        if rec.CurrentCompany <> 'Test Company' then begin
            Message('onafterdelete');
            tempText := rec."No.";
            tempText[2] := 'P';
            // Action 1 PO 
            if POrecord.Get(Porecord."Document Type"::Order, tempText) then begin
                POrecord.Delete();
                Message('Your PO has been deleted.');
            end;

            // Action 2 SO
            SORecord.ChangeCompany('Test Company');
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", tempText);
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
        temptext: Text[20];
        pline: Record "Purchase Line";
        pGetFlag: Boolean;
    begin
        sline.SetCurrentKey("Document Type", "Document No.", "Line No.");
        sline.SetRange("Document Type", rec."Document type");
        sline.SetRange("Document No.", rec."No.");
        sline.SetRange("Line No.", 1, 10000);
        if (sline.findset) then
            repeat
                temptext := sline."Document No.";
                temptext[2] := 'P';
                pGetFlag := pline.GET(sline."Document Type", temptext, sline."Line No.");
                pline."Document Type" := sline."Document Type";
                pline."Document No." := temptext;
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

    procedure POupdate(POrecord: Record "Purchase Header");
    begin
        POrecord."Document Type" := POrecord."Document Type"::Order;
        POrecord."Buy-from Vendor No." := 'V00040';
        POrecord."Buy-from Vendor Name" := 'HEQSINTERNATIONAL';
        POrecord."Sell-to Customer No." := 'C00040';
        Porecord."Document Date" := 20180612D;
        POrecord."Location Code" := rec."Location Code";
        porecord.Amount := rec.Amount;
        Porecord."Status" := rec."Status";
        porecord."WorkDescription" := returnBeautifulText();
        POrecord."Ship-to Address" := rec."Ship-to Address";
        POrecord."Ship-to Contact" := rec."Ship-to Contact";
        porecord."Currency Code" := rec."Currency Code";
        porecord."Ship-to Name" := rec."Ship-to Name";
        POrecord."Ship-to Address" := rec."Ship-to Address";
        porecord."Send IC Document" := true;
        POrecord."Posting Date" := rec."Posting Date";
        POrecord."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
        POrecord.Modify();
    end;

    procedure POinsert();
    var
        POrecord: Record "Purchase Header";
    begin
        Porecord.Init;
        POrecord."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
        POrecord."Vendor Invoice No." := 'VA0000013';
        POrecord."Document Type" := POrecord."Document Type"::Order;
        POrecord."No." := rec."No.";
        POrecord."No."[2] := 'P';
        POrecord."Buy-from Vendor No." := 'V00040';
        POrecord."Buy-from Vendor Name" := 'HEQSINTERNATIONAL';
        POrecord."Send IC Document" := true;
        Porecord."Document Date" := 20180612D;
        POrecord."Location Code" := rec."Location Code";
        porecord.Amount := rec.Amount;
        Porecord."Status" := POrecord."Status"::Released;
        porecord."Sell-to Customer No." := rec."Sell-to Customer No.";
        porecord."WorkDescription" := returnBeautifulText();
        POrecord.Insert;
    end;

    procedure SOupdate(SOrecord: Record "Sales Header");
    begin
        SOrecord."Document Type" := sorecord."Document Type"::Order;
        sorecord."Sell-to Customer No." := 'C00040';
        sorecord."Document Date" := 20180612D;
        sorecord."Location Code" := rec."Location Code";
        sorecord.Amount := rec.Amount;
        sorecord."Status" := rec."Status";
        sorecord."Work Description" := rec."Work Description";
        sorecord."Ship-to Address" := rec."Ship-to Address";
        sorecord."Ship-to Contact" := rec."Ship-to Contact";
        sorecord."Currency Code" := rec."Currency Code";
        sorecord."Ship-to Name" := rec."Ship-to Name";
        sorecord."Ship-to Address" := rec."Ship-to Address";
        sorecord."Send IC Document" := true;
        sorecord."Posting Date" := rec."Posting Date";
        sorecord.Modify();
    end;
}