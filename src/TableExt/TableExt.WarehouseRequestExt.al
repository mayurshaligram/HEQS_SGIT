tableextension 50123 "Warehouse Request Ext" extends "Warehouse Request"
{
    fields
    {
        field(50103; "Original SO"; Code[20])
        {
            Editable = false;
        }
    }
}