tableextension 50109 "Warehouse Shipment Line_Ext" extends "Warehouse Shipment Line"
{
    // Need description
    // Field Number not within the system requirement
    fields
    {
        field(201; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
    }
}