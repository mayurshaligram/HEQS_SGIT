tableextension 50127 "Sales Invoice Ext" extends "Sales Invoice Line"
{
    fields
    {
        field(50100; "BOM Item"; Boolean)
        {
            Caption = 'BOM Item';
            Description = 'BOM Item for Sales Invoice Line';
            Editable = false;
        }
    }
}