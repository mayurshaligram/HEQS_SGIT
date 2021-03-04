pageextension 50124 "Purchase Lines Subform_Ext" extends "Purchase Order Subform"
{
    Caption = 'Purchase Order Subform_Ext';
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
    }
}