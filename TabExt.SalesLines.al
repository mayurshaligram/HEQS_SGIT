tableextension 50104 "Sales line_Ext" extends "Sales Line"
{
    trigger OnAfterInsert();
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        BOMSL: Record "Sales Line";
        temp: text[20];
    begin
        if (rec.CurrentCompany <> 'Test Company') and (rec.Type = rec.Type::Item) then begin
            ExplodeBOM();
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

    var
        DocumentTotals: Codeunit "Document Totals";

    procedure ExplodeBOM()
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        Message('ExplodeBOM!');
        // CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
        ExplodeBOMCompLines(rec);
        // DocumentTotals.SalesDocTotalsNotUpToDate();
    end;



    var
        Text003: Label 'There is not enough space to explode the BOM.';
        ToSalesLine: Record "Sales Line";
        FromBOMComp: Record "BOM Component";
        SalesHeader: Record "Sales Header";
        ItemTranslation: Record "Item Translation";
        Item: Record Item;
        Resource: Record Resource;
        UOMMgt: Codeunit "Unit of Measure Management";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        BOMItemNo: Code[20];
        LineSpacing: Integer;
        NextLineNo: Integer;
        NoOfBOMComp: Integer;
        Selection: Integer;

    local procedure ExplodeBOMCompLines(SalesLine: Record "Sales Line")
    var
        PreviousSalesLine: Record "Sales Line";
        InsertLinesBetween: Boolean;
    begin
        ToSalesLine.Reset();
        ToSalesLine.SetRange("Document Type", "Document Type");
        ToSalesLine.SetRange("Document No.", "Document No.");
        ToSalesLine := SalesLine;
        NextLineNo := "Line No.";
        InsertLinesBetween := false;
        if ToSalesLine.Find('>') then
            if ToSalesLine."Attached to Line No." = "Line No." then begin
                ToSalesLine.SetRange("Attached to Line No.", "Line No.");
                ToSalesLine.FindLast;
                ToSalesLine.SetRange("Attached to Line No.");
                NextLineNo := ToSalesLine."Line No.";
                InsertLinesBetween := ToSalesLine.Find('>');
            end else
                InsertLinesBetween := true;
        if InsertLinesBetween then
            LineSpacing := (ToSalesLine."Line No." - NextLineNo) div (1 + NoOfBOMComp)
        else
            LineSpacing := 10000;
        if LineSpacing = 0 then
            Error(Text003);

        FromBOMComp.Reset();
        FromBOMComp.SetRange("Parent Item No.", "No.");
        FromBOMComp.FindSet;
        repeat
            ToSalesLine.Init();
            NextLineNo := NextLineNo + LineSpacing;
            ToSalesLine."Line No." := NextLineNo;

            case FromBOMComp.Type of
                FromBOMComp.Type::" ":
                    ToSalesLine.Type := ToSalesLine.Type::" ";
                FromBOMComp.Type::Item:
                    ToSalesLine.Type := ToSalesLine.Type::Item;
                FromBOMComp.Type::Resource:
                    ToSalesLine.Type := ToSalesLine.Type::Resource;
            end;
            if ToSalesLine.Type <> ToSalesLine.Type::" " then begin
                FromBOMComp.TestField("No.");
                ToSalesLine.Validate("No.", FromBOMComp."No.");
                if SalesHeader."Location Code" <> "Location Code" then
                    ToSalesLine.Validate("Location Code", "Location Code");
                if FromBOMComp."Variant Code" <> '' then
                    ToSalesLine.Validate("Variant Code", FromBOMComp."Variant Code");
                if ToSalesLine.Type = ToSalesLine.Type::Item then begin
                    ToSalesLine."Drop Shipment" := "Drop Shipment";
                    Item.Get(FromBOMComp."No.");
                    ToSalesLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                    ToSalesLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, ToSalesLine."Unit of Measure Code");
                    ToSalesLine.Validate(Quantity,
                      Round(
                        "Quantity (Base)" * FromBOMComp."Quantity per" *
                        UOMMgt.GetQtyPerUnitOfMeasure(
                          Item, ToSalesLine."Unit of Measure Code") / ToSalesLine."Qty. per Unit of Measure",
                        UOMMgt.QtyRndPrecision));
                end else
                    if ToSalesLine.Type = ToSalesLine.Type::Resource then begin
                        Resource.Get(FromBOMComp."No.");
                        ToSalesLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                        ToSalesLine."Qty. per Unit of Measure" :=
                          UOMMgt.GetResQtyPerUnitOfMeasure(Resource, ToSalesLine."Unit of Measure Code");
                        ToSalesLine.Validate(Quantity,
                          Round(
                            "Quantity (Base)" * FromBOMComp."Quantity per" *
                            UOMMgt.GetResQtyPerUnitOfMeasure(
                              Resource, ToSalesLine."Unit of Measure Code") / ToSalesLine."Qty. per Unit of Measure",
                            UOMMgt.QtyRndPrecision));
                    end else
                        ToSalesLine.Validate(Quantity, "Quantity (Base)" * FromBOMComp."Quantity per");

                if SalesHeader."Shipment Date" <> "Shipment Date" then
                    ToSalesLine.Validate("Shipment Date", "Shipment Date");
            end;
            if SalesHeader."Language Code" = '' then
                ToSalesLine.Description := FromBOMComp.Description
            else
                if not ItemTranslation.Get(FromBOMComp."No.", FromBOMComp."Variant Code", SalesHeader."Language Code") then
                    ToSalesLine.Description := FromBOMComp.Description;

            ToSalesLine."BOM Item No." := BOMItemNo;


            ToSalesLine.Type := ToSalesLine.Type::Item;
            ToSalesLine.Insert();

            ToSalesLine.Validate("Qty. to Assemble to Order");

            if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine.Reserve = ToSalesLine.Reserve::Always) then
                ToSalesLine.AutoReserve();

            if Selection = 1 then begin
                ToSalesLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                ToSalesLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                ToSalesLine."Dimension Set ID" := "Dimension Set ID";
                ToSalesLine.Modify();
            end;

            if PreviousSalesLine."Document No." <> '' then
                if TransferExtendedText.SalesCheckIfAnyExtText(PreviousSalesLine, false) then
                    TransferExtendedText.InsertSalesExtText(PreviousSalesLine);

            PreviousSalesLine := ToSalesLine;
        until FromBOMComp.Next = 0;

        if TransferExtendedText.SalesCheckIfAnyExtText(ToSalesLine, false) then
            TransferExtendedText.InsertSalesExtText(ToSalesLine);
    end;

}

