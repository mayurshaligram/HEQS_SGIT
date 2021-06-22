page 50115 "Trip List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Trip;
    ModifyAllowed = false;
    CardPageId = 50116;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStr;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStr;
                }
                field(Ongoing; OnGoingStr)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStr;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStr;
                }

                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStr;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
        OnGoingStr: Text;
        ColorStr: Text;


    trigger OnAfterGetRecord();
    begin
        Rec.CalcFields("Total Completed");
        Rec.CalcFields("Total Schedule");
        OnGoingStr := format(Rec."Total Completed") + '/' + format(Rec."Total Schedule");
        case Rec.Status of
            Rec.Status::Completed:
                ColorStr := 'Favorable';
            Rec.Status::Released:
                ColorStr := 'AttentionAccent';
            Rec.Status::Open:
                ColorStr := 'Strong';
        end
    end;
}