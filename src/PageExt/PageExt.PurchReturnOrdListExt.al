pageextension 50115 "Purchase Return Order List_Ext" extends "Purchase Return Order List"
{
    trigger OnOpenPage();
    begin
        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}