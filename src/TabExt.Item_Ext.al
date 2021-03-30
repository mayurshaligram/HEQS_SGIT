tableextension 50102 "Item_Ext" extends "Item"
{

    fields
    {
        field(50101; "Unit Assembly Hr"; Decimal)
        {

        }
    }
    trigger OnBeforeModify()
    var
        IsValid: Boolean;
    begin
        IsValid := false;
        if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then begin
            if (Rec.Type = Rec.Type::Inventory) and (Rec."Unit Cost" <> xRec."Unit Cost") then
                IsValid := true;

            if Rec.Type = Rec.Type::Service then
                IsValid := true;

            if IsValid = false then
                Error('Please only creat new service item in Retail, for other type item please go to HEQS International.');
        end;
    end;

    // trigger OnBeforeModify()
    // var
    //     Temp: Text;
    // begin
    //     if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
    //         if (xRec."Unit Price" <> Rec."Unit Price") or (xRec."Unit Cost" <> Rec."Unit Cost") then
    //             Temp := '1'
    //         else
    //             Error('Please only edit items Unit Price in Retail');
    // end;

    trigger OnBeforeDelete()
    begin
        if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
            Error('Please only edit items in HEQS International Pty Ltd');
    end;

    trigger OnAfterInsert()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        RetailItemRecord := Rec;
                        RetailItemRecord.Insert();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;

    trigger OnAfterModify()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
        TempCost: Integer;
        TempPrice: Integer;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        RetailItemRecord.Get(Rec."No.");
                        TempCost := RetailItemRecord."Unit Cost";
                        TempPrice := RetailItemRecord."Unit Price";
                        RetailItemRecord := Rec;
                        RetailItemRecord."Unit Cost" := TempCost;
                        RetailItemRecord."Unit Price" := TempPrice;
                        RetailItemRecord.Modify();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;

    trigger OnAfterDelete()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        RetailItemRecord.Get(Rec."No.");
                        RetailItemRecord := Rec;
                        RetailItemRecord.Delete();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}