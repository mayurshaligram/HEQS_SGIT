pageextension 50111 "Warehouse Receipt Ext" extends "Warehouse Receipt"
{


    actions
    {
        modify("Post Receipt")
        {
            trigger OnAfterAction()
            var
                PutAway: Record "Warehouse Activity Header";
                PutAwayLine: Record "Warehouse Activity Line";
                Item: Record Item;
            begin
                PutAway.Reset();
                PutAway.SetRange(Type, PutAway.Type::"Put-away");
                PutAway.FindLast();
                //
                PutAwayLine.Reset();
                PutAwayLine.SetRange("Activity Type", PutAway.Type::"Put-away");
                PutAwayLine.SetRange("No.", PutAway."No.");
                if PutAwayLine.FindSet() then
                    repeat
                        if PutAwayLine."Unit of Measure Code" = '' then begin
                            Item.Get(PutAwayLine."Item No.");
                            PutAwayLine."Unit of Measure Code" := Item."Base Unit of Measure";
                            PutAwayLine.Modify();
                        end;
                    until PutAwayLine.Next() = 0;
            end;
        }
    }

    var
        myInt: Integer;
}