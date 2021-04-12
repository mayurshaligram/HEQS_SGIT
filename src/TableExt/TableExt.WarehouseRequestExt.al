tableextension 50109 "Warehouse Request Ext" extends "Warehouse Request"
{
    fields
    {
        field(50100; "Original SO"; Code[20])
        {
            Editable = false;
        }
    }
}