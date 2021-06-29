page 50113 "Schedule List"
{
    Caption = 'Schedule';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = Schedule;
    ApplicationArea = All;
    ModifyAllowed = true;
    Editable = true;
    CardPageId = 50114;
    UsageCategory = Lists;
    // SourceTableView = WHERE("From Location Code" = CONST('NSW'));
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
                    MultiLine = true;
                    ApplicationArea = All;
                    Style = Unfavorable;
                }
                field("Delivery Items"; Rec."Delivery Items")
                {
                    Caption = 'Delivery Items';
                    MultiLine = true;
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Assemble; AssembleStr)
                {
                    Caption = 'Assemble';
                    ApplicationArea = All;
                    Style = Unfavorable;
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
                    StyleExpr = TempStr;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field("Delivery Option"; Rec."Delivery Option")
                {
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                    Visible = false;
                }
                field("Shipping Agent"; Rec."Shipping Agent")
                {
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                    Visible = false;
                }
                field("QC Requirement"; Rec."QC Requirement")
                {
                    ApplicationArea = All;
                    StyleExpr = TempStr;
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
                        Trip."Location Code" := Schedule1."From Location Code";
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
                            Schedule.Modify(True);
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
                        CurrPage.Update();
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
                    if Trip.Get(Rec."Trip No.") then begin
                        Page.RunModal(Page::"Trip Card", Trip);
                        CurrPage.Update();
                    end
                    else
                        Message('This Schedule item has not been assign to a trip.');
                end;
            }
            action("Assign Trip")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    CurrentRec: Record Schedule;
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
            action("Up")
            {
                ApplicationArea = All;
                Image = MoveUp;
                ToolTip = 'Move up the item in Schedule. Shift+ctrl+J';
                ShortcutKey = 'Shift+Ctrl+J';

                trigger OnAction();
                var
                    Schedule: Record Schedule;
                    Trip: Record Trip;
                    Message: Label 'Scheduel %1 is at top of Trip %2 Do you want to move up the last item in Trip %3';
                    TempText: Text;
                begin
                    if Rec."Trip No." = '' then begin
                        // Assign Trip
                        if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin

                            Rec."Trip No." := Trip."No.";
                            Trip.CalcFields("Total Schedule");
                            Rec."Trip Sequece" := Trip."Total Schedule";
                            Rec.Modify(true);
                            CurrPage.Update();

                        end;
                    end else // Move down the trip if the sequence = 0
                    begin
                        if Rec."Trip Sequece" = 0 then begin
                            TempText := 'Schedule ' + Rec."Subsidiary Source No." + ' is at top of Trip ' + Rec."Trip No." + '. Do you want to move to other Trip?';
                            if Confirm(TempText) then begin
                                if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin
                                    if Trip."No." <> Rec."Trip No." then begin
                                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                                        Rec."Trip No." := Trip."No.";
                                        Trip.CalcFields("Total Schedule");
                                        Rec."Trip Sequece" := Trip."Total Schedule";
                                        Rec.Modify(true);
                                        CurrPage.Update();
                                    end;
                                    if Schedule.FindSet() then
                                        repeat
                                            Schedule."Trip Sequece" -= 1;
                                            Schedule."Global Sequence" := Format(Schedule."Trip No.") + Format(Schedule."Trip Sequece");
                                            Schedule.Modify();
                                        until Schedule.Next() = 0;
                                end;
                            end;
                        end
                        else begin
                            // Switch the trip sequence with another schedule item in one trip
                            Schedule.Reset();
                            Schedule.SetRange("Trip No.", Rec."Trip No.");
                            Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" - 1);
                            if Schedule.FindSet() then begin
                                Schedule."Trip Sequece" := Rec."Trip Sequece";
                                Rec."Trip Sequece" -= 1;
                                Schedule.Modify(true);
                                Rec.Modify(true);
                                CurrPage.Update();
                            end;
                        end;
                    end;

                end;
            }
            action("Down")
            {
                ApplicationArea = All;
                Image = MoveDown;
                ToolTip = 'Move down the item in Schedule.Shit+Ctrl+K';
                ShortcutKey = 'Shift+Ctrl+K';

                trigger OnAction();
                var
                    Schedule: Record Schedule;
                    Trip: Record Trip;
                    TempText: Text;
                begin
                    if Rec."Trip No." = '' then begin
                        if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin
                            if Trip."No." <> Rec."Trip No." then begin
                                Rec."Trip No." := Trip."No.";
                                Trip.CalcFields("Total Schedule");
                                Rec."Trip Sequece" := Trip."Total Schedule";
                                Rec.Modify(true);
                                CurrPage.Update();
                            end;
                        end;
                    end else
                    // if is trip sequence is equal to the total sequence of the trip then ask whether move to other trip;

                    begin
                        Trip.Get(Rec."Trip No.");
                        Trip.CalcFields("Total Schedule");
                        if (Rec."Trip Sequece" + 1) >= Trip."Total Schedule" then begin
                            TempText := 'Schedule ' + Rec."Subsidiary Source No." + ' is at bottom of Trip ' + Rec."Trip No." + '. Do you want to move this schedule item to the other Trip?';
                            if Confirm(TempText) then begin
                                if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin
                                    if Trip."No." <> Rec."Trip No." then begin
                                        Rec."Trip No." := Trip."No.";
                                        Trip.CalcFields("Total Schedule");
                                        Rec."Trip Sequece" := Trip."Total Schedule";
                                        Rec.Modify(true);
                                        CurrPage.Update();
                                    end;
                                end;
                            end;
                        end else begin
                            Schedule.Reset();
                            Schedule.SetRange("Trip No.", Rec."Trip No.");
                            Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" + 1);
                            if Schedule.FindSet() then begin
                                Schedule."Trip Sequece" := Rec."Trip Sequece";
                                Rec."Trip Sequece" += 1;
                                Schedule.Modify(true);
                                Rec.Modify(true);
                                CurrPage.Update();
                            end;
                        end;

                    end;
                end;
            }

        }
    }
    views
    {
        view("Current Delivery Schedule")
        {
            Caption = 'Current Delivery Schedule';
            SharedLayout = true;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Delivery),
                            Status = filter(Norm | Postponed | Released),
                            "From Location Code" = field("From Location Code"));
        }
        view("Online Platform Pickup Schedule")
        {
            Caption = 'Online Platform Pickup Schedule';
            SharedLayout = false;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Pickup),
                            Status = filter(Norm | Postponed | Released), "Subsidiary Source No." = filter('IFSO*'),
                            "From Location Code" = field("From Location Code"));
            layout
            {
                modify(Suburb)
                {
                    Visible = false;
                }
                modify(Zone)
                {
                    Visible = false;
                }
                modify(Assemble)
                {
                    Visible = false;
                }
                modify(Extra)
                {
                    Visible = false;
                }
                modify("Phone No.")
                {
                    Visible = false;
                }
                modify(Driver)
                {
                    Visible = false;
                }
                modify(Vehicle)
                {
                    Visible = false;
                }
                modify("Trip No.")
                {
                    Visible = false;
                }
                modify("Trip Sequece")
                {
                    Visible = false;
                }
                modify(Status)
                {
                    Visible = false;
                }
                modify("Shipping Agent")
                {
                    Visible = true;
                }
                modify(Name)
                {
                    Visible = true;
                }
                modify(Customer)
                {
                    Visible = false;
                }
                movebefore("Shipping Agent"; Name)
                moveafter("Shipping Agent"; "Delivery Time")
                moveafter("Delivery Items"; "Delivery Date")

                modify("QC Requirement")
                {
                    Visible = true;
                }
            }
        }
        view("Pickup Schedule")
        {
            Caption = 'Pick Up Order';
            SharedLayout = false;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Pickup),
                            Status = filter(Norm | Postponed | Released),
                            "Subsidiary Source No." = filter('<>IFSO*'),
                            "From Location Code" = field("From Location Code"));
            layout
            {
                modify(Suburb)
                {
                    Visible = false;
                }
                modify(Zone)
                {
                    Visible = false;
                }
                modify(Assemble)
                {
                    Visible = false;
                }
                modify(Extra)
                {
                    Visible = false;
                }
                modify(Driver)
                {
                    Visible = false;
                }
                modify(Vehicle)
                {
                    Visible = false;
                }
                modify("Trip No.")
                {
                    Visible = false;
                }
                modify("Trip Sequece")
                {
                    Visible = false;
                }
                modify(Status)
                {
                    Visible = false;
                }
                modify("Shipping Agent")
                {
                    Visible = true;
                }
                movebefore("Shipping Agent"; Name)
                moveafter("Shipping Agent"; "Delivery Time")
                moveafter("Delivery Items"; "Delivery Date")
            }
        }
        view("Archived Delivery Schedule")
        {
            Caption = 'Archived Delivery Schedule';
            SharedLayout = true;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Delivery),
                            Status = filter(Completed),
                            "From Location Code" = field("From Location Code"));
        }
        view("Archived Online Pickup")
        {
            Caption = 'Archived Online Pickup';
            SharedLayout = false;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Pickup),
                            Status = filter(Completed),
                            "Subsidiary Source No." = filter('IFSO*'),
                            "From Location Code" = field("From Location Code"));
            layout
            {
                modify(Suburb)
                {
                    Visible = false;
                }
                modify(Zone)
                {
                    Visible = false;
                }
                modify(Assemble)
                {
                    Visible = false;
                }
                modify(Extra)
                {
                    Visible = false;
                }
                modify("Phone No.")
                {
                    Visible = false;
                }
                modify(Driver)
                {
                    Visible = false;
                }
                modify(Vehicle)
                {
                    Visible = false;
                }
                modify("Trip No.")
                {
                    Visible = false;
                }
                modify("Trip Sequece")
                {
                    Visible = false;
                }
                modify(Status)
                {
                    Visible = false;
                }
                modify("Shipping Agent")
                {
                    Visible = true;
                }
                modify(Name)
                {
                    Visible = true;
                }
                modify(Customer)
                {
                    Visible = false;
                }
                movebefore("Shipping Agent"; Name)
                moveafter("Shipping Agent"; "Delivery Time")
                moveafter("Delivery Items"; "Delivery Date")

                modify("QC Requirement")
                {
                    Visible = true;
                }
            }
        }
        view("Archived Pickup")
        {
            Caption = 'Archived Pickup';
            SharedLayout = false;
            OrderBy = ascending("Trip No.", "Trip Sequece");
            Filters = where("Delivery Option" = const(Pickup),
                            Status = filter(Completed),
                            "Subsidiary Source No." = filter('<>IFSO*'),
                            "From Location Code" = field("From Location Code"));
            layout
            {
                modify(Suburb)
                {
                    Visible = false;
                }
                modify(Zone)
                {
                    Visible = false;
                }
                modify(Assemble)
                {
                    Visible = false;
                }
                modify(Extra)
                {
                    Visible = false;
                }
                modify(Driver)
                {
                    Visible = false;
                }
                modify(Vehicle)
                {
                    Visible = false;
                }
                modify("Trip No.")
                {
                    Visible = false;
                }
                modify("Trip Sequece")
                {
                    Visible = false;
                }
                modify(Status)
                {
                    Visible = false;
                }
                modify("Shipping Agent")
                {
                    Visible = true;
                }
                movebefore("Shipping Agent"; Name)
                moveafter("Shipping Agent"; "Delivery Time")
                moveafter("Delivery Items"; "Delivery Date")
            }
        }
        view(NeedSchedule)
        {
            Caption = 'Need Schedule (Norm and PostPoned)';
            SharedLayout = true;
            OrderBy = Ascending("Trip No.", "Trip Sequece");
            Filters = where("Status" = filter(Norm | Postponed),
            "From Location Code" = field("From Location Code"));
        }
        view(Postponed)
        {
            Caption = 'Postponed (Yellow)';
            SharedLayout = true;
            Filters = where("Status" = filter(Postponed),
            "From Location Code" = field("From Location Code"));
        }
        view(Complete)
        {
            Caption = 'Complete (Green)';
            SharedLayout = true;
            Filters = where("Status" = filter(Completed),
            "From Location Code" = field("From Location Code"));
        }
        view(RemoteView)
        {
            Caption = 'Remote (Woollongong)';
            SharedLayout = true;
            Filters = where("Remote" = const(true), "From Location Code" = field("From Location Code"));
        }

        view("TO - QLD")
        {
            Caption = 'TO - QLD';
            SharedLayout = true;
            Filters = where("To Location Code" = const('QLD'), "From Location Code" = field("From Location Code"));
        }
        view("TO - VIC")
        {
            Caption = 'TO - VIC';
            SharedLayout = true;
            Filters = where("To Location Code" = const('VIC'), "From Location Code" = field("From Location Code"));
        }
        view("TO - NSW")
        {
            Caption = 'TO - NSW';
            SharedLayout = true;
            Filters = where("To Location Code" = const('NSW'), "From Location Code" = field("From Location Code"));
        }
        view("Property Management")
        {
            Caption = 'Property Management';
            SharedLayout = true;
            Filters = where("Source Type" = filter("Property Management"), "From Location Code" = field("From Location Code"));
        }
        view("Second Lease Pick Up")
        {
            Caption = 'Second Lease Pick Up';
            SharedLayout = true;
            Filters = where(Status = filter(Rescheduled), "From Location Code" = field("From Location Code"));
        }
    }

    var
        ScheduleColorMgt: Codeunit "Schedule Color Mgt1";
        TempStr: Text;
        DataCaption: Text;
        AssembleStr: Text;

    trigger OnAfterGetRecord()
    begin
        TempStr := ScheduleColorMgt.ChangeColor(Rec);
        DataCaption := Rec."From Location Code";
        if Rec.Assemble then
            AssembleStr := 'Yes'
        else
            AssembleStr := '';
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
            ConfirmStr := Schedule."Subsidiary Source No." + ' has already in Trip ' + Schedule."Trip No." + ' do you want to move it to the new trip?';
            if Confirm(ConfirmStr) = false then
                exit(false);
        end;
        exit(true);
    end;

    procedure AssignTripNo(var Schedule: Record Schedule; TripNo: Code[20]);
    var
        xSchedule: Record Schedule;
        Trip: Record Trip;
    begin
        xSchedule.Reset();
        xSchedule.SetCurrentKey("Trip No.", "Trip Sequece");
        xSchedule.SetRange("Trip No.", Rec."Trip No.");
        xSchedule.SetFilter("Trip Sequece", '>%1', Rec."Trip Sequece");
        Schedule."Trip No." := TripNo;
        Trip.Get(TripNo);
        Trip.CalcFields("Total Schedule");
        Schedule."Trip Sequece" := Trip."Total Schedule";
        Schedule.Modify(true);
        if xSchedule.FindSet() then
            repeat
                xSchedule."Trip Sequece" -= 1;
                xSchedule."Global Sequence" := Format(xSchedule."Trip No.") + Format(xSchedule."Trip Sequece");
                xSchedule.Modify();
            until xSchedule.Next() = 0;


    end;



}