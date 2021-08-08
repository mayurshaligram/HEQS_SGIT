page 50140 PostingDateChange
{
    PageType = Card;
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    ShowFilter = false;
    SourceTable = "Sales Header";
    SourceTableTemporary = true;


    //SourceTable = TableName;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    Editable = true;
                }
            }
        }
    }

}