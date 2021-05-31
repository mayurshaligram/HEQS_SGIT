tableextension 50112 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "Schedule Nos."; Code[20])
        {
            Caption = 'Schedule Nos.';
            TableRelation = "No. Series";
        }
    }
}