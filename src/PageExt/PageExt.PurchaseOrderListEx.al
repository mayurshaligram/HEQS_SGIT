pageextension 50112 "Purchase Order List_Ext" extends "Purchase Order List"
{
    layout
    {
        addafter("Buy-from Vendor Name")
        {

            field("Vendor Invoice No."; Rec."Vendor Invoice No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Vendor Shipment No."; Rec."Vendor Shipment No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnOpenPage();
    begin
        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}