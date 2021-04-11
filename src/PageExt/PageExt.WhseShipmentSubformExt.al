pageextension 50124 "Whse. Shipment Subform Ext" extends "Whse. Shipment Subform"
{
    layout
    {
        addafter("Source No.")
        {
            field("Original SO"; Rec."Original SO")
            {
                Visible = true;
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the number of original document that the line relates to.';
            }
        }
    }

}