page 50117 "Schedule Subform"
{
    Caption = 'Schedule';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Schedule";
    SourceTableView = sorting("Trip Sequece") order(ascending);

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

                // NSWPage: Page "Schedule List";
                // VICPage: page "VIC Schedule";
                // QLDPage: Page "QLD Schedule";
                begin
                    Schedule.SetRange("Trip No.", Rec."Trip No.");
                    TempInt := Schedule.Count();
                    Schedule.Reset();
                    case Rec."From Location Code" of
                        'NSW':
                            if Page.RunModal(Page::"Schedule List", Schedule) = Action::LookupOK then begin
                                Schedule."Trip No." := Rec."Trip No.";
                                Schedule."Trip Sequece" := TempInt;
                                Schedule.Modify();
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
                begin
                    Rec."Trip No." := '';
                    Rec."Trip Sequece" := 0;
                    Rec.Modify();
                    CurrPage.Update();
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
        TempStr := ScheduleColorMgt.ChangeColor(Rec);
    end;
}