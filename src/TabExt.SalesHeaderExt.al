tableextension 50100 "Sales Header_Ext" extends "Sales Header"
{
    fields
    {
        field(201; Money; Boolean)
        {
            Caption = 'Whether Delivery Stuff Should Receive Money From Customer.';
            Editable = false;
        }
        field(500; "Automate Purch.Doc No."; Text[20])
        {
            Caption = 'Purch.Order Ref Cust';
            Editable = false;
        }
    }
    var
        InventoryName: Text;

    trigger OnInsert();
    begin
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
        TextList: List of [Text];
    begin
        InventoryName := 'HEQS International Pty Ltd';
        if Rec.CurrentCompany <> InventoryName then begin
            if POrecord.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") then begin
                UpdatePurchaseHeader(POrecord);
            end;

            // Action 2 SO
            SORecord.ChangeCompany(InventoryName);
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany(InventoryName);
                    ICRec.Get(SORecord."Document type", SORecord."No.");
                    ICrec."Ship-to Name" := rec."Ship-to Name";
                    ICrec."Ship-to Address" := rec."Ship-to Address";
                    ICrec.Ship := rec.ship;
                    ICrec."Work Description" := rec."Work Description";
                    rec.CALCFIELDS("Work Description");
                    ICrec."Work Description" := rec."Work Description";
                    ICrec."Document Date" := DT2DATE(system.CurrentDateTime);
                    ICrec.Status := rec.Status;
                    ICREC.Modify();
                    SLrec.SetCurrentKey("Document No.");
                    SLrec.SetRange("Document No.", rec."No.");
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
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                    ISLrec."Bin Code" := SLrec."Bin Code";
                                    ISLrec."Unit of Measure Code" := SLrec."Unit of Measure Code";
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
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
                                    ISLrec."Unit of Measure Code" := SLrec."Unit of Measure";
                                    ISLrec."Unit Price" := SLrec."Unit Price";
                                    // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                    ISLrec.UpdateAmounts();
                                    ISLrec.Insert();
                                end;
                            end;
                        until (SLrec.Next() = 0);
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
        InventoryName := 'HEQS International Pty Ltd';
        if rec.CurrentCompany <> InventoryName then begin
            // Action 1 PO 
            if POrecord.Get(Porecord."Document Type"::Order, Rec."Automate Purch.Doc No.") then begin
                POrecord.Delete();
            end;

            // Action 2 SO
            SORecord.ChangeCompany(InventoryName);
            SORecord.SetCurrentKey("External Document No.");
            SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
            if (SORecord.findset) then
                repeat
                    ICrec.ChangeCompany(InventoryName);
                    ICRec.get(SORecord."Document type", SORecord."No.");
                    ICREC.Delete();
                until (SORecord.next() = 0);
        end;
    end;

    procedure loadlines();
    var
        sline: Record "Sales Line";
        FromSO: Record "Sales Header";
        Temptext: Text[20];
        pline: Record "Purchase Line";
        pGetFlag: Boolean;
        Vendor: Record Vendor;
    begin
        sline.SetCurrentKey("Document Type", "Document No.", "Line No.");
        sline.SetRange("Document Type", rec."Document type");
        sline.SetRange("Document No.", rec."No.");
        sline.SetRange("Line No.", 1, 10000);
        if (sline.findset) then
            repeat
                FromSO.Get(Sline."Document No.");
                pGetFlag := pline.GET(sline."Document Type", FromSO."Automate Purch.Doc No.", sline."Line No.");
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
                Vendor."Search Name" := InventoryName;
                Vendor.FindSet();
                pline."Buy-from Vendor No." := Vendor."No.";
                pline."Pay-to Vendor No." := Vendor."No.";
                pline."Unit of Measure Code" := sline."Unit of Measure Code";
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
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        ToPORecord: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        InventoryName := 'HEQS International Pty Ltd';
        if Rec.CurrentCompany <> InventoryName then begin
            PurchPaySetup.Get('');
            NoSeriesCode := PurchPaySetup."Order Nos.";
            NoSeries.Get(NoSeriesCode);
            NoSeriesLine.SetRange("Series Code", NoSeries.Code);

            if NoSeriesLine.FindSet() = false then
                Error('Please Create No series line');
            begin
                ToPORecord.Init();
                // Message('The purchase Order %1', ToPORecord."No.");
                ToPORecord."Document Type" := Rec."Document Type";
                ToPORecord."No." := NoSeriesMgt.DoGetNextNo(NoSeries.Code, System.Today(), true, true);
                ToPORecord."Sales Order Ref" := Rec."No.";
                InventoryName := 'HEQS INTERNATIONAL PTY LTD';
                Vendor."Search Name" := InventoryName;
                Vendor.FindSet();
                ToPORecord."Buy-from Vendor No." := Vendor."No.";
                ToPORecord."Buy-from Vendor Name" := Vendor.Name;
                ToPORecord.Insert();
                UpdatePurchaseHeader(ToPORecord);
                Rec."Automate Purch.Doc No." := ToPORecord."No.";
            end;
        end
    end;

    procedure UpdatePurchaseHeader(PurchaseHeader: Record "Purchase Header");
    var
        Vendor: Record Vendor;
        InventoryName: Text;
    begin
        InventoryName := 'HEQS INTERNATIONAL PTY LTD';
        Vendor."Search Name" := InventoryName;
        Vendor.FindSet();
        PurchaseHeader."Buy-from Vendor No." := Vendor."No.";
        PurchaseHeader."Buy-from Vendor Name" := Vendor.Name;
        // Update Based on SO
        PurchaseHeader."Pay-to Vendor No." := Vendor."No.";
        PurchaseHeader."Pay-to Name" := Vendor.Name;
        PurchaseHeader."VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
        PurchaseHeader."Order Date" := System.Today();

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