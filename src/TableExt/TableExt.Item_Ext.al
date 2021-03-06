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
        field(50100; NSW; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Warehouse Entry".Quantity where("Location Code" = const('NSW'), "Item No." = field("No.")));
            DecimalPlaces = 0 : 5;
        }
        field(50103; VIC; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Warehouse Entry".Quantity where("Location Code" = const('VIC'), "Item No." = field("No.")));
            DecimalPlaces = 0 : 5;
        }
        field(50104; QLD; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Warehouse Entry".quantity where("Location Code" = const('QLD'), "Item No." = field("No.")));
            DecimalPlaces = 0 : 5;
        }
    }
    trigger OnBeforeModify()
    var
        IsValid: Boolean;
        user: Record User;
    begin
        user.Get(Database.UserSecurityId());
        if (User."Full Name" <> 'Karen Huang') and (User."Full Name" <> 'Pei Xu') and (User."Full Name" <> 'Stephen Lu') then begin
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
    var
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if (User."Full Name" <> 'Karen Huang') and (User."Full Name" <> 'Pei Xu') and (User."Full Name" <> 'Stephen Lu') then begin
            if Rec.CurrentCompany <> 'HEQS International Pty Ltd' then
                Error('Please only edit items in HEQS International Pty Ltd');
        end;
    end;

    trigger OnAfterInsert()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
        ItemUOM: Record "Item Unit of Measure";
        NewItemUOM: Record "Item Unit of Measure";
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
        TempCost: Decimal;
        TempPrice: Decimal;
        TempShelfNo: Code[10];
        TempStandardCost: Decimal;
        TempIndirectCost: Decimal;
        TempLastDirectCost: Decimal;
        TempItemDiscGroup: Code[20];
        TempVendorNO: Code[20];
        TempVendorItemNo: Code[20];

        ItemUOM: Record "Item Unit of Measure";
        NewItemUOM: Record "Item Unit of Measure";
        OriginalItemUOM: Record "Item Unit of Measure";
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        if RetailItemRecord.Get(Rec."No.") then begin
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

                            if Rec."Base Unit of Measure" <> xRec."Base Unit of Measure" then begin
                                ItemUOM.Reset();
                                ItemUOM.ChangeCompany(OtherCompanyRecord.Name);
                                ItemUOM.SetRange("Item No.", Rec."No.");
                                ItemUOM.SetRange(Code, Rec."Base Unit of Measure");
                                if ItemUOM.Count = 0 then begin
                                    if OriginalItemUOM.Get(Rec."No.", Rec."Base Unit of Measure") then begin
                                        ItemUOM := OriginalItemUOM;
                                        ItemUOM.Insert();
                                    end;
                                end;
                            end;
                        end;
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;

    trigger OnAfterRename()
    var
        TempText: Text;
        RetailItemRecord: Record Item;
        OtherCompanyRecord: Record Company;
        TempCost: Decimal;
        TempPrice: Decimal;
        TempShelfNo: Code[10];
        TempStandardCost: Decimal;
        TempIndirectCost: Decimal;
        TempLastDirectCost: Decimal;
        TempItemDiscGroup: Code[20];
        TempVendorNO: Code[20];
        TempVendorItemNo: Code[20];

        ItemUOM: Record "Item Unit of Measure";
        NewItemUOM: Record "Item Unit of Measure";
        OriginalItemUOM: Record "Item Unit of Measure";
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        RetailItemRecord.ChangeCompany(OtherCompanyRecord.Name);
                        if RetailItemRecord.Get(xRec."No.") then
                            RetailItemRecord.Rename(Rec."No.");
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