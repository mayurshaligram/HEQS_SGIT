pageextension 50100 SalesReceivablesSetupPageExt extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Customer Nos.")
        {
            field("Schedule Nos."; Rec."Schedule Nos.")
            {
                Caption = 'Schedule Nos.';
                ApplicationArea = All;
            }
        }
    }
}