tableextension 50101 "Purchase Header_Ext" extends "Purchase Header"
{
    Caption = 'Purchase Header_Ext';
    fields
    {
        field(50100; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }
        field(50101; "Sales Order Ref"; Text[20])
        {
            Caption = 'Automate Purch.Doc No.';
            Editable = false;
        }
    }
}