pageextension 50125 "Posted Purchase Invoices_Ext" extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field("Vendor Shipment No."; Rec."Vendor Shipment No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Posted SI No."; Rec."Posted SI No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Posted SI No.(Inventory Co.)"; Rec."Posted SI No.(Inventory Co.)")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}