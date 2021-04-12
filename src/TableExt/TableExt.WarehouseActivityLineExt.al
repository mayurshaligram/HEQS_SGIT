tableextension 50107 "Warehouse Activity Line_Ext" extends "Warehouse Activity Line"
{
    // Need description
    // Field number not in the system requirement range
    fields
    {
        field(50100; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
        field(50101; "Total Pick-up Item"; Integer)
        {
            Editable = false;
        }
        field(50102; "Original SO"; Code[20])
        {
            Editable = false;
        }
    }
}