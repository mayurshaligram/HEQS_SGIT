tableextension 50111 BOMComponentExt extends "BOM Component"
{
    trigger OnBeforeInsert();
    var
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if (User."Full Name" <> 'Karen Huang') and (User."Full Name" <> 'Pei Xu') then begin
            if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
                Error('Please only edit items in HEQS International Pty Ltd');
        end;
    end;

    trigger OnAfterInsert()
    var
        TempText: Text;
        RetailBOMComponent: Record "BOM Component";
        LastRetailBomComponent: Record "BOM Component";
        OtherCompanyRecord: Record Company;
        TempLine: Integer;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailBOMComponent.Reset();
                        RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
                        if RetailBOMComponent.Get(Rec."Parent Item No.", Rec."Line No.") = false then begin
                            RetailBOMComponent := Rec;
                            RetailBOMComponent.Insert();
                        end;
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;

    trigger OnBeforeModify();
    var
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if (User."Full Name" <> 'Karen Huang') and (User."Full Name" <> 'Pei Xu') then begin
            if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
                Error('Please only edit items in HEQS International Pty Ltd');
        end;
    end;


    trigger OnAfterModify()
    var
        TempText: Text;
        RetailBOMComponent: Record "BOM Component";
        LastRetailBomComponent: Record "BOM Component";
        OtherCompanyRecord: Record Company;
        TempLine: Integer;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        LastRetailBomComponent.ChangeCompany(OtherCompanyRecord.Name);
                        LastRetailBomComponent.FindLast();
                        RetailBOMComponent.Reset();
                        RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
                        if RetailBOMComponent.Get(Rec."Parent Item No.", "Line No.") then begin
                            RetailBOMComponent := Rec;
                            RetailBOMComponent.Modify();
                        end;
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;

    trigger OnBeforeDelete();
    var
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if (User."Full Name" <> 'Karen Huang') and (User."Full Name" <> 'Pei Xu') then begin
            if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
                Error('Please only edit items in HEQS International Pty Ltd');
        end;
    end;

    trigger OnAfterDelete()
    var
        TempText: Text;
        RetailBOMComponent: Record "BOM Component";
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailBOMComponent.Reset();
                        RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
                        if RetailBOMComponent.Get(Rec."Parent Item No.", Rec."Line No.") = true then
                            RetailBOMComponent.Delete();
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}