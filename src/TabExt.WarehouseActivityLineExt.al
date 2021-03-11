tableextension 50112 "Warehouse Activity Line_Ext" extends "Warehouse Activity Line"
{
    Caption = 'Warehouse Activity Line_Ext';

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