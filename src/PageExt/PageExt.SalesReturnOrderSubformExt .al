pageextension 50105 "Sales Return Order Subform_Ext" extends "Sales Return Order Subform"
{
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