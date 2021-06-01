page 50117 "Schedule Subform"
{
    Caption = 'Schedule';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Schedule";
    SourceTableView = WHERE(Status = FILTER(Norm | NeedReschedule));

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field(Suburb; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}