codeunit 50116 WhseRequestMgt
{
    procedure ValidateWhseRequest(SalesHeader: Record "Sales Header");
    var
        WhseRequest: Record "Warehouse Request";
        NewWhseRequest: Record "Warehouse Request";
    begin
        WhseRequest.Reset();
        WhseRequest.SetRange("Source No.", SalesHeader."No.");
        if WhseRequest.FindSet() then begin
            if WhseRequest."Location Code" <> SalesHeader."Location Code" then begin
                NewWhseRequest.Reset();
                NewWhseRequest := WhseRequest;
                NewWhseRequest."Location Code" := SalesHeader."Location Code";
                WhseRequest.Delete();
                Database.Commit();
                NewWhseRequest.Insert();
                Database.Commit();
            end
        end;
    end;
}