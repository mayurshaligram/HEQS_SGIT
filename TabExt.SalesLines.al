tableextension 50104 "Sales line_Ext" extends "Sales Line"
{
    trigger OnAfterInsert();
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];
    begin
        if (rec.CurrentCompany <> 'Test Company') and (rec.Type = rec.Type::Item) then begin
            PLrec.Init();
            PLrec."Document Type" := rec."Document Type";
            temp := rec."Document No.";
            temp[2] := 'P';
            PLrec."Document No." := temp;
            PLrec."Line No." := rec."Line No.";
            PLrec.Type := PLrec.Type::Item;
            PLrec.Insert();
            // ISO line
            ISLrec.ChangeCompany('Test Company');
            ISOrec.ChangeCompany('Test Company');
            ISLrec."Document Type" := rec."Document Type";
            ISLrec."Line No." := rec."Line No.";
            ISOrec.SetCurrentKey("External Document No.");
            ISORec.SetRange("External Document No.", temp);
            if (ISORec.findset) then
                repeat
                    ISLrec."Document No." := ISOrec."No.";
                    ISLrec.Type := ISLrec.Type::Item;
                    Message('%1 %2', ISLrec."Document Type", ISLrec.Type);
                    ISLrec.Insert();
                until (ISORec.next() = 0);
        end;
    end;

    trigger OnAfterModify();
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];
    begin
        if (rec.CurrentCompany <> 'Test Company') and (rec.Type = rec.Type::Item) then begin
            temp := rec."Document No.";
            temp[2] := 'P';
            PLrec.Get(rec."Document Type", temp, rec."Line No.");
            PLrec."No." := rec."No.";
            PLrec.Type := rec.Type;
            PLrec."Description" := rec."Description";
            PLrec.Quantity := rec.Quantity;
            PLrec."Location Code" := rec."Location Code";
            PLrec."Unit of Measure" := rec."Unit of Measure";
            PLrec."Bin Code" := rec."Bin Code";
            PLrec."Unit Price (LCY)" := rec."Unit Price";
            PLrec."Buy-from Vendor No." := 'V00040';
            PLrec."Unit of Measure Code" := 'PCS';
            PLrec.Modify();
            // ISO line
            ISLrec.ChangeCompany('Test Company');
            ISOrec.ChangeCompany('Test Company');
            ISLrec."Document Type" := rec."Document Type";
            ISLrec."Line No." := rec."Line No.";
            ISOrec.SetCurrentKey("External Document No.");
            ISORec.SetRange("External Document No.", temp);
            if (ISORec.findset) then
                repeat
                    ISLrec."Document No." := ISOrec."No.";
                    ISLrec."No." := rec."No.";
                    ISLrec.Type := rec.Type::Item;
                    ISLrec."Description" := rec."Description";
                    ISLrec.Quantity := rec.Quantity;
                    ISLrec."Location Code" := rec."Location Code";
                    ISLrec."Unit of Measure" := rec."Unit of Measure";
                    ISLrec."Bin Code" := rec."Bin Code";
                    ISLrec."Unit of Measure Code" := 'PCS';
                    ISLrec.Modify();
                until (ISORec.next() = 0);

        end;
    end;

    trigger OnAfterDelete();
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];
    begin
        if (rec.CurrentCompany <> 'Test Company') and (rec.Type = rec.Type::Item) then begin
            temp := rec."Document No.";
            temp[2] := 'P';
            PLrec.get(rec."Document Type", temp, rec."Line No.");
            PLrec.Delete();
            // ISO line
            ISLrec.ChangeCompany('Test Company');
            ISOrec.ChangeCompany('Test Company');
            ISOrec.SetCurrentKey("External Document No.");
            ISORec.SetRange("External Document No.", temp);
            if (ISORec.findset) then
                repeat
                    ISLrec.get(rec."Document Type", ISOrec."No.", rec."Line No.");
                    ISLrec.Delete();
                until (ISORec.next() = 0);
        end;
    end;
}

