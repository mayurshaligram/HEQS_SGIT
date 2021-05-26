pageextension 50126 "Posted Sales Shipments Ext" extends "Posted Sales Shipments"
{
    layout
    {
        addafter("No.")
        {
            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies Order No';
            }
        }
    }
}