pageextension 50129 "Item List Ext" extends "Item List"
{
    layout
    {
        addafter(Type)
        {
            field(NSW; Rec.NSW)
            {
                ApplicationArea = All;
            }
            field(VIC; Rec.VIC)
            {
                ApplicationArea = All;
            }
            field(QLD; Rec.QLD)
            {
                ApplicationArea = All;
            }
        }
    }
}