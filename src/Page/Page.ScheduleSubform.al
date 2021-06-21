page 50117 "Schedule Subform"
{
    Caption = 'Schedule';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Schedule";
    SourceTableView = sorting("Trip Sequece") order(ascending);
    RefreshOnActivate = true;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Source No."; Rec."Source No.")
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;
                    Visible = false;
                    StyleExpr = TempStr;
                }
                field("Subsidiary Source No."; Rec."Subsidiary Source No.")
                {
                    Caption = 'Original No.';
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
                field("Trip No."; Rec."Trip No.")
                {
                    Caption = 'Trip';
                    ApplicationArea = All;
                    StyleExpr = TempStr;
                }
                field(Remote; Rec.Remote)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Trip Sequece"; Rec."Trip Sequece")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No."; Rec."No.")
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
            action("Move Top")
            {
                ApplicationArea = All;
                Caption = 'Move Top';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UnlimitedCredit;
                ShortcutKey = 'Shift+Ctrl+T';
                ToolTip = 'Short Cut Shift+Ctrl+T';
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;
                begin
                    if Rec."Trip Sequece" > 0 then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", 0, Rec."Trip Sequece" - 1);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" += 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                        Rec."Trip Sequece" := 0;
                        Rec.Modify();
                        CurrPage.Update();
                    end;

                end;
            }
            action("Move Up")
            {
                ApplicationArea = All;
                Caption = 'Up', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = MoveUp;
                ShortcutKey = 'Shift+Ctrl+U';
                ToolTip = 'Shortcut Shift+Ctrl+U';
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;
                begin
                    if Rec."Trip Sequece" > 0 then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" - 1);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" += 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                        Rec."Trip Sequece" -= 1;
                        Rec.Modify();
                        CurrPage.Update();
                    end;

                end;
            }
            action("Move Down")
            {
                ApplicationArea = All;
                Caption = 'Down', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = MoveDown;
                ShortcutKey = 'Shift+Ctrl+D';
                ToolTip = 'Shortcut Shift+Ctrl+D';
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;

                    MaxInt: Integer;
                    MaxSchedule: Record Schedule;
                begin
                    MaxSchedule.SetCurrentKey("Trip Sequece");
                    MaxSchedule.SetAscending("Trip Sequece", false);
                    MaxSchedule.SetRange("Trip No.", Rec."Trip No.");
                    if MaxSchedule.FindSet() then
                        MaxInt := MaxSchedule."Trip Sequece";
                    if Rec."Trip Sequece" < MaxInt then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" + 1);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" -= 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                        Rec."Trip Sequece" += 1;
                        Rec.Modify();
                        CurrPage.Update();
                    end;

                end;
            }
            action("Move Bottom")
            {
                ApplicationArea = All;
                Caption = 'Bottom';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Bins;
                ShortcutKey = 'Shift+Ctrl+B';
                ToolTip = 'Shortcut Shift+Ctrl+B';
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;

                    MaxInt: Integer;
                    MaxSchedule: Record Schedule;
                begin
                    MaxSchedule.SetCurrentKey("Trip Sequece");
                    MaxSchedule.SetAscending("Trip Sequece", false);
                    MaxSchedule.SetRange("Trip No.", Rec."Trip No.");
                    if MaxSchedule.FindSet() then
                        MaxInt := MaxSchedule."Trip Sequece";
                    if Rec."Trip Sequece" < MaxInt then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" + 1, MaxInt);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" -= 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                        Rec."Trip Sequece" += MaxInt;
                        Rec.Modify();
                        CurrPage.Update();
                    end;
                end;

            }
            action("Add Schedule Item")
            {
                ApplicationArea = All;
                Caption = 'Add Schedule Item';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = "8ball";

                trigger OnAction()
                var
                    Schedule: Record Schedule;
                    TempInt: Integer;

                    NSWPage: Page "Schedule List";
                    VICPage: page "VIC Schedule";
                    QLDPage: Page "QLD Schedule";

                    ConfirmStr: Text;
                    TempBool: Boolean;
                begin
                    Schedule.SetRange("Trip No.", Rec."Trip No.");
                    TempInt := Schedule.Count();
                    Schedule.Reset();
                    TempBool := true;
                    case Rec."From Location Code" of
                        'NSW':
                            begin
                                Schedule.Reset();
                                Schedule.SetFilter("Trip No.", '<>%1', Rec."Trip No.");
                                NSWPage.SetTableView(Schedule);
                                NSWPage.LookupMode(true);

                                if NSWPage.RunModal() = Action::LookupOK then begin
                                    Schedule.Reset();
                                    NSWPage.GetRecord(Schedule);
                                    Schedule.SetFilter("No.", NSWPage.GetSelectionFilter());
                                    if Schedule.FindSet() then
                                        repeat
                                            if Schedule."Trip No." <> '' then begin
                                                ConfirmStr := Schedule."Subsidiary Source No." + ' has already in Trip ' + Schedule."Trip No." + ' do you want to move it to the new trip?';
                                                TempBool := Confirm(ConfirmStr);
                                            end;
                                            if TempBool then begin
                                                Schedule."Trip No." := Rec."Trip No.";
                                                Schedule."Trip Sequece" := TempInt;
                                                Schedule.Modify();
                                                TempInt += 1;
                                            end;
                                        until Schedule.Next() = 0;
                                end;
                            end;
                        'VIC':
                            if Page.RunModal(Page::"VIC Schedule", Schedule) = Action::LookupOK then begin
                                Schedule."Trip No." := Rec."Trip No.";
                                Schedule."Trip Sequece" := TempInt;
                                Schedule.Modify()
                            end;
                        'QLD':
                            if Page.RunModal(Page::"QLD Schedule", Schedule) = Action::LookupOK then begin
                                Schedule."Trip No." := Rec."Trip No.";
                                Schedule."Trip Sequece" := TempInt;
                                Schedule.Modify();
                            end;
                    end;
                    CurrPage.Update();
                end;
            }
            action("Remove Schedule Item")
            {
                ApplicationArea = All;
                Caption = 'Remove Schedule Item';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = AboutNav;

                trigger OnAction()
                var
                    Schedule: Record Schedule;
                    Trip: Record Trip;
                    TempInt: Integer;
                begin

                    CurrPage.SetSelectionFilter(Schedule);
                    if Schedule.FindSet() then begin
                        Trip.Get(Schedule."Trip No.");
                        TempInt := 0;
                        repeat
                            Schedule."Trip No." := '';
                            Schedule."Trip Sequece" := 0;
                            Schedule.Modify(true);
                        until Schedule.Next() = 0;
                        Clear(Schedule);
                        Schedule.SetRange("Trip No.", Trip."No.");
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" := TempInt;
                                TempInt += 1;
                                Schedule.Modify(true);
                            until Schedule.Next() = 0;
                        CurrPage.Update();
                    end
                end;
            }
            action("Edit")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ConfidentialOverview;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Page.Run(Page::"Schedule Card", Rec);
                end;
            }
        }
    }
    var
        ScheduleColorMgt: Codeunit "Schedule Color Mgt1";
        TempStr: Text;

    trigger OnAfterGetRecord()
    begin
        // TempStr := 'Accent';
        TempStr := ScheduleColorMgt.ChangeColor(Rec);
    end;
}