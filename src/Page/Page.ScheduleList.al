page 50113 "Schedule List"
{
    Caption = 'NSW Schedule';
    PageType = List;
    SourceTable = Schedule;
    ApplicationArea = All;
    ModifyAllowed = true;
    Editable = true;
    CardPageId = 50114;
    UsageCategory = Lists;
    SourceTableView = WHERE("From Location Code" = CONST('NSW'));
    RefreshOnActivate = true;
    // sorting(descending"Trip No.", Ascending"Trip Sequece")
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
                field("Subsidiary Source No."; Rec."Subsidiary Source No.")
                {
                    Caption = 'Original SO';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Source No."; Rec."Source No.")
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;
                    Visible = false;
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
                field("Trip No."; Rec."Trip No.")
                {
                    Caption = 'Trip';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                    trigger OnValidate();
                    begin
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Trip: Record Trip;
                        SubformCard: Page "Schedule Subform";
                        xTrip: Record Trip;
                        TempInt: Integer;
                        Schedule: Record Schedule;
                    begin
                        Trip.Reset();
                        if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then
                            if Rec."Trip No." <> Trip."No." then begin
                                TempInt := 0;
                                Rec."Trip No." := '';
                                Rec."Trip Sequece" := 0;
                                Rec.Modify(true);
                                Clear(Schedule);
                                Schedule.SetRange("Trip No.", Rec."No.");
                                if Schedule.FindSet() then
                                    repeat
                                        Schedule."Trip Sequece" := TempInt;
                                        TempInt += 1;
                                        Schedule.Modify(true);
                                    until Schedule.Next() = 0;
                                Trip.CalcFields("Total Schedule");
                                Rec."Trip Sequece" := Trip."Total Schedule";
                                Rec."Trip No." := Trip."No.";
                                Rec.Modify(true);

                                CurrPage.Update();
                            end;
                    end;
                }
                field("Trip Sequece"; Rec."Trip Sequece")
                {
                    Caption = 'Trip Sequence';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Remote; Rec.Remote)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
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
                    Schedule1: Record Schedule;
                    TempSchedule: Record Schedule;
                    Trip: Record Trip;
                    TempInt: Integer;
                    TempBool: Boolean;
                    ConfirmStr: Text;
                    ResultStr: Text;

                    Schedule: Record Schedule;
                    TempRecordNo: List of [Code[20]];
                    ScheduleNo: Code[20];
                begin
                    CurrPage.SetSelectionFilter(Schedule1);
                    // if Schedule.FindSet() then begin
                    //     repeat
                    //         Message(Schedule."No.");
                    //     until Schedule.Next() = 0;
                    // end;
                    if Schedule1.FindSet() then begin
                        repeat
                            TempRecordNo.Add(Schedule1."No.");
                        until Schedule1.Next() = 0;
                        Trip.Init();
                        Trip.Insert(true);
                        TempInt := 0;
                    end;

                    foreach ScheduleNo in TempRecordNo do begin
                        Schedule.Reset();
                        Schedule.Get(ScheduleNo);
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
                    Schedule: Record Schedule;
                    ScheduleMgt: Codeunit "Schedule Mgt";
                    TempRecordNo: List of [Code[20]];
                    TempNo: Code[20];
                begin
                    if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin
                        CurrPage.SetSelectionFilter(Schedule);
                        if Schedule.FindSet() then
                            repeat
                                TempRecordNo.Add(Schedule."No.");
                            until Schedule.Next() = 0;
                        foreach TempNo in TempRecordNo do begin
                            Schedule.Reset();
                            Schedule.Get(TempNo);
                            AssignTrip(Schedule, Trip."No.");
                        end;
                        CurrPage.Update();
                    end;
                end;
            }

        }
    }
    views
    {
        view(NeedSchedule)
        {
            Caption = 'Need Schedule (Norm and PostPoned)';
            SharedLayout = true;
            OrderBy = Ascending("Trip No.", "Trip Sequece");
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

        view("NSW - QLD")
        {
            Caption = 'NSW - QLD';
            SharedLayout = true;
            Filters = where("To Location Code" = const('QLD'));
        }
        view("NSW - VIC")
        {
            Caption = 'NSW - VIC';
            SharedLayout = true;
            Filters = where("To Location Code" = const('VIC'));
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
            Filters = where(Status = filter(Rescheduled));
        }

    }

    var
        ScheduleColorMgt: Codeunit "Schedule Color Mgt1";
        TempStr: Text;

    trigger OnAfterGetRecord()
    begin
        TempStr := ScheduleColorMgt.ChangeColor(Rec);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Global Sequence");
        Rec.SetAscending("Global Sequence", true);
    end;




    procedure GetSelectionFilter(): Text;
    var
        Schedule: Record Schedule;
        FilterStr: Text;
    begin
        CurrPage.SetSelectionFilter(Schedule);
        if Schedule.FindSet() then
            repeat
                FilterStr += Schedule."No." + '|';
            until Schedule.Next() = 0;
        FilterStr := FilterStr.TrimEnd('|');
        exit(FilterStr);
    end;

    procedure AssignTrip(var Schedule: Record Schedule; TripNo: Code[20]);
    var
        TempBool: Boolean;
    begin
        TempBool := ComfirmChange(Schedule);
        if TempBool then
            AssignTripNo(Schedule, TripNo);
    end;

    procedure ComfirmChange(var
                            Schedule: Record Schedule): Boolean;

    var
        ConfirmStr: Text;
    begin
        if Schedule."Trip No." <> '' then begin
            ConfirmStr := Schedule."Source No." + ' has already in Trip ' + Schedule."Trip No." + ' do you want to move it to the new trip?';
            if Confirm(ConfirmStr) = false then
                exit(false);
        end;
        exit(true);
    end;

    procedure AssignTripNo(var Schedule: Record Schedule; TripNo: Code[20]);
    var
        Trip: Record Trip;
    begin
        Schedule."Trip No." := TripNo;
        Trip.Get(TripNo);
        Trip.CalcFields("Total Schedule");
        Schedule."Trip Sequece" := Trip."Total Schedule";
        Schedule.Modify();
    end;



}