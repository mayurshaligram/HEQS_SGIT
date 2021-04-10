pageextension 50139 ItemCardExt extends "Item Card"
{
    layout
    {
        addafter("Unit Volume")
        {
            field("Unit Assembly Hr"; Rec."Unit Assembly Hr")
            {
                ApplicationArea = Basic, Suite;

                Caption = 'Unit Volume';
                ToolTip = 'The Unit Volume of the Item';
                Editable = true;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}