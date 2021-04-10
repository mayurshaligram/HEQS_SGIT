pageextension 50114 "Purchase Order List_Ext" extends "Purchase Order List"
{
    trigger OnOpenPage();
    begin
        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}