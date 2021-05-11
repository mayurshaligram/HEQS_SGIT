tableextension 50104 "Purchase Line_Ext" extends "Purchase Line"
{
    fields
    {
        field(50100; "BOM Item"; Boolean)
        {
            Editable = false;
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        PayableMgt: Codeunit PayableMgt;

    // trigger OnBeforeModify()
    // var
    //     ParentPurchaseHeader: Record "Purchase Header";
    // begin
    //     ParentPurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
    //     if ParentPurchaseHeader."Sales Order Ref" <> '' then
    //         Error('Please Change the Purchase Order Information in %1', ParentPurchaseHeader."Sales Order Ref");
    // end;

    trigger OnBeforeDelete()
    var
        ParentPurchaseHeader: Record "Purchase Header";
        User: Record User;
    begin
        user.Get(Database.UserSecurityId());
        ParentPurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
        if (ParentPurchaseHeader."Sales Order Ref" <> '') and (User."Full Name" <> 'Pei Xu') then
            Error('Please Change the Purchase Order Information in %1', ParentPurchaseHeader."Sales Order Ref");
    end;

    trigger OnAfterDelete()
    begin
        PayableMgt.PutPayableItem(Rec);
    end;

    trigger OnAfterInsert()
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then
            ExplodeBOM();
        PayableMgt.PutPayableItem(Rec);
    end;

    trigger OnAfterModify()
    var
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        ToPurchaseLine: Record "Purchase Line";
        temp: text[20];
        // BOM related var
        FromBOMComp: Record "BOM Component";
        Plprice: Record "Purchase price";
    begin
        if (rec.CurrentCompany = 'HEQS International Pty Ltd') and (rec.Type = rec.Type::Item) then begin
            // need to check the associated line

            FromBOMComp.Reset();
            FromBOMComp.SetRange("Parent Item No.", "No.");
            if FromBOMComp.FindSet then
                // iterate the set
                repeat
                    // find the associated salesline
                    ToPurchaseLine.Reset();
                    ToPurchaseLine.SetRange("Document Type", rec."Document Type");
                    ToPurchaseLine.SetRange("Document No.", rec."Document No.");
                    ToPurchaseLine.SetRange("No.", FromBOMComp."No.");
                    ToPurchaseLine.SetRange("BOM Item", true);
                    //// message('%1, %2', FromBOMComp.Type, FromBOMComp.Description);
                    if ToPurchaseLine.FindSet then
                        repeat
                            // updata the associated salesline value
                            ToPurchaseLine."Document Type" := rec."Document Type";
                            ToPurchaseLine."Document No." := rec."Document No.";
                            ToPurchaseLine."Location Code" := "Location Code";
                            ToPurchaseLine.Quantity := Quantity * FromBOMComp."Quantity per";
                            ToPurchaseLine.Modify();
                        until ToPurchaseLine.Next() = 0;
                until FromBOMComp.Next() = 0;
        end;
        PayableMgt.PutPayableItem(Rec);
    end;

    procedure ExplodeBOM()
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        //// message('ExplodeBOM!');
        // CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
        ExplodeBOMCompLines(Rec);
        // DocumentTotals.SalesDocTotalsNotUpToDate();
    end;

    local procedure ExplodeBOMCompLines(PurchaseLine: Record "Purchase Line")
    var
        Text003: Label 'There is not enough space to explode the BOM.';
        ToPurchaseLine: Record "Purchase Line";
        PreviousPurchaseLine: Record "Purchase Line";
        InsertLinesBetween: Boolean;
        NextLineNo: Integer;
        LineSpacing: Integer;
        NoOfBOMComp: Integer;
        FromBOMComp: Record "BOM Component";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        Resource: Record Resource;
        ItemTranslation: Record "Item Translation";
        Selection: Integer;
        TransferExtendedText: Codeunit "Transfer Extended Text";
    begin
        ToPurchaseLine.Reset();
        ToPurchaseLine.SetRange("Document Type", "Document Type");
        ToPurchaseLine.SetRange("Document No.", "Document No.");
        ToPurchaseLine := PurchaseLine;
        NextLineNo := "Line No.";
        InsertLinesBetween := false;
        //// message('// message from ExplodeBOMComplines.');
        if ToPurchaseLine.Find('>') then
            if ToPurchaseLine."Attached to Line No." = "Line No." then begin
                ToPurchaseLine.SetRange("Attached to Line No.", "Line No.");
                ToPurchaseLine.FindLast;
                ToPurchaseLine.SetRange("Attached to Line No.");
                NextLineNo := ToPurchaseLine."Line No.";
                InsertLinesBetween := ToPurchaseLine.Find('>');
            end else
                InsertLinesBetween := true;
        if InsertLinesBetween then
            LineSpacing := (ToPurchaseLine."Line No." - NextLineNo) div (1 + NoOfBOMComp)
        else
            LineSpacing := 10000;
        if LineSpacing = 0 then
            Error(Text003);

        FromBOMComp.Reset();
        FromBOMComp.SetRange("Parent Item No.", "No.");
        if FromBOMComp.FindSet then
            repeat
                ToPurchaseLine.Init();
                NextLineNo := NextLineNo + LineSpacing;
                ToPurchaseLine."Line No." := NextLineNo;

                case FromBOMComp.Type of
                    FromBOMComp.Type::" ":
                        ToPurchaseLine.Type := ToPurchaseLine.Type::" ";
                    FromBOMComp.Type::Item:
                        ToPurchaseLine.Type := ToPurchaseLine.Type::Item;
                    FromBOMComp.Type::Resource:
                        ToPurchaseLine.Type := ToPurchaseLine.Type::Resource;
                end;
                if ToPurchaseLine.Type <> ToPurchaseLine.Type::" " then begin
                    FromBOMComp.TestField("No.");
                    ToPurchaseLine.Validate("No.", FromBOMComp."No.");
                    if PurchaseHeader."Location Code" <> "Location Code" then
                        ToPurchaseLine.Validate("Location Code", "Location Code");
                    if FromBOMComp."Variant Code" <> '' then
                        ToPurchaseLine.Validate("Variant Code", FromBOMComp."Variant Code");
                    if ToPurchaseLine.Type = ToPurchaseLine.Type::Item then begin
                        ToPurchaseLine."Drop Shipment" := "Drop Shipment";
                        Item.Get(FromBOMComp."No.");
                        ToPurchaseLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                        ToPurchaseLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, ToPurchaseLine."Unit of Measure Code");
                        ToPurchaseLine.Validate(Quantity,
                          Round(
                            "Quantity (Base)" * FromBOMComp."Quantity per" *
                            UOMMgt.GetQtyPerUnitOfMeasure(
                              Item, ToPurchaseLine."Unit of Measure Code") / ToPurchaseLine."Qty. per Unit of Measure",
                            UOMMgt.QtyRndPrecision));
                    end else
                        if ToPurchaseLine.Type = ToPurchaseLine.Type::Resource then begin
                            Resource.Get(FromBOMComp."No.");
                            ToPurchaseLine.Validate("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                            ToPurchaseLine."Qty. per Unit of Measure" :=
                              UOMMgt.GetResQtyPerUnitOfMeasure(Resource, ToPurchaseLine."Unit of Measure Code");
                            ToPurchaseLine.Validate(Quantity,
                              Round(
                                "Quantity (Base)" * FromBOMComp."Quantity per" *
                                UOMMgt.GetResQtyPerUnitOfMeasure(
                                  Resource, ToPurchaseLine."Unit of Measure Code") / ToPurchaseLine."Qty. per Unit of Measure",
                                UOMMgt.QtyRndPrecision));
                        end else
                            ToPurchaseLine.Validate(Quantity, "Quantity (Base)" * FromBOMComp."Quantity per");

                    // if PurchaseHeader."Shipment Date" <> "Shipment Date" then
                    //     ToPurchaseLine.Validate("Shipment Date", "Shipment Date");
                end;
                if PurchaseHeader."Language Code" = '' then
                    ToPurchaseLine.Description := FromBOMComp.Description
                else
                    if not ItemTranslation.Get(FromBOMComp."No.", FromBOMComp."Variant Code", PurchaseHeader."Language Code") then
                        ToPurchaseLine.Description := FromBOMComp.Description;

                // ToPurchaseLine."BOM Item No." := BOMItemNo;


                ToPurchaseLine.Type := ToPurchaseLine.Type::Item;
                ToPurchaseLine."BOM Item" := true;
                // ToPurchaseLine.Quantity := Quantity;
                ToPurchaseLine."Location Code" := "Location Code";
                ToPurchaseLine.Insert();

                // ToPurchaseLine.Validate("Qty. to Assemble to Order");

                // if (ToPurchaseLine.Type = ToPurchaseLine.Type::Item) and (ToPurchaseLine.Reserve = ToPurchaseLine.Reserve::Always) then
                //     ToPurchaseLine.AutoReserve();

                if Selection = 1 then begin
                    ToPurchaseLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                    ToPurchaseLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                    ToPurchaseLine."Dimension Set ID" := "Dimension Set ID";
                    ToPurchaseLine.Modify();
                end;

                if PreviousPurchaseLine."Document No." <> '' then
                    if TransferExtendedText.PurchCheckIfAnyExtText(PreviousPurchaseLine, false) then
                        TransferExtendedText.InsertPurchExtText(PreviousPurchaseLine);

                PreviousPurchaseLine := ToPurchaseLine;
            until FromBOMComp.Next = 0;

        if TransferExtendedText.PurchCheckIfAnyExtText(ToPurchaseLine, false) then
            TransferExtendedText.InsertPurchExtText(ToPurchaseLine);
    end;
}