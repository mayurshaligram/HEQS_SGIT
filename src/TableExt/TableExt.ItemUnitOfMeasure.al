tableextension 50119 ItemUOMExt extends "Item Unit of Measure"
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

    trigger OnAfterInsert();
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        Item.Reset();
                        Item.ChangeCompany(OtherCompanyRecord.Name);
                        if Item.Get(Rec."Item No.") then begin
                            ItemUOM.Reset();
                            ItemUOM.ChangeCompany(OtherCompanyRecord.Name);
                            if ItemUOM.Get(Rec."Item No.", Rec.Code) = false then begin
                                ItemUOM := Rec;
                                ItemUOM.Insert();
                            end;
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

    trigger OnAfterModify();
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        Item.Reset();
                        Item.ChangeCompany(OtherCompanyRecord.Name);
                        if Item.Get(Rec."Item No.") then begin
                            ItemUOM.Reset();
                            ItemUOM.ChangeCompany(OtherCompanyRecord.Name);
                            if ItemUOM.Get(Rec."Item No.", Rec.Code) = true then begin
                                ItemUOM := Rec;
                                ItemUOM.Modify();
                            end
                            else begin
                                ItemUOM := Rec;
                                ItemUOM.Insert();
                            end;
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

    trigger OnAfterDelete();
    var
        ItemUOM: Record "Item Unit of Measure";
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        ItemUOM.Reset();
                        ItemUOM.ChangeCompany(OtherCompanyRecord.Name);
                        if ItemUOM.Get(Rec."Item No.", Rec.Code) = true then begin
                            ItemUOM.Delete();
                        end;
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;




}