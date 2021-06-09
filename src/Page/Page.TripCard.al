page 50116 "Trip Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Trip;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
            }
            part(ScheduleSubform; "Schedule Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Trip No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
    }

}