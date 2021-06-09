codeunit 50110 "Schedule Color Mgt1"
{
    procedure ChangeColor(Schedule: Record Schedule): Text[50]
    begin

        case Schedule.Status of
            Schedule.Status::Completed:
                exit('Favorable');
            Schedule.Status::NeedReschedule:
                exit('StrongAccent');
            Schedule.Status::Postponed:
                exit('Ambiguous');
            Schedule.Status::Norm:
                exit('Strong');
        end;
    end;

}