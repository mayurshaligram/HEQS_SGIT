pageextension 50127 TransferOrderExt extends "Transfer Order"
{
    actions
    {
        modify("Re&lease")
        {
            trigger OnAfterAction();
            begin
                Testing()
            end;
        }
    }


    procedure Testing();
    var
        Schedule: Record Schedule;
        SalesLine: Record "Transfer Line";
        TempDeliveryItem: Text[2000];
    begin
        Schedule."Source Type" := Schedule."Source Type"::"Transfer Order";
        Schedule."Source No." := Rec."No.";
        Schedule."Subsidiary Source No." := 'Transfer Order';
        Schedule."Ship-to City" := Rec."Transfer-to Code";
        Schedule."Delivery Date" := Rec."Shipment Date";
        SalesLine.SetRange("Document No.", Rec."No.");
        if SalesLine.FindSet() then
            repeat
                if IsMainItemLine(SalesLine) then
                    if StrLen(TempDeliveryItem) < 1900 then
                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
            until SalesLine.Next() = 0;


        Schedule."To Location Code" := Rec."Transfer-to Code";
        Schedule."Delivery Items" := TempDeliveryItem;
        Schedule.Customer := Rec."Transfer-to City";
        Schedule.Remote := true;
        Schedule.Status := Schedule.Status::Norm;
        Schedule."From Location Code" := Rec."Transfer-from Code";
        Schedule.Insert(true);
    end;

    local procedure IsMainItemLine(SalesLine: Record "Transfer Line"): Boolean;
    var
        TempItem: Record Item;
    begin
        TempItem.Reset();
        if TempItem.Get(SalesLine."Item No.") = false then
            exit(false);
        TempItem.CalcFields("Assembly BOM");
        if TempItem."Assembly BOM" then
            exit(true);
    end;
}