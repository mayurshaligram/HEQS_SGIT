tableextension 50102 "Item_Ext" extends "Item"
{

    fields
    {

        field(50101; "Unit Assembly Hr"; Decimal)
        {

        }

        field(50102; Token; Boolean)
        {
        }
        modify("Indirect Cost %")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Unit Cost")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Unit Price")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Shelf No.")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }

        modify("Standard Cost")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Last Direct Cost")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Item Disc. Group")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Vendor No.")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
        }
        modify("Vendor Item No.")
        {
            trigger OnBeforeValidate();
            begin
                Rec.Token := true;
                Rec.Modify();
            end;

            trigger OnAfterValidate();
            begin
                Rec.Token := false;
                Rec.Modify();
            end;
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

            if Rec.Token = true then begin
                IsValid := true;
            end;

            if IsValid = false then
                Error('Please only creat new service item in current trading company , for other type item creation or modification please go to HEQS International.');
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
        TempShelfNo: Code[10];
        TempStandardCost: Decimal;
        TempIndirectCost: Decimal;
        TempLastDirectCost: Decimal;
        TempItemDiscGroup: Code[20];
        TempVendorNO: Code[20];
        TempVendorItemNo: Code[20];
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        RetailItemRecord.Get(Rec."No.");
                        // AB#67
                        TempCost := RetailItemRecord."Unit Cost";
                        TempPrice := RetailItemRecord."Unit Price";
                        TempShelfNo := RetailItemRecord."Shelf No.";
                        TempStandardCost := RetailItemRecord."Standard Cost";
                        TempIndirectCost := RetailItemRecord."Indirect Cost %";
                        TempLastDirectCost := RetailItemRecord."Last Direct Cost";
                        TempItemDiscGroup := RetailItemRecord."Item Disc. Group";
                        TempVendorNO := RetailItemRecord."Vendor No.";
                        TempVendorItemNo := RetailItemRecord."Vendor Item No.";

                        RetailItemRecord := Rec;
                        RetailItemRecord."Unit Cost" := TempCost;
                        RetailItemRecord."Unit Price" := TempPrice;
                        RetailItemRecord."Shelf No." := TempShelfNo;
                        RetailItemRecord."Standard Cost" := TempStandardCost;
                        RetailItemRecord."Indirect Cost %" := TempIndirectCost;
                        RetailItemRecord."Last Direct Cost" := TempLastDirectCost;
                        RetailItemRecord."Item Disc. Group" := TempItemDiscGroup;
                        RetailItemRecord."Vendor Item No." := TempVendorNO;
                        RetailItemRecord."Vendor No." := TempVendorItemNo;
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
                        RetailItemRecord.Delete();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}