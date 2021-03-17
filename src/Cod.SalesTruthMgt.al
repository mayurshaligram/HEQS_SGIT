codeunit 50101 "Sales Truth Mgt"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, 36, 'OnCreatePurchaseOrder', '', false, false)]
    local procedure CreatePurchaseOrder();
    var
        IsConsent: Boolean;
        Text1: Label 'FAKEPO0000010';
    begin


        IsConsent := Confirm('Create a Associated Purchase Order?');
        if IsConsent then
            Message('Purchase Order %1 has been created', Text1);
    end;
}