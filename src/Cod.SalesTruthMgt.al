codeunit 50101 "Sales Truth Mgt"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, 36, 'OnCreatePurchaseOrder', '', false, false)]
    local procedure CreatePurchaseOrder(var SalesHeader: Record "Sales Header");
    var
        InventoryCompanyName: Text;
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        ToPORecord: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        InventoryCompanyName := 'HEQS International Pty Ltd';
        if SalesHeader.CurrentCompany <> InventoryCompanyName then begin
            PurchPaySetup.Get('');
            NoSeriesCode := PurchPaySetup."Order Nos.";
            NoSeries.Get(NoSeriesCode);
            NoSeriesLine.SetRange("Series Code", NoSeries.Code);

            if NoSeriesLine.FindSet() = false then
                Error('Please Create No series line');
            begin
                ToPORecord.Init();
                // Message('The purchase Order %1', ToPORecord."No.");
                ToPORecord."Document Type" := SalesHeader."Document Type";
                ToPORecord."No." := NoSeriesMgt.DoGetNextNo(NoSeries.Code, System.Today(), true, true);
                ToPORecord."Sales Order Ref" := SalesHeader."No.";
                InventoryCompanyName := 'HEQS INTERNATIONAL PTY LTD';
                Vendor."Search Name" := InventoryCompanyName;
                Vendor.FindSet();
                ToPORecord."Buy-from Vendor No." := Vendor."No.";
                ToPORecord."Buy-from Vendor Name" := Vendor.Name;
                ToPORecord.Insert();
                SalesHeader.UpdatePurchaseHeader(ToPORecord);
                SalesHeader."Automate Purch.Doc No." := ToPORecord."No.";
                SalesHeader.Modify();
            end;
        end
    end;


}