page 50105 "DevPage"
{
    Caption = 'DevPage';
    Editable = true;
    PageType = List;
    SourceTable = Driver;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'DevPage';
    Permissions = TableData 7312 = rimd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Password; Password)
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    var
                        WarehouseJournal: Record "Warehouse Journal Line";
                        WarehouseEntry: Record "Warehouse Entry";
                        InputWindow: Dialog;
                    begin
                        if Password = Correct then begin
                            Message('Password Correct.');
                            // Delete all the WarehouseEntry in the Batch NSWWIJ
                            WarehouseEntry.Reset();
                            WarehouseJournal.Reset();
                            // WarehouseJournal.SetRange(Quantity, 0);
                            if WarehouseEntry.FindSet() then
                                repeat
                                    WarehouseEntry.Delete();
                                until WarehouseEntry.Next() = 0;
                            if WarehouseJournal.FindSet() then
                                repeat
                                    WarehouseJournal.Delete();
                                until WarehouseJournal.Next() = 0;
                            DeletePilloW();
                        end

                        else
                            if Password = LineFixPassword then begin
                                Message('This for line discount fix');
                                LineFix();
                                Message('This for delete item 7030003 and 7030013');
                                DeleteItem();
                            end;
                        if Password = ExternalMovingPassword then
                            ExternalMoving();
                    end;

                }
            }
        }

    }
    var
        Password: Code[20];
        Correct: Code[20];
        LineFixPassword: Code[20];
        ExternalMovingPassword: Code[20];

    trigger OnOpenPage();
    begin
        Correct := 'asfgsfga';
        LineFixPassword := '3ttq43asfg';
        ExternalMovingPassword := '326690';
    end;

    local procedure DeletePilloW();
    var
        BOMComponent: Record "BOM Component";
        Item: Record Item;
    begin
        // Delete the item pillow in all the original trading company
        BOMComponent.Reset();
        BOMComponent.SetRange("No.", '7050012');
        if BOMComponent.FindSet() then
            repeat
                BOMComponent.Delete()
            until BOMComponent.Next() = 0;

        if Item.Get(7050012) then
            Item.Delete();
    end;

    local procedure DeleteItem();
    var
        BOMComponent: Record "BOM Component";
        Item: Record Item;
    begin
        // Delete the item pillow in all the original trading company
        BOMComponent.Reset();
        BOMComponent.SetRange("No.", '7030003');
        if BOMComponent.FindSet() then
            repeat
                BOMComponent.Delete()
            until BOMComponent.Next() = 0;

        if Item.Get(7030003) then
            Item.Delete();

        BOMComponent.Reset();
        BOMComponent.SetRange("No.", '7030013');
        if BOMComponent.FindSet() then
            repeat
                BOMComponent.Delete()
            until BOMComponent.Next() = 0;

        if Item.Get(7030013) then
            Item.Delete();
    end;

    local procedure LineFix();
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, 'FSO101007');
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", 'FSO101007');
        SalesLIne.SetRange("No.", '7020009');
        if SalesLine.FindSet() then begin
            SalesLine."Line Discount %" := 0;
            SalesLine.Modify();
        end;
    end;

    local procedure ExternalMoving();
    var
        SalesHeader: Record "Sales Header";
        TempText: Text;
        OtherCompanyRecord: Record Company;
    begin
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
            OtherCompanyRecord.Reset();
            if OtherCompanyRecord.Find('-') then
                repeat
                    if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
                        SalesHeader.ChangeCompany(OtherCompanyRecord.Name);
                        if SalesHeader.FindSet() then
                            repeat
                                if SalesHeader."External Document No." <> '' then begin
                                    SalesHeader."Your Reference" := SalesHeader."External Document No.";
                                    SalesHeader."External Document No." := '';
                                    SalesHeader.Modify();
                                end;
                            until SalesHeader.Next() = 0;
                    end;
                until OtherCompanyRecord.Next() = 0;
        end;
    end;
}

