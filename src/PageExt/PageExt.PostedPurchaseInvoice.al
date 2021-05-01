pageextension 50122 "Posted Purchase Invoice Ext" extends "Posted Purchase Invoice"
{
    layout
    {
        addafter("Vendor Order No.")
        {

            field("Vendor Shipment No."; Rec."Vendor Shipment No.")
            {
                Caption = 'Vendor Shipment No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor s shipment number.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}