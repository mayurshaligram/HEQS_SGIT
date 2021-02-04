tableextension 50108 "Purchase Line_Ext" extends "Purchase Line"
{
    fields
    {
        field(201; "BOM Item"; Boolean)
        {
            Editable = false;
        }
    }
}