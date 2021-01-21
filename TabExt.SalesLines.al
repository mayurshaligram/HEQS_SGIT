tableextension 50104 "Sales line_Ext" extends "Sales Line"
{
    trigger OnAfterModify();
    var 
        PLrec: Record "Purchase Line";
        temp: text[20];
    begin
        
        // temp := rec."Document No.";
        // temp[2] := 'P';
        // PLrec.SetCurrentKey("Document Type", "Document No.", "Line No.");
        // PLrec.SetRange("Document Type", rec."Document Type");
        // PLrec.SetRange("Document No.", rec."Document No.");
        // PLrec.SetRange("Line No.", rec."Line No.");
        // if (PLrec.findSet()) then 
        //     repeat
        //         PLrec.Type := rec.Type;
        //         PLrec."Description" := rec."Description";
        //         PLrec.Quantity := rec.Quantity;
        //         PLrec."Location Code" := rec."Location Code";
        //         PLrec."Unit of Measure" := rec."Unit of Measure";
        //         PLrec."Bin Code" := rec."Bin Code";
        //         PLrec."Unit Price (LCY)" := rec."Unit Price";
        //         PLrec."Buy-from Vendor No." := 'V00040';
        //         PLrec."Unit of Measure Code" := 'PCS';
        //         PLrec.Modify();
        //     until (PLrec.Next() = 0)
        // else begin
        //     PLrec.Type := rec.Type;
        //     PLrec."Description" := rec."Description";
        //     PLrec.Quantity := rec.Quantity;
        //     PLrec."Location Code" := rec."Location Code";
        //     PLrec."Unit of Measure" := rec."Unit of Measure";
        //     PLrec."Bin Code" := rec."Bin Code";
        //     PLrec."Unit Price (LCY)" := rec."Unit Price";
        //     PLrec."Buy-from Vendor No." := 'V00040';
        //     PLrec."Unit of Measure Code" := 'PCS';
        //     PLrec.Insert();
        // end;;
    end;
}