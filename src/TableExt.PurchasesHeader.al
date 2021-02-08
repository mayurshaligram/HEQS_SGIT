tableextension 50101 "Purchase Header_Ext" extends "Purchase Header"
{
    Caption = 'Purchase Header_Ext';
    fields
    {
        field(28088; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }
    }
}