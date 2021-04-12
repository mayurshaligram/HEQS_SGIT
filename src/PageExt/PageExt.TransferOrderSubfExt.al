pageextension 50113 "Transfer Order Subform_Ext" extends "Transfer Order Subform"
{
    Caption = 'Transfer Order Subform_Ext';
    layout
    {
        modify("Item No.")
        {
            trigger OnAfterValidate();
            begin
                CurrPage.Update();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate();
            begin
                CurrPage.Update();
            end;
        }
    }
}