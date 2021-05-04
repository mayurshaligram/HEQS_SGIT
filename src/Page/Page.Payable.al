page 50110 Payable
{
    Caption = 'Payable';
    Editable = true;
    PageType = List;
    SourceTable = Payable;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'Payable';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document No. for the Payable';
                }
                field(Item; Rec.Item)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Items for the payable';
                    MultiLine = true;
                }
                field(AUD; Rec.AUD)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount for AUD';
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field("Source of Cash"; Rec."Source of Cash")
                {
                    ApplicationArea = All;
                }
                field(USD; Rec.USD)
                {
                    ApplicationArea = All;
                }
                field("Date of Payment"; Rec."Date of Payment")
                {
                    ApplicationArea = All;
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
                field(Approval; Rec.Approval)
                {
                    ApplicationArea = All;
                }
                field("Director Approval"; Rec."Director Approval")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Account Details"; Rec."Account Details")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice No"; Rec."Posted Invoice No")
                {
                    ApplicationArea = All;
                }
            }
        }

    }
}


