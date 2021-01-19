tableextension 50100 "Sales Header_Ext" extends "Sales Header"
{
    Caption = 'Sales Header_Ext';
    // add one more extra field
    // work description po

//     fields
//     {
//         modify(Relation)
//         {
//             TableRelation = if (Type = const (Resource)) Resource;
//         }
//   }



    trigger OnInsert();
    begin
        rec."No." := insstr(rec."No.", '0S', 1);
    end;
    // will revert back the original function
    // OnAfterModify the content in the Slaes Header Table
    // 1. when the admin first create the record and released trigger will create the order in PO
    // 2. when the admin reopen the record and trigger will update the order
    // the order could only be modified when it status is open!!
    trigger OnAfterModify();
    // goal: the ID of PO is P<basenumber>
    // code data type: Denotes a special type of string that is converted to uppercase and removes any trailing or leading spaces.
    // char: char is the element of text, code, literal, or the string
    // string: literal, code, text
    var
        tempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header"; 
    begin
        loadlines;
        tempText := rec."No.";
        tempText[2] := 'P';
        hasPO := POrecord.Get(Porecord."Document Type"::Order,tempText);
    if not hasPO then 
        begin
         if rec.Status = rec.Status::Released then 
            begin
                // POrecord.LoadFields()
                Porecord.Init;
                POrecord."Vendor Invoice No." := 'VA0000013';
                POrecord."Document Type" := POrecord."Document Type"::Order;
                POrecord."No." := rec."No.";
                POrecord."No."[2] := 'P';
                POrecord."Buy-from Vendor No." := 'V00010';
                POrecord."Buy-from Vendor Name" := 	'ANC Global Logistics';
                Porecord."Document Date" := 20180612D;
                POrecord."Location Code" := rec."Location Code";
                porecord.Amount :=   rec.Amount;
                Porecord."Status" := POrecord."Status"::Released;
                porecord."Sell-to Customer No." := rec."Sell-to Customer No.";
                porecord."WorkDescription" := returnBeautifulText();
                POrecord.Insert;
            end;
        end
    else begin
    // want to change need to set the status to open 
        if rec.Status = rec.Status::Open then begin
            POupdate(POrecord);
            end;
        if rec.Status = rec.Status::Released then begin
            POupdate(POrecord);
            end;
    end;
    end;

    procedure loadlines();
    var
        sline: Record "Sales Line";
        pline: Record "Purchase Line";
    begin
        // "Document Type", "Document No.", "Line No."
        sline."Document No." := rec."No.";
        sline.SetCurrentKey("Document Type", "Document No.", "Line No."); 
        sline.SetRange("Document Type",rec."Document type");  
        sline.SetRange("Document No.",rec."No.");
        sline.SetRange("Line No.", 1, 10000);
        if (sline.findset) then
        repeat
            pline."Document Type" := sline."Document Type";
            pline."Document No." := sline."Document No.";
            pline."Line No." := sline."Line No.";
            pline.Type := sline.Type;
            pline."No." := sline."No.";
            pline."Document No."[2] := 'P';
            pline."Description" := sline."Description";
            pline.Quantity := sline.Quantity;
            pline."Location Code" := sline."Location Code";
            pline."Unit of Measure" := sline."Unit of Measure";
            pline."Bin Code" := sline."Bin Code";
            pline."Unit Price (LCY)" := sline."Unit Price";
            if not pline.GET(sline."Document Type", pline."Document No.", pline."Line No.") then begin
                pline.Insert();
            end else 
                pline.Modify();
        until (sline.next() = 0);
    end;
    procedure returnBeautifulText():Text;
    var
        mytext: Text;
        myInstream: inStream;
    begin
        rec."Work Description".CreateinStream(myInstream);
        myinstream.Read(mytext,100); 
        Exit(mytext); 
    end; 
    // could update the date
    procedure POupdate(POrecord: Record "Purchase Header");
    begin
        // POrecord."Purchase Order Subform" := rec."Sales Order Subform";

        POrecord."Document Type" := POrecord."Document Type"::Order;
        POrecord."Buy-from Vendor No." := 'V00030';
        POrecord."Buy-from Vendor Name" := 	'HEQS International Pty Ltd';
        POrecord."Sell-to Customer No." := 'C00040';
        Porecord."Document Date" := 20180612D;
        POrecord."Location Code" := rec."Location Code";
        porecord.Amount :=   rec.Amount;
        Porecord."Status" := rec."Status";
        porecord."WorkDescription" := returnBeautifulText();
        POrecord."Ship-to Address" := rec."Ship-to Address";
        POrecord."Ship-to Contact" := rec."Ship-to Contact";
        porecord."Currency Code" := rec."Currency Code";
        porecord."Ship-to Name" := rec."Ship-to Name";
        POrecord."Ship-to Address" := rec."Ship-to Address";
        // porecord."Bill-to Address" := rec."Bill-to Address";
        POrecord.Modify();
    end;
}