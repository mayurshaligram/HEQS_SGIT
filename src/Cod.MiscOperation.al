// For Used for Web Service providing information for Power Apps

codeunit 50100 "MiscOperations"
{

    Procedure ReduceToHandle(myType: Text; myNo: Text; Line: Text): Text
    begin

        exit(myType + MyNo + Line);
    end;

    procedure PingPong(): Text
    begin
        exit('Pong');
    end;

    procedure Ping(inputJson: Text): Text
    var
        input: JsonObject;
    begin
        input.ReadFrom(inputJson);
        exit('Man is here to take');
    end;

    procedure Delay(delayMilliseconds: Integer)
    begin
        Sleep(delayMilliseconds);
    end;

    procedure GetLengthOfStringWithConfirmation(inputJson: Text): Text
    var
        MyPickLine: Record "Warehouse Activity Line";
        c: JsonToken;
        input: JsonObject;
        MyText: Text;
        TempInt: Text;
    begin
        MyPickLine.ChangeCompany('HEQS International Pty Ltd');
        input.ReadFrom(inputJson);
        if input.Get('confirm', c) and c.AsValue().AsBoolean() = true and input.Get('str', c) then begin
            input.Get('Type', c);
            if c.AsValue().AsText() = 'Pick' then
                MyPickLine."Activity Type" := MyPickLine."Activity Type"::Pick;
            input.Get('No', c);
            MyPickLine."No." := c.AsValue().AsText();
            input.Get('Line', c);
            Evaluate(MyPickLine."Line No.", c.AsValue().AsText());
            input.Get('Amount', c);
            MyPickLine.SetCurrentKey("Activity Type", "No.", "Line No.");
            if MyPickLine.Find() then begin
                MyPickLine."Qty. Handled" := MyPickLine."Qty. Handled" + c.AsValue().AsInteger();
                MyPickLine.Modify();
            end;
            exit('Success full Picked ' + c.AsValue().AsText() + ', ');
        end
        else
            exit('-1');
    end;

    procedure GetItemsDescriptionWithConfirmation(inputJson: Text): Text
    var
        MyItem: Record Item;
        c: JsonToken;
        input: JsonObject;
    begin
        MyItem.ChangeCompany('HEQS International Pty Ltd');
        input.ReadFrom(inputJson);
        if input.Get('confirm', c) and c.AsValue().AsBoolean() = true and input.Get('str', c) then begin
            input.Get('No', c);
            MyItem."No." := c.AsValue().AsText();
            MyItem.Get(MyItem."No.");
            exit(MyItem.Description);
        end
        else
            exit('Bad');
    end;

    procedure Post(inputJson: Text): Text
    var
        WarehousePickPage: Page "My Warehouse Pick";
        // MyPage: Page "Whse. Pick Subform";
        MyPick: Record "Warehouse Activity Header";
        WhseActivLine: Record "Warehouse Activity Line";
        WPSubform: Page "My Whse. Pick Subform";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        c: JsonToken;
        input: JsonObject;
    begin
        MyPick.ChangeCompany('HEQS International Pty Ltd');
        input.ReadFrom(inputJson);
        if input.Get('confirm', c) and c.AsValue().AsBoolean() = true and input.Get('str', c) then begin
            input.Get('No', c);
            MyPick."No." := c.AsValue().AsText();
            WhseActivLine."No." := MyPick."NO.";
            WhseActivLine."Activity Type" := WhseActivLine."Activity Type"::Pick;
            WPSubform.SetRecord(WhseActivLine);
            if WhseActivLine.Findset() then
                // repeat
                    WPSubform.RegisterActivityYesNo();
            // until WhseActivLine.Next() = 0;
        end;
        exit('Good');
    end;

    procedure Post2(inputJson: Text): Text
    var
        WarehousePickPage: Page "My Warehouse Pick";
        // MyPage: Page "Whse. Pick Subform";
        MyPick: Record "Warehouse Activity Header";
        WhseActivLine: Record "Warehouse Activity Line";
        WPSubform: Page "My Whse. Pick Subform";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        c: JsonToken;
        input: JsonObject;
    begin
        MyPick.ChangeCompany('HEQS International Pty Ltd');
        input.ReadFrom(inputJson);
        if input.Get('confirm', c) and c.AsValue().AsBoolean() = true and input.Get('str', c) then begin
            input.Get('No', c);
            MyPick."No." := c.AsValue().AsText();
            WhseActivLine."No." := MyPick."NO.";
            WhseActivLine."Activity Type" := WhseActivLine."Activity Type"::Pick;
            WPSubform.SetRecord(WhseActivLine);
            if WhseActivLine.Findset() then
                // repeat
                    WPSubform.RegisterActivityYesNo();
            // until WhseActivLine.Next() = 0;
        end;
        exit('Good');
    end;

}