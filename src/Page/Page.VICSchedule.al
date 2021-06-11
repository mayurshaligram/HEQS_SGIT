page 50118 "VIC Schedule"
{
    Caption = 'VIC Schedule';
    PageType = List;
    SourceTable = Schedule;
    ApplicationArea = All;
    ModifyAllowed = false;
    CardPageId = 50114;
    UsageCategory = Lists;
    SourceTableView = WHERE("From Location Code" = CONST('VIC'));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    StyleExpr = TempStr;
                }
                field("Source No."; Rec."Source No.")
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Suburb; Rec."Ship-to City")
                {
                    Caption = 'Suburb';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Zone; Rec.Zone)
                {
                    Caption = 'Zone';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    Caption = 'Delivery Date';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Delivery Time"; Rec."Delivery Time")
                {
                    Caption = 'Delivery Time/Note';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Delivery Items"; Rec."Delivery Items")
                {
                    Caption = 'Delivery Items';
                    MultiLine = true;
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Assemble; Rec.Assemble)
                {
                    Caption = 'Assemble';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Extra; Rec.Extra)
                {
                    Caption = 'Extra';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Customer; Rec.Customer)
                {
                    Caption = 'Customer';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    Caption = 'Phone';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Driver"; Rec.Driver)
                {
                    Caption = 'Driver';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Vehicle; Rec.Vehicle)
                {
                    Caption = 'Vehicle';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Remote; Rec.Remote)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Complete Order")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Schedule: Record Schedule;
                begin
                    CurrPage.SetSelectionFilter(Schedule);
                    if Schedule.FindSet() then
                        repeat
                            Schedule.Status := Schedule.Status::Completed;
                            Schedule.Modify();
                        until Schedule.Next() = 0;
                end;
            }
            action("New Trip")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Schedule: Record Schedule;
                    Trip: Record Trip;
                    TempInt: Integer;
                    TempBool: Boolean;
                    ConfirmStr: Text;
                    ResultStr: Text;
                begin
                    CurrPage.SetSelectionFilter(Schedule);
                    if Schedule.FindSet() then begin
                        Trip.Init();
                        Trip.Insert(true);
                        TempInt := 0;
                        repeat
                            TempBool := true;
                            if Schedule."Trip No." <> '' then begin
                                ConfirmStr := Schedule."Source No." + ' has already in Trip ' + Schedule."Trip No." + ' do you want to move it to the new trip?';
                                TempBool := Confirm(ConfirmStr);
                            end;
                            if TempBool then begin
                                Schedule."Trip No." := Trip."No.";
                                Schedule."Trip Sequece" := TempInt;
                                Schedule.Modify();
                                TempInt += 1;
                            end
                        until Schedule.Next() = 0;
                    end;
                    if TempInt >= 1 then begin
                        ResultStr := 'Trip ' + Trip."No." + ' has been created, do you want to open to adjust sequence?';
                        TempBool := Confirm(ResultStr);
                        if TempBool then begin
                            Commit();
                            Page.Run(Page::"Trip Card", Trip);
                        end;
                    end
                    else
                        Trip.Delete();
                end;
            }
            action("View Trip")
            {
                ApplicationArea = All;
                trigger OnAction();
                var
                    Trip: Record Trip;
                begin
                    if Trip.Get(Rec."Trip No.") then
                        Page.RunModal(Page::"Trip Card", Trip)
                    else
                        Message('This Schedule item has not been assign to a trip.');
                end;
            }
            action("Assign Trip")
            {
                ApplicationArea = All;
                trigger OnAction();
                var
                    Trip: Record Trip;
                begin
                    if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then
                        Rec."Trip No." := Trip."No.";
                    Rec.Modify();
                end;
            }
        }

    }

    views
    {
        view("Sorting By Trip")
        {
            Caption = 'Sorting By Trip';
            OrderBy = Ascending("Trip No.", "Trip Sequece");
        }
        view(NeedSchedule)
        {
            Caption = 'Need Schedule (Norm and PostPoned)';
            SharedLayout = true;
            Filters = where("Status" = filter(Norm | Postponed));
        }
        view(Postponed)
        {
            Caption = 'Postponed (Yellow)';
            SharedLayout = true;
            Filters = where("Status" = filter(Postponed));
        }
        view(Complete)
        {
            Caption = 'Complete (Green)';
            SharedLayout = true;
            Filters = where("Status" = filter(Completed));
        }
        view(RemoteView)
        {
            Caption = 'Remote (Woollongong)';
            SharedLayout = true;
            Filters = where("Remote" = const(true));
        }

        view("VIC - NSW")
        {
            Caption = 'VIC - NSW';
            SharedLayout = true;
            Filters = where("To Location Code" = const('NSW'));
        }
        view("VIC - QLD")
        {
            Caption = 'VIC - QLD';
            SharedLayout = true;
            Filters = where("To Location Code" = const('QLD'));
        }
        view("Property Management")
        {
            Caption = 'Property Management';
            SharedLayout = true;
            Filters = where("Source Type" = filter("Property Management"));
        }
        view("Second Lease Pick Up")
        {
            Caption = 'Second Lease Pick Up';
            SharedLayout = true;
            Filters = where(Status = filter(NeedReschedule));
        }
    }

    var
        ScheduleColorMgt: Codeunit "Schedule Color Mgt1";
        TempStr: Text;

    trigger OnAfterGetRecord()
    begin
        TempStr := ScheduleColorMgt.ChangeColor(Rec);
    end;
}