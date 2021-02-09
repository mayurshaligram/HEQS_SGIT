tableextension 50112 "Warehouse Activity Line_Ext" extends "Warehouse Activity Line"
{
    Caption = 'Warehouse Activity Line_Ext';

    fields
    {
        field(201; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
    }
    trigger OnInsert();
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        Message('On insert activity');
        WarehouseShipmentLine.SetRange("Item No.", "Item No.");
        if WarehouseShipmentLine.FindSet() then begin
            Rec."Pick-up Item" := WarehouseShipmentLine."Pick-up Item";
            Modify();
            Message('After modify');
        end;
    end;
}