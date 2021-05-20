page 50112 ChangePostedSalesInvoice
{
    PageType = Card;
    SourceTable = "Sales Invoice Header";
    Permissions = TableData "Sales Invoice Header" = imd;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin

    //             end;
    //         }
    //     }
    // }
}