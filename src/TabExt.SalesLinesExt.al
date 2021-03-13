tableextension 50104 "Sales line_Ext" extends "Sales Line"
{
    fields
    {
        field(201; "BOM Item"; Boolean)
        {
            Editable = false;
        }
        field(202; "Package Tracking ID"; Code[20])
        {
        }
        field(203; "Car ID"; Code[20])
        {
        }
    }
    var
        InventoryName: Text;

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
        InventoryName := 'HEQS International Pty Ltd';
        if (rec.CurrentCompany = InventoryName) then
            ExplodeBOM();
        if (rec.CurrentCompany <> InventoryName) and (rec.Type = rec.Type::Item) then begin
            // ExplodeBOM for only current SalesLine 
            ExplodeBOM();
            // PO line
            PLrec.Init();
            PLrec."Document Type" := rec."Document Type";
            FromSO.Get(Rec."Document Type"::Order, Rec."Document No.");
            PLrec."Document No." := FromSO."Automate Purch.Doc No.";
            PLrec."Line No." := rec."Line No.";
            // Message('SalesLine OnAfterInsert %1', Rec."No.");
            PLrec."Unit of Measure Code" := rec."Unit of Measure Code";
            PLrec.Type := PLrec.Type::Item;
            PLprice.Reset();
            PLprice.SetRange("Item No.", "No.");
            if PLprice.FindSet then
                repeat
                    // message('%1 Plprice item No', PLprice."Item No.");
                    PLrec."Direct Unit Cost" := PLprice."Direct Unit Cost";
                until plprice.Next() = 0;

            PLrec."BOM Item" := "BOM Item";
            PLrec."No." := rec."No.";
            PLrec.Type := rec.Type;
            PLrec."Description" := rec."Description";
            PLrec.Quantity := rec.Quantity;
            PLrec."Location Code" := rec."Location Code";
            PLrec."Unit of Measure" := rec."Unit of Measure";
            PLrec."Bin Code" := rec."Bin Code";
            PLrec."Unit Price (LCY)" := rec."Unit Price";
            Vendor."Search Name" := 'HEQS INTERNATIONAL PTY LTD';
            Vendor.FindSet();
            PLrec."Buy-from Vendor No." := Vendor."No.";
            Plrec."Unit of Measure Code" := Rec."Unit of Measure Code";
            Plrec."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
            Plrec."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
            // Plrec.posting
            // Plrec."VAT Bus. Posting Group" := 'DOMESTIC';
            PLrec."BOM Item" := "BOM Item";
            PLprice.Reset();
            PLprice.SetRange("Item No.", "No.");
            PLrec.Insert();
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
                    ISLrec.Type := ISLrec.Type::Item;
                    ISLrec."BOM Item" := "BOM Item";
                    ISLrec.Insert();
                until (ISORec.next() = 0);
        end;
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

    procedure ExplodeBOM()
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        //// message('ExplodeBOM!');
        // CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
        ExplodeBOMCompLines(rec);
        // DocumentTotals.SalesDocTotalsNotUpToDate();
    end;

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
        //// message('// message from ExplodeBOMComplines.');
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
        if FromBOMComp.FindSet then
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
                ToSalesLine."BOM Item" := true;
                // ToSalesLine.Quantity := Quantity;
                ToSalesLine."Location Code" := "Location Code";
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

