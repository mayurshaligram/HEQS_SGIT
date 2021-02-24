tableextension 50102 "Item_Ext" extends "Item"
{
    Caption = 'Item_Ext';
    trigger OnAfterInsert()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'Test Company' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('Test Company' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        RetailItemRecord := Rec;
                        RetailItemRecord.Insert();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}