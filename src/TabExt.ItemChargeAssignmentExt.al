tableextension 50108 "Item Charge AssignmentExt" extends "Item Charge Assignment (Purch)"
{
    Caption = 'Item Charge Assignment (Purch)_Ext';
    fields
    {
        modify("Amount to Assign")
        {
            trigger OnAfterValidate()
            begin
                // "Amount to Assign" := "Qty. Assigned" * ;
                Message('ssss');
            end;
        }
    }
}