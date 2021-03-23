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
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;
        end;

        if (Rec.CurrentCompany <> 'HEQS International Pty Ltd') and IsItemLine then begin
            onInsertBOMPurchIC(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure onInsertBOMPurchIC(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnAfterModify();
    begin
        onUpdatePurch_IC_BOM(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure onUpdatePurch_IC_BOM(var SalesLine: Record "Sales Line");
    begin
    end;

    // Could be refactorize to CodeUnit
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

