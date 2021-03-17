tableextension 50110 "Warehouse Activity Header_Ext" extends "Warehouse Activity Header"
{
    // Need Description
    // Number of field not in the system requirement review

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
        field(22; "Sorting Field 1"; enum "Sorting Field")
        {
            Caption = 'Sorting Field 1';
            trigger OnValidate()
            begin
                if "Sorting Field 1" <> xRec."Sorting Field 1" then
                    SortingField;
            end;
        }
        field(23; "Sorting Field 2"; enum "Sorting Field")
        {
            Caption = 'Sorting Field 2';
            trigger OnValidate()
            begin
                if "Sorting Field 2" <> xRec."Sorting Field 2" then
                    SortingField;
            end;
        }
        field(24; "Sorting Field 3"; enum "Sorting Field")
        {
            Caption = 'Sorting Field 3';
            trigger OnValidate()
            begin
                if "Sorting Field 3" <> xRec."Sorting Field 3" then
                    SortingField;
            end;
        }

    }

    procedure SortingField()
    var
        WhseActivLine2: Record "Warehouse Activity Line";
        WhseActivLine3: Record "Warehouse Activity Line";
        SortingFieldList: List of [Enum "Sorting Field"];
        SortingFieldList2: List of [Enum "Sorting Field"];
        SequenceNo: Integer;
        IsHandled: Boolean;
        SortingFieldName: List of [Integer];
        TempEnum: Enum "Sorting Field";
        TempField1: FieldRef;
        TempText: Text;
        i: Integer;
        j: Integer;
    begin
        // Add
        SortingFieldList.Add("Sorting Field 1");
        SortingFieldList.Add("Sorting Field 2");
        SortingFieldList.Add("Sorting Field 3");
        // Remove Duplicate
        i := 1;
        j := 2;
        if SortingFieldList.Count >= 2 then
            repeat
            begin
                if SortingFieldList.Get(i) = SortingFieldList.Get(j) then
                    SortingFieldList.Remove(SortingFieldList.Get(j));
                i := i + 1;
                j := j + 1;
            end;
            until i >= SortingFieldList.Count;
        if SortingFieldList.Get(1) = SortingFieldList.Get(2) then
            SortingFieldList.RemoveAt(2);
        foreach TempEnum in SortingFieldlist do
            if (TempEnum = TempEnum::"Pick-up") or (TempEnum = TempEnum::Zone) or (TempEnum = TempEnum::Bin) then
                SortingFieldList2.add(TempEnum);
        SortingFieldList := SortingFieldList2;
        // foreach TempEnum in SortingFieldName do
        //     SortingFieldList2.Add(TempEnum);
        // Change to FieldName
        // foreach TempEnum in SortingFieldList do begin
        //     if TempEnum = TempEnum::"Pick-up" then
        //         SortingFieldName.Add(WhseActivLine2.FieldNo("Pick-up Item"));
        //     if TempEnum = TempEnum::Zone then
        //         SortingFieldName.Add(WhseActivLine2.FieldNo("Zone Code"));
        //     if TempEnum = TempEnum::Bin then
        //         SortingFieldName.Add(WhseActivLine2.FieldNo("Bin Code"));
        // end;
        // load to field


        IsHandled := false;
        if IsHandled then
            exit;
        WhseActivLine2.LockTable();
        WhseActivLine2.SetRange("Activity Type", Type);
        WhseActivLine2.SetRange("No.", "No.");

        if (SortingFieldList.Count = 3) then
            if (SortingFieldList.Get(1) = TempEnum::"Pick-up") and (SortingFieldList.Get(2) = TempEnum::Zone) and (SortingFieldList.Get(3) = TempEnum::Bin) then
                WhseActivLine2.SetCurrentKey("Pick-up Item", "Zone Code", "Bin Code")
            else
                if (SortingFieldList.Get(1) = TempEnum::"Pick-up") and (SortingFieldList.Get(3) = TempEnum::Zone) and (SortingFieldList.Get(2) = TempEnum::Bin) then
                    WhseActivLine2.SetCurrentKey("Pick-up Item", "Bin Code", "Zone Code")
                else
                    if (SortingFieldList.Get(2) = TempEnum::"Pick-up") and (SortingFieldList.Get(1) = TempEnum::Zone) and (SortingFieldList.Get(3) = TempEnum::Bin) then
                        WhseActivLine2.SetCurrentKey("Zone Code", "Pick-up Item", "Bin Code")
                    else
                        if (SortingFieldList.Get(3) = TempEnum::"Pick-up") and (SortingFieldList.Get(1) = TempEnum::Zone) and (SortingFieldList.Get(2) = TempEnum::Bin) then
                            WhseActivLine2.SetCurrentKey("Zone Code", "Bin Code", "Pick-up Item")
                        else
                            if (SortingFieldList.Get(3) = TempEnum::"Pick-up") and (SortingFieldList.Get(2) = TempEnum::Zone) and (SortingFieldList.Get(1) = TempEnum::Bin) then
                                WhseActivLine2.SetCurrentKey("Bin Code", "Zone Code", "Pick-up Item")
                            else
                                if (SortingFieldList.Get(2) = TempEnum::"Pick-up") and (SortingFieldList.Get(3) = TempEnum::Zone) and (SortingFieldList.Get(1) = TempEnum::Bin) then
                                    WhseActivLine2.SetCurrentKey("Bin Code", "Pick-up Item", "Zone Code");
        if (SortingFieldList.Count = 2) then
            if (SortingFieldList.Get(1) = TempEnum::"Pick-up") and (SortingFieldList.Get(2) = TempEnum::Zone) then
                WhseActivLine2.SetCurrentKey("Pick-up Item", "Zone Code")
            else
                if (SortingFieldList.Get(1) = TempEnum::"Pick-up") and (SortingFieldList.Get(2) = TempEnum::Bin) then
                    WhseActivLine2.SetCurrentKey("Pick-up Item", "Bin code")
                else
                    if (SortingFieldList.Get(1) = TempEnum::"Zone") and (SortingFieldList.Get(2) = TempEnum::"Pick-up") then
                        WhseActivLine2.SetCurrentKey("Zone Code", "Pick-up Item")
                    else
                        if (SortingFieldList.Get(1) = TempEnum::"Zone") and (SortingFieldList.Get(2) = TempEnum::"Bin") then
                            WhseActivLine2.SetCurrentKey("Zone Code", "Bin code")
                        else
                            if (SortingFieldList.Get(1) = TempEnum::"Bin") and (SortingFieldList.Get(2) = TempEnum::"Pick-up") then
                                WhseActivLine2.SetCurrentKey("Bin code", "Pick-up Item")
                            else
                                if (SortingFieldList.Get(1) = TempEnum::"Bin") and (SortingFieldList.Get(2) = TempEnum::"Zone") then
                                    WhseActivLine2.SetCurrentKey("Bin code", "Zone Code");
        if (SortingFieldList.Count = 1) then
            if (SortingFieldList.Get(1) = TempEnum::"Pick-up") then
                WhseActivLine2.SetCurrentKey("Pick-up Item")
            else
                if (SortingFieldList.Get(1) = TempEnum::Zone) then
                    WhseActivLine2.SetCurrentKey("Zone Code")
                else
                    if (SortingFieldList.Get(1) = TempEnum::Bin) then
                        WhseActivLine2.SetCurrentKey("Bin Code");

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
enum 50112 "Sorting Field"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; None) { Caption = ' '; }

    value(1; "Pick-up") { Caption = 'Pick-up'; }
    value(2; "Zone") { Caption = 'Zone'; }
    value(3; "Bin") { Caption = 'Bin'; }
}