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
                    ApplicationArea = All;
                }
                field(Suburb; Rec."Ship-to City")
                {
                    ApplicationArea = All;
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
            action("Move Up")
            {
                ApplicationArea = All;
                Caption = 'Move Up the schedule item', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = "1099Form";
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;
                begin
                    if Rec."Trip Sequece" <> 0 then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" - 1);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" += 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                    end;
                    Rec."Trip Sequece" -= 1;
                    Rec.Modify();
                    CurrPage.Update();
                end;
            }
            action("Move Down")
            {
                ApplicationArea = All;
                Caption = 'Move Down the schedule item', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;
                trigger OnAction()
                var
                    TempInt: Integer;
                    Schedule: Record Schedule;
                begin
                    if Rec."Trip Sequece" <> 0 then begin
                        Schedule.SetRange("Trip No.", Rec."Trip No.");
                        Schedule.SetRange("Trip Sequece", Rec."Trip Sequece" + 1);
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Trip Sequece" -= 1;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                    end;
                    Rec."Trip Sequece" += 1;
                    Rec.Modify();
                    CurrPage.Update();
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
        }
    }
}