page 50108 "Vehicle Lookup"
{
    Caption = 'Vehicles';
    Editable = true;
    PageType = List;
    SourceTable = Vehicle;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Vehicle';
    ApplicationArea = All;

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
            }
        }

    }
}

