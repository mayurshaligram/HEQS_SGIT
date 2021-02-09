tableextension 50110 "Warehouse Activity Header_Ext" extends "Warehouse Activity Header"
{
    Caption = 'Warehouse Activity Header_Ext';
    fields
    {
        field(21; "New Sorting Method"; Enum "Before Whse. Activity Sorting Method")
        {
            Caption = 'New Sorting Method';

            trigger OnValidate()
            begin
                if "New Sorting Method" <> xRec."New Sorting Method" then
                    NewSortWhseDoc;
            end;
        }
    }

    procedure NewSortWhseDoc()
    var
        WhseActivLine2: Record "Warehouse Activity Line";
        WhseActivLine3: Record "Warehouse Activity Line";
        SequenceNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        WhseActivLine2.LockTable();
        WhseActivLine2.SetRange("Activity Type", Type);
        WhseActivLine2.SetRange("No.", "No.");
        case "New Sorting Method" of
            "New Sorting Method"::Item:
                WhseActivLine2.SetCurrentKey("Activity Type", "No.", "Item No.");
            "New Sorting Method"::Document:
                WhseActivLine2.SetCurrentKey("Activity Type", "No.", "Location Code", "Source Document", "Source No.");
            "New Sorting Method"::"Shelf or Bin":
                SortWhseDocByShelfOrBin(WhseActivLine2, SequenceNo);
            "New Sorting Method"::"Due Date":
                WhseActivLine2.SetCurrentKey("Activity Type", "No.", "Due Date");
            "New Sorting Method"::"Ship-To":
                WhseActivLine2.SetCurrentKey(
                  "Activity Type", "No.", "Destination Type", "Destination No.");
            "New Sorting Method"::"Bin Ranking":
                SortWhseDocByBinRanking(WhseActivLine2, SequenceNo);
            "New Sorting Method"::"Action Type":
                SortWhseDocByActionType(WhseActivLine2, SequenceNo);
            "New Sorting Method"::"Pick-up Zone Bin":
                begin
                    WhseActivLine2.SetCurrentKey("Pick-up Item", "Zone Code", "Bin Code", "Item No.");
                    WhseActivLine2.SetAscending("Pick-up Item", false);
                end
        end;

        if SequenceNo = 0 then begin
            WhseActivLine2.SetRange("Breakbulk No.", 0);
            if WhseActivLine2.Find('-') then begin
                SequenceNo := 10000;
                repeat
                    SetActivityFilter(WhseActivLine2, WhseActivLine3);
                    if WhseActivLine3.Find('-') then
                        repeat
                            WhseActivLine3."Sorting Sequence No." := SequenceNo;
                            WhseActivLine3.Modify();
                            SequenceNo := SequenceNo + 10000;
                        until WhseActivLine3.Next = 0;

                    WhseActivLine2."Sorting Sequence No." := SequenceNo;
                    WhseActivLine2.Modify();
                    SequenceNo := SequenceNo + 10000;
                until WhseActivLine2.Next = 0;
            end;
        end;
    end;

    local procedure SortWhseDocByBinRanking(var WhseActivLine2: Record "Warehouse Activity Line"; var SequenceNo: Integer)
    var
        WhseActivLine3: Record "Warehouse Activity Line";
        BreakBulkWhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine2.SetCurrentKey("Activity Type", "No.", "Bin Ranking");
        WhseActivLine2.SetRange("Breakbulk No.", 0);
        if WhseActivLine2.Find('-') then begin
            SequenceNo := 10000;
            WhseActivLine2.SetRange("Action Type", WhseActivLine2."Action Type"::Take);
            if WhseActivLine2.Find('-') then
                repeat
                    SetActivityFilter(WhseActivLine2, WhseActivLine3);
                    if WhseActivLine3.Find('-') then
                        repeat
                            WhseActivLine3."Sorting Sequence No." := SequenceNo;
                            WhseActivLine3.Modify();
                            SequenceNo := SequenceNo + 10000;
                            BreakBulkWhseActivLine.Copy(WhseActivLine3);
                            BreakBulkWhseActivLine.SetRange("Action Type", WhseActivLine3."Action Type"::Place);
                            BreakBulkWhseActivLine.SetRange("Breakbulk No.", WhseActivLine3."Breakbulk No.");
                            if BreakBulkWhseActivLine.Find('-') then
                                repeat
                                    BreakBulkWhseActivLine."Sorting Sequence No." := SequenceNo;
                                    BreakBulkWhseActivLine.Modify();
                                    SequenceNo := SequenceNo + 10000;
                                until BreakBulkWhseActivLine.Next = 0;
                        until WhseActivLine3.Next = 0;
                    WhseActivLine2."Sorting Sequence No." := SequenceNo;
                    WhseActivLine2.Modify();
                    SequenceNo := SequenceNo + 10000;
                until WhseActivLine2.Next = 0;
            WhseActivLine2.SetRange("Action Type", WhseActivLine2."Action Type"::Place);
            WhseActivLine2.SetRange("Breakbulk No.", 0);
            if WhseActivLine2.Find('-') then
                repeat
                    WhseActivLine2."Sorting Sequence No." := SequenceNo;
                    WhseActivLine2.Modify();
                    SequenceNo := SequenceNo + 10000;
                until WhseActivLine2.Next = 0;
        end;
    end;

    local procedure SortWhseDocByActionType(var WhseActivLine2: Record "Warehouse Activity Line"; var SequenceNo: Integer)
    var
        WhseActivLine3: Record "Warehouse Activity Line";
    begin
        WhseActivLine2.SetCurrentKey("Activity Type", "No.", "Action Type", "Bin Code");
        WhseActivLine2.SetRange("Action Type", WhseActivLine2."Action Type"::Take);
        if WhseActivLine2.Find('-') then begin
            SequenceNo := 10000;
            repeat
                WhseActivLine2."Sorting Sequence No." := SequenceNo;
                WhseActivLine2.Modify();
                SequenceNo := SequenceNo + 10000;
                if WhseActivLine2."Breakbulk No." <> 0 then begin
                    WhseActivLine3.Copy(WhseActivLine2);
                    WhseActivLine3.SetRange("Action Type", WhseActivLine2."Action Type"::Place);
                    WhseActivLine3.SetRange("Breakbulk No.", WhseActivLine2."Breakbulk No.");
                    if WhseActivLine3.Find('-') then
                        repeat
                            WhseActivLine3."Sorting Sequence No." := SequenceNo;
                            WhseActivLine3.Modify();
                            SequenceNo := SequenceNo + 10000;
                        until WhseActivLine3.Next = 0;
                end;
            until WhseActivLine2.Next = 0;
        end;
        WhseActivLine2.SetRange("Action Type", WhseActivLine2."Action Type"::Place);
        WhseActivLine2.SetRange("Breakbulk No.", 0);
        if WhseActivLine2.Find('-') then
            repeat
                WhseActivLine2."Sorting Sequence No." := SequenceNo;
                WhseActivLine2.Modify();
                SequenceNo := SequenceNo + 10000;
            until WhseActivLine2.Next = 0;
    end;
}

enum 50111 "Before Whse. Activity Sorting Method"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; None) { Caption = ' '; }
    value(1; "Item") { Caption = 'Item'; }
    value(2; "Document") { Caption = 'Document'; }
    value(3; "Shelf or Bin") { Caption = 'Shelf or Bin'; }
    value(4; "Due Date") { Caption = 'Due Date'; }
    value(5; "Ship-To") { Caption = 'Ship-To'; }
    value(6; "Bin Ranking") { Caption = 'Bin Ranking'; }
    value(7; "Action Type") { Caption = 'Action Type'; }
    value(8; "Pick-up Zone Bin") { Caption = 'Pick-up Zone Bin'; }
}