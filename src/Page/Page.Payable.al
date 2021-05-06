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
                field("Posted Invoice No"; Rec."Posted Invoice No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Posted Invoice No. if posted';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vendor Invoice No.';

                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Company';
                }
                field(Vendor; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vendor';
                }
                field(Item; Rec.Item)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Items for the payable';
                    MultiLine = true;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code for the amount';
                }
                field(Amount; Rec."AUD")
                {
                    Caption = 'Amount';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount for AUD';
                }
                field("Amount Remaining"; Rec."USD")
                {
                    Caption = 'Amount Remaining';
                    ApplicationArea = All;
                    ToolTip = 'Specifies Amount Remaining';
                }
                field("Amount Received Not Invoiced"; Rec."Amount Received Not Invoiced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Amount Remaining';
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field("Source of Cash"; Rec."Payment Method Code")
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
                // field("Account Details"; Rec."Account Details")
                // {
                //     ApplicationArea = All;
                // }

            }
        }

    }
}


