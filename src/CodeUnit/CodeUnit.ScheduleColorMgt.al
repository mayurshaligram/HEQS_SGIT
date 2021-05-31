codeunit 50110 "Schedule Color Mgt"
{
    procedure ChangeColor(Schedule: Record Schedule): Text[50]
    begin
        case Schedule.Status of
            Schedule.Status::Completed:
                exit('Subordinate');
            Schedule.Status::NeedReschedule:
                exit('Ambiguous');
            Schedule.Status::Pending:
                exit('Attention');
            Schedule.Status::Norm:
                exit('Accent');
        end
    end;

}