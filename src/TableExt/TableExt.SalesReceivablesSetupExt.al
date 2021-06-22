tableextension 50112 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "Schedule Nos."; Code[20])
        {
            Caption = 'Schedule Nos.';
            TableRelation = "No. Series";
        }
        field(50101; "Trip"; Code[20])
        {
            Caption = 'Trip Nos.';
            TableRelation = "No. Series";
        }
    }
}