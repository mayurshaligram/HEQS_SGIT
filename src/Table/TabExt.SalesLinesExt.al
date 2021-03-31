tableextension 50103 "Sales line_Ext" extends "Sales Line"
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
        field(50103; NeedAssemble; Boolean)
        {
            Description = 'The Line Need Assemble.';
            Editable = true;
        }
        field(50104; AssemblyHour; Decimal)
        {
            Description = 'Assembly Hour';
            Editable = true;
        }
        field(50105; UnitAssembleHour; Decimal)
        {
            Description = 'The Assemble hour for just one item';
            Editable = true;
        }
        field(50106; "Main Item Line"; Integer)
        {
            Description = 'Main Item Line';
            Editable = false;
        }
    }

    trigger OnAfterInsert();
    var
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;
        end;

        if (Rec.CurrentCompany <> 'HEQS International Pty Ltd') and IsItemLine then begin
            onInsertPurchICBOM(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure onInsertPurchICBOM(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnBeforeModify();
    begin
        if Rec.Type = Rec.Type::Item then
            if Rec."BOM Item" = true then
                Error('Please Only Edit Main Item, Bom is managed by system only');
    end;

    trigger OnAfterModify();
    var
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;
        end;

        if (Rec."Promised Delivery Date" <> xRec."Promised Delivery Date") then IsItemLine := true;

        if (Rec.CurrentCompany <> 'HEQS International Pty Ltd') and IsItemLine then begin
            OnUpdatePurchICBOM(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdatePurchICBOM(var SalesLine: Record "Sales Line");
    begin
    end;


    // Could be refactorize to CodeUnit
    [IntegrationEvent(false, false)]
    local procedure OnDeleteBOMPurchIC(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnBeforeDelete();
    begin
        if Rec.Type = Rec.Type::Item then
            if Rec."BOM Item" = true then
                Error('Please Only Edit Main Item, Bom is managed by system only');
    end;

    trigger OnAfterDelete();
    var
        FromSO: Record "Sales Header";
        PO: Record "Purchase Header";
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];

        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;

            if (Rec."BOM Item" = false) and (IsItemLine = true) then
                OnDeleteBOMPurchIC(Rec);
            // if (rec.CurrentCompany <> 'HEQS International Pty Ltd') and (rec.Type = rec.Type::Item) then begin
            //     FromSO.Get(Rec."Document Type", Rec."Document No.");
            //     PO.Get(Rec."Document Type", FromSO."Automate Purch.Doc No.");
            //     PLrec.get(rec."Document Type", PO."NO.", rec."Line No.");
            //     PLrec.Delete();
            //     // ISO line
            //     ISLrec.ChangeCompany('HEQS International Pty Ltd');
            //     ISOrec.ChangeCompany('HEQS International Pty Ltd');
            //     ISOrec.SetCurrentKey("External Document No.");
            //     ISORec.SetRange("External Document No.", PO."No.");
            //     if (ISORec.findset) then
            //         repeat
            //             ISLrec.get(rec."Document Type", ISOrec."No.", rec."Line No.");
            //             ISLrec.Delete();
            //         until (ISORec.next() = 0);
            // end;
        end;


    end;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
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

