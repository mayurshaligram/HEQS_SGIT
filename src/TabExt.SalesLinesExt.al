tableextension 50104 "Sales line_Ext" extends "Sales Line"
{
    fields
    {
        field(50100; "BOM Item"; Boolean)
        {
            Caption = 'IsBOM';
            Description = 'Indicate the Line is Sales Item or Inventory BOM';
            Editable = false;
        }
        field(50101; "Package Tracking ID"; Code[20])
        {
            Description = 'Package Tracking ID for this sales line';
            Editable = false;
        }
        field(50102; "Car ID"; Code[20])
        {
            Description = 'Car ID for Delivery';
            Editable = false;
        }
    }

    trigger OnAfterInsert();
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        FromSO: Record "Sales Header";
        ISOrec: Record "Sales Header";
        BOMSL: Record "Sales Line";
        PLprice: Record "Purchase Price";
        SO: Record "Sales Header";
        FromBOMComp: Record "BOM Component";
        temp: text[20];
        Vendor: Record Vendor;
    begin
        onCreatePurch_IC_BOM(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure onCreatePurch_IC_BOM(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnAfterModify();
    var
        FromSO: Record "Sales Header";
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        ToSalesLine: Record "Sales Line";
        temp: text[20];
        // BOM related var
        FromBOMComp: Record "BOM Component";
        Plprice: Record "Purchase price";
        TempSO: Record "Sales Header";
    begin
        if (rec.CurrentCompany = 'HEQS International Pty Ltd') and (rec.Type = rec.Type::Item) then begin
            // need to check the associated line

            FromBOMComp.Reset();
            FromBOMComp.SetRange("Parent Item No.", "No.");
            if FromBOMComp.FindSet then
                // iterate the set
                repeat
                    // find the associated salesline
                    ToSalesLine.Reset();
                    ToSalesLine.SetRange("Document Type", rec."Document Type");
                    ToSalesLine.SetRange("Document No.", rec."Document No.");
                    ToSalesLine.SetRange("No.", FromBOMComp."No.");
                    ToSalesLine.SetRange("BOM Item", true);
                    //// message('%1, %2', FromBOMComp.Type, FromBOMComp.Description);
                    if ToSalesLine.FindSet then
                        repeat
                            // updata the associated salesline value
                            ToSalesLine."Document Type" := rec."Document Type";
                            ToSalesLine."Document No." := rec."Document No.";
                            // ToSalesLine."Location Code" := "Location Code";
                            ToSalesLine.Validate("Location Code", "Location Code");
                            // ToSalesLine.Validate(Quantity,
                            //       Round(
                            //         "Quantity (Base)" * FromBOMComp."Quantity per" *
                            //         UOMMgt.GetResQtyPerUnitOfMeasure(
                            //           Resource, ToSalesLine."Unit of Measure Code") / ToSalesLine."Qty. per Unit of Measure",
                            //         UOMMgt.QtyRndPrecision));
                            ToSalesLine.Quantity := Quantity * FromBOMComp."Quantity per";
                            ToSalesLine.Modify();

                        until ToSalesLine.Next() = 0;
                until FromBOMComp.Next() = 0;
        end;

        if (rec.CurrentCompany <> 'HEQS International Pty Ltd') and (rec.Type = rec.Type::Item) then begin
            // need to check the associated line

            FromBOMComp.Reset();
            FromBOMComp.SetRange("Parent Item No.", "No.");
            if FromBOMComp.FindSet then
                // iterate the set
                repeat
                    // find the associated salesline
                    ToSalesLine.Reset();
                    ToSalesLine.SetRange("Document Type", rec."Document Type");
                    ToSalesLine.SetRange("Document No.", rec."Document No.");
                    ToSalesLine.SetRange("No.", FromBOMComp."No.");
                    ToSalesLine.SetRange("BOM Item", true);
                    //// message('%1, %2', FromBOMComp.Type, FromBOMComp.Description);
                    if ToSalesLine.FindSet then
                        repeat
                            // updata the associated salesline value
                            ToSalesLine."Document Type" := rec."Document Type";
                            ToSalesLine."Document No." := rec."Document No.";
                            ToSalesLine."Location Code" := "Location Code";
                            ToSalesLine.Quantity := Quantity * FromBOMComp."Quantity per";
                            ToSalesLine.Modify();
                            //////// PO update
                            // temp := tosalesline."Document No.";
                            // temp[2] := 'P';
                            FromSO.Get(FromSO."Document Type"::Order, ToSalesLine."Document No.");
                            if PLrec.Get(tosalesline."Document Type", FromSO."Automate Purch.Doc No.", tosalesline."Line No.") then begin
                                Plrec."Location Code" := ToSalesLine."Location Code";
                                PLrec.Quantity := ToSalesLine.Quantity;
                                PLrec."No." := Tosalesline."No.";
                                Plrec.Description := Tosalesline.Description;
                                PLrec.Type := Plrec.Type::Item;
                                Plrec."BOM Item" := true;
                                Plrec."Unit of Measure Code" := ToSalesLine."Unit of Measure Code";
                                Plrec."VAT Bus. Posting Group" := ToSalesLine."VAT Bus. Posting Group";
                                Plrec."VAT Prod. Posting Group" := ToSalesLine."VAT Prod. Posting Group";
                                // Plrec."Gen. Prod. Posting Group" := ToSalesLine."Gen. Prod. Posting Group";
                                PLrec.Modify();
                            end else begin
                                PLrec.init();
                                PLrec."Document Type" := ToSalesLine."Document type";
                                TempSO.Get(ToSalesLine."Document Type", ToSalesLine."Document No.");
                                Plrec."Document No." := TempSO."Automate Purch.Doc No.";
                                PLrec."Line No." := ToSalesLine."Line No.";
                                Plrec."Location Code" := ToSalesLine."Location Code";
                                PLrec.Quantity := ToSalesLine.Quantity;
                                PLrec."No." := Tosalesline."No.";
                                Plrec.Description := Tosalesline.Description;
                                PLrec.type := Plrec.type::Item;
                                Plrec."BOM Item" := true;
                                Plrec."Unit of Measure Code" := ToSalesLine."Unit of Measure Code";
                                Plrec."VAT Bus. Posting Group" := ToSalesLine."VAT Bus. Posting Group";
                                Plrec."VAT Prod. Posting Group" := ToSalesLine."VAT Prod. Posting Group";
                                // Plrec."Gen. Prod. Posting Group" := ToSalesLine."Gen. Prod. Posting Group";
                                PLrec.Insert();
                            end;

                            // ISO line
                            ISLrec.ChangeCompany('HEQS International Pty Ltd');
                            ISOrec.ChangeCompany('HEQS International Pty Ltd');
                            ISLrec."Document Type" := tosalesline."Document Type";
                            ISLrec."Line No." := tosalesline."Line No.";
                            ISOrec.SetCurrentKey("External Document No.");
                            TempSO.Get(Rec."Document Type", Rec."Document No.");
                            ISORec.SetRange("External Document No.", TempSO."Automate Purch.Doc No.");
                            if (ISORec.findset) then
                                repeat
                                    if ISLrec.get(ToSalesLine."Document Type", ISOrec."No.", ToSalesLine."Line No.") then begin
                                        ISLrec."Document No." := ISOrec."No.";
                                        ISLrec."No." := tosalesline."No.";
                                        ISLrec.Type := tosalesline.Type::Item;
                                        ISLrec."Description" := tosalesline."Description";
                                        ISLrec.Quantity := tosalesline.Quantity;
                                        ISLrec."Location Code" := tosalesline."Location Code";
                                        ISLrec."Unit of Measure" := tosalesline."Unit of Measure";
                                        ISLrec."Bin Code" := tosalesline."Bin Code";
                                        ISLrec."Unit of Measure Code" := ToSalesLine."Unit of Measure";
                                        ISLrec."BOM Item" := true;
                                        ISLrec.Modify();
                                    end else begin
                                        ISLrec."Document No." := ISOrec."No.";
                                        ISLrec."No." := tosalesline."No.";
                                        ISLrec.Type := tosalesline.Type::Item;
                                        ISLrec."Description" := tosalesline."Description";
                                        ISLrec.Quantity := tosalesline.Quantity;
                                        ISLrec."Location Code" := tosalesline."Location Code";
                                        ISLrec."Unit of Measure" := tosalesline."Unit of Measure";
                                        ISLrec."Bin Code" := tosalesline."Bin Code";
                                        ISLrec."Unit of Measure Code" := ToSalesLine."Unit of Measure";
                                        ISLrec."BOM Item" := true;
                                        ISLrec.Insert();
                                    end;
                                until (ISORec.next() = 0);
                        // sync vertical data
                        until ToSalesLine.Next = 0;
                until FromBOMComp.Next = 0;
            FromSO.Get(FromSO."Document Type"::Order, Rec."Document No.");
            if FromSO."Automate Purch.Doc No." = '' then
                error('Not Purch.Order Ref Value');
            PLrec.Get(rec."Document Type", FromSO."Automate Purch.Doc No.", Rec."Line No.");
            PLrec."Description" := rec."Description";
            PLrec.Quantity := rec.Quantity;
            PLrec."Location Code" := rec."Location Code";
            PLrec."Unit of Measure" := rec."Unit of Measure";
            PLrec."Bin Code" := rec."Bin Code";
            PLrec."Unit Price (LCY)" := rec."Unit Price";
            Plrec."Unit of Measure Code" := Rec."Unit of Measure Code";
            Plrec."VAT Bus. Posting Group" := REc."VAT Bus. Posting Group";
            Plrec."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
            // Plrec."Gen. Prod. Posting Group" := Rec."Gen. Prod. Posting Group";
            // PLrec."Buy-from Vendor No." := 'FUR ';
            PLrec."BOM Item" := "BOM Item";
            PLprice.Reset();
            PLprice.SetRange("Item No.", "No.");
            if PLrec."BOM Item" = false then begin
                if PLprice.FindSet then
                    repeat
                        // message('%1 Plprice item No', PLprice."Item No.");
                        PLrec."Direct Unit Cost" := PLprice."Direct Unit Cost";
                    until plprice.Next() = 0;
                PLrec.UpdateAmounts();
            end;
            PLrec.Modify();
            // ISO line
            ISLrec.ChangeCompany('HEQS International Pty Ltd');
            ISOrec.ChangeCompany('HEQS International Pty Ltd');
            ISLrec."Document Type" := rec."Document Type";
            ISLrec."Line No." := rec."Line No.";
            ISOrec.SetCurrentKey("External Document No.");
            ISORec.SetRange("External Document No.", FromSO."Automate Purch.Doc No.");
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
                    ISLrec."Unit of Measure Code" := Rec."Unit of Measure Code";
                    ISLrec."BOM Item" := "BOM Item";
                    ISLrec.Modify();
                until (ISORec.next() = 0);

        end;
    end;

    trigger OnAfterDelete();
    var
        FromSO: Record "Sales Header";
        PO: Record "Purchase Header";
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];
        InventoryName: Text;
    begin
        InventoryName := 'HEQS International Pty Ltd';
        if (rec.CurrentCompany <> InventoryName) and (rec.Type = rec.Type::Item) then begin
            FromSO.Get(Rec."Document Type", Rec."Document No.");
            PO.Get(Rec."Document Type", FromSO."Automate Purch.Doc No.");
            PLrec.get(rec."Document Type", PO."NO.", rec."Line No.");
            PLrec.Delete();
            // ISO line
            ISLrec.ChangeCompany('HEQS International Pty Ltd');
            ISOrec.ChangeCompany('HEQS International Pty Ltd');
            ISOrec.SetCurrentKey("External Document No.");
            ISORec.SetRange("External Document No.", PO."No.");
            if (ISORec.findset) then
                repeat
                    ISLrec.get(rec."Document Type", ISOrec."No.", rec."Line No.");
                    ISLrec.Delete();
                until (ISORec.next() = 0);
        end;
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

}

