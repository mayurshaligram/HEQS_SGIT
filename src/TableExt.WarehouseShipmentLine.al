tableextension 50109 "Warehouse Shipment Line_Ext" extends "Warehouse Shipment Line"
{
    Caption = 'Warehouse Shipment Line_Ext';
    fields
    {
        field(201; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
    }
}