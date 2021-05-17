pageextension 50117 "WhseSubformExt" extends "Whse. Pick Subform"
{
    layout
    {
        addafter("Source No.")
        {
            field("Original SO"; Rec."Original SO")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the original SO for warehouse activity line.';
                Visible = true;
            }
        }
    }
}