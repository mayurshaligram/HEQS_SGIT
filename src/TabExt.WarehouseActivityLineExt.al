tableextension 50112 "Warehouse Activity Line_Ext" extends "Warehouse Activity Line"
{
    // Need description
    // Field number not in the system requirement range
    fields
    {
        field(201; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
        field(202; "Total Pick-up Item"; Integer)
        {
            Editable = false;
        }
    }
}