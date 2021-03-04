tableextension 50102 "Item_Ext" extends "Item"
{
    trigger OnBeforeInsert()
    begin
        if Rec.CurrentCompany <> 'Test Company' then
            Error('Please only edit items in Test Company');
    end;

    // trigger OnBeforeModify()
    // var
    //     Temp: Text;
    // begin
    //     if Rec.CurrentCompany <> 'Test Company' then
    //         if (xRec."Unit Price" <> Rec."Unit Price") or (xRec."Unit Cost" <> Rec."Unit Cost") then
    //             Temp := '1'
    //         else
    //             Error('Please only edit items Unit Price in Retail');
    // end;

    trigger OnBeforeDelete()
    begin
        if Rec.CurrentCompany <> 'Test Company' then
            Error('Please only edit items in Test Company');
    end;

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

    // trigger OnAfterModify()
    // var
    //     TempText: Text;
    //     RetailItemRecord: Record Item;
    //     OtherCompanyRecord: Record Company;
    //     TempCost: Integer;
    //     TempPrice: Integer;
    // begin
    //     if Rec.CurrentCompany = 'Test Company' then begin
    //         OtherCompanyRecord.Reset();
    //         if OtherCompanyRecord.Find('-') then
    //             repeat
    //                 if ('Test Company' <> OtherCompanyRecord.Name) then begin
    //                     RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
    //                     RetailItemRecord.Get(Rec."No.");
    //                     TempCost := RetailItemRecord."Unit Cost";
    //                     TempPrice := RetailItemRecord."Unit Price";
    //                     RetailItemRecord := Rec;
    //                     RetailItemRecord."Unit Cost" := TempCost;
    //                     RetailItemRecord."Unit Price" := TempPrice;
    //                     RetailItemRecord.Modify();
    //                 end;
    //             until OtherCompanyRecord.Next() = 0;
    //     end;
    // end;

    trigger OnAfterDelete()
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
                        RetailItemRecord.Get(Rec."No.");
                        RetailItemRecord := Rec;
                        RetailItemRecord.Delete();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}