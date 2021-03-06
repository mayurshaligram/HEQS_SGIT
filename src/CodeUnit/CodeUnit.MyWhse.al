// ??
codeunit 50102 "My Whse"
{
    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        WhseActivLine.Copy(Rec);
        Code;
        Rec.Copy(WhseActivLine);
    end;

    var
        Text001: Label 'Do you want to register the %1 Document?';
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "myWhse.-Activity-Register";
        WMSMgt: Codeunit "WMS Management";
        Text002: Label 'The document %1 is not supported.';

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCode(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        // with WhseActivLine do begin
        CheckSourceDocument();

        WMSMgt.CheckBalanceQtyToHandle(WhseActivLine);

        // if not Confirm(Text001, false, "Activity Type") then
        //     exit;

        IsHandled := false;
        OnBeforeRegisterRun(WhseActivLine, IsHandled);
        if not IsHandled then
            WhseActivityRegister.Run(WhseActivLine);
        Clear(WhseActivityRegister);
        // end;

        OnAfterCode(WhseActivLine);
    end;

    local procedure CheckSourceDocument()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSourceDocument(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        // with WhseActivLine do
        if (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement") and
           not (WhseActivLine."Source Document" in [WhseActivLine."Source Document"::" ",
                                      WhseActivLine."Source Document"::"Prod. Consumption",
                                      WhseActivLine."Source Document"::"Assembly Consumption"])
        then
            Error(Text002, WhseActivLine."Source Document");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSourceDocument(WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterRun(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;
}

