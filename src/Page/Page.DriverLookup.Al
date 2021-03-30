page 50107 "Driver Lookup"
{
    Caption = 'Driver';
    Editable = true;
    PageType = List;
    SourceTable = Driver;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Driver';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No for the Driver';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the First Name';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Middle Name';

                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last name';
                }
            }
        }

    }
}

