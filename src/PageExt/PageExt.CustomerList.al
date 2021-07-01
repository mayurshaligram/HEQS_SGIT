pageextension 50128 MyExtension extends "Customer List"
{
    trigger OnOpenPage();
    begin
        Report.Run(Report::MyRdlReport);
    end;
}