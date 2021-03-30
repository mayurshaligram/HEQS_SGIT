tableextension 50118 TransferLineExt extends "Transfer Line"
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

    var
        myInt: Integer;

    trigger OnAfterInsert();
    var
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        Item.Get(Rec."Item No.");
        if (Item.Type = Item.Type::Inventory) then IsItemLine := true;


        if (Rec.CurrentCompany = 'HEQS International Pty Ltd') and IsItemLine then begin
            onInsertBOM(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure onInsertBOM(var TransferLine: Record "Transfer Line");
    begin
    end;


    trigger OnAfterModify();
    var
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Item.Type = Item.Type::Inventory) then IsItemLine := true;

        if (Rec.CurrentCompany = 'HEQS International Pty Ltd') and IsItemLine then begin
            OnUpdateBOM(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBOM(var TransferLine: Record "Transfer Line");
    begin
    end;
}