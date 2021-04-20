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

                        if Password = DeletePurchaseLinePassword then
                            if Dialog.Confirm('Delete PurchaseLine Password') then
                                DeletePurchaseLine();

                        if Password = TurnWarehouseRequestReleasePassword then
                            if Dialog.Confirm('Delete PurchaseLine Password') then
                                TurnWarehouseRequestRelease();

                        if Password = GiveBackExternalPassword then
                            if Dialog.Confirm('Give Back to external password') then
                                GiveBackExternal();
                        if Password = ReleaseWhseRequesPassword then
                            if Dialog.Confirm('Release Whse Request') then
                                ReleaseWhseRequest();
                        if Password = DeleteAllWhseShipmentLinePassword then
                            if Dialog.Confirm('Delete all whse shipment line') then
                                DeleteAllWhseShipmentLine();
                        if Password = QuickFixPassword then
                            if Dialog.Confirm('Quick Fix all the sales header') then
                                QuickFix();
                        if Password = ReleaseReOpenPassword then
                            if Dialog.Confirm('Release Reopen all the sales Header to fix BOM') then
                                ReleaseReOpen();
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
        DeletePurchaseLinePassword: Code[20];
        TurnWarehouseRequestReleasePassword: Code[20];

        SalesTruthMgt: Codeunit "Sales Truth Mgt";

        GiveBackExternalPassword: Code[20];
        ReleaseWhseRequesPassword: Code[20];

        DeleteAllWhseShipmentLinePassword: Code[20];
        QuickFixPassword: Code[20];
        ReleaseReOpenPassword: Code[20];

    trigger OnOpenPage();
    begin
        Correct := 'asfgsfga';
        LineFixPassword := '3ttq43asfg';
        ExternalMovingPassword := 'asfghy48sjahiw';
        DeletePurchaseLinePassword := 'jbcv2bjbvoi';
        TurnWarehouseRequestReleasePassword := 'adsf2tg';

        ReleaseWhseRequesPassword := 'heqs326689';
        DeleteAllWhseShipmentLinePassword := 'heqs326690';
        // International
        GiveBackExternalPassword := 'heqs326688';
        // Retail 
        ReleaseReOpenPassword := 'RO';
        // International
        QuickFixPassword := 'qqq';

    end;

    local procedure DeletePurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";

        PurchaseHeader: Record "Purchase Header";
    begin
        if Rec.CurrentCompany = 'HEQS Furniture Pty Ltd' then begin
            PurchaseLine.SetRange(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
            // PurchaseLine.SetRange(PurchaseLine."Document No.", 'FPO000012');

            if PurchaseLine.FindSet() then
                repeat
                    if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") = false then begin
                        PurchaseLine.Delete();
                        Message('PurchaseLine %1 %2 has been deleted', PurchaseLine."Document No.", PurchaseLine."Line No.");
                    end
                until PurchaseLine.Next() = 0;
        end;
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

    local procedure TurnWarehouseRequestRelease();
    var
        WhseRequest: Record "Warehouse Request";
    begin
        WhseRequest.Get(WhseRequest.Type::Outbound, 'NSW', 37, WhseRequest."Source Subtype"::"1", 'INT101029');
        WhseRequest."Document Status" := WhseRequest."Document Status"::Released;
        WhseRequest.Modify();
        RecreateTheSalesLine();
    end;

    local procedure RecreateTheSalesLine();
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        RetailPurchaseLine: Record "Purchase Line";
        RetailSalesHeader: Record "Sales Header";
        OtherSalesLine: Record "Sales Line";
        Item: Record Item;
    begin

        SalesLine.Reset();
        // SalesLine.SetRange("Document No.", 'INT101029');
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);

        OtherSalesLine.Reset();
        OtherSalesLine.SetRange("Document No.", 'INT101092');
        OtherSalesLine.FindSet();



        // SalesHeader.Status := SalesHeader.Status::Open;
        // SalesHeader.Modify();
        // SalesHeader.RecreateSalesLines(SalesHeader."No.");
        // SalesHeader.Status := SalesHeader.Status::Released;
        // SalesHeader.Modify();

        if SalesLine.FindSet() then
            repeat
                if (SalesLine."Unit of Measure Code" = '') or (SalesLine."Gen. Bus. Posting Group" = '') then begin
                    SalesHeader.Reset();
                    SalesHeader.Get(SalesHeader."Document Type"::Order, SalesLine."Document No.");
                    RetailPurchaseLine.Reset();
                    RetailPurchaseLine.ChangeCompany(SalesHeader."Sell-to Customer Name");
                    RetailSalesHeader.Reset();
                    RetailSalesHeader.ChangeCompany(SalesHeader."Sell-to Customer Name");
                    RetailSalesHeader.Get(RetailSalesHeader."Document Type"::Order, SalesHeader.RetailSalesHeader);
                    if RetailPurchaseLine.Get(SalesHeader."Document Type", RetailSalesHeader."Automate Purch.Doc No.", SalesLine."Line No.") then
                        SalesLine."Unit of Measure Code" := RetailPurchaseLine."Unit of Measure Code";
                    SalesLine."Gen. Bus. Posting Group" := RetailPurchaseLine."Gen. Bus. Posting Group";
                    SalesLine."Gen. Prod. Posting Group" := RetailPurchaseLine."Gen. Prod. Posting Group";
                    SalesLine.Modify();
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure GiveBackExternal();
    var
        SalesHeader: Record "Sales Header";
        RetailSalesHeader: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany() = SalesTruthMgt.InventoryCompany() then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            if SalesHeader.FindSet() then begin
                SalesHeader.Status := SalesHeader.Status::Open;
                SalesHeader.Modify();
                SalesTruthMgt.QuickFix(SalesHeader);
                SalesHeader.Status := SalesHeader.Status::Released;
                SalesHeader.Modify();
                repeat
                    if SalesHeader."External Document No." = '' then begin
                        RetailSalesHeader.Reset();
                        RetailSalesHeader.ChangeCompany(SalesHeader."Sell-to Customer Name");
                        if RetailSalesHeader.Get(SalesHeader."Document Type", SalesHeader.RetailSalesHeader) then
                            SalesHeader."External Document No." := RetailSalesHeader."Automate Purch.Doc No.";
                        SalesHeader.Modify();
                    end;
                until SalesHeader.Next() = 0;
            end

        end;

        DeleteAllWhseShipmentLine();
        ReleaseWhseRequest();

    end;

    local procedure ReleaseWhseRequest();
    var
        WhseRequest: Record "Warehouse Request";
    begin
        if WhseRequest.CurrentCompany() = SalesTruthMgt.InventoryCompany() then
            WhseRequest.Reset();
        if WhseRequest.FindSet() then
            repeat
                if WhseRequest."Document Status" = WhseRequest."Document Status"::Open then begin
                    WhseRequest."Document Status" := WhseRequest."Document Status"::Released;
                    WhseRequest.Modify();
                end;
            until WhseRequest.Next() = 0;
    end;

    local procedure DeleteAllWhseShipmentLine();
    var
        WhseShipment: Record "Warehouse Shipment Line";
    begin
        if WhseShipment.FindSet() then
            repeat
                WhseShipment.Delete();
            until WhseShipment.Next() = 0;
    end;

    local procedure QuickFix();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany() = SalesTruthMgt.InventoryCompany() then
            if SalesHeader.FindSet() then
                repeat
                    SalesHeader.Status := SalesHeader.Status::Open;
                    SalesHeader.Modify();
                    SalesTruthMgt.QuickFix(SalesHeader);
                    SalesHeader.Status := SalesHeader.Status::Released;
                    SalesHeader.Modify();
                until SalesHeader.Next() = 0;
    end;


    // To be improved
    local procedure ReleaseReOpen();
    var
        SalesHeader: Record "Sales Header";

        Text1: Label 'Please release the current Sales Order in at "%1"';
        Text2: Label 'Please provide the location code for the Sales Line';
        Text3: Label 'Please provide the location code for the Sales Order';
        Text4: Label 'There BOM component Inconsistency for the Sales Line, Please report to administrator.';
        SalesLine: Record "Sales Line";
        MainSalesLine: Record "Sales Line";
        TempLineNo: Integer;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        BOMSalesLine: Record "Sales Line";
        CorrectMainSalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        ICRetailSales: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany() <> SalesTruthMgt.InventoryCompany() then
            if SalesHeader.FindSet() then
                repeat
                    SalesHeader.Status := SalesHeader.Status::Open;
                    SalesHeader.Modify();
                    if PurchaseHeader.Get(SalesHeader."Document Type", SalesHeader."Automate Purch.Doc No.") then begin
                        PurchaseHeader.Status := SalesHeader.Status::Open;
                        PurchaseHeader.Modify();
                    end;

                    ICRetailSales.Reset();
                    ICRetailSales.ChangeCompany(SalesTruthMgt.InventoryCompany());
                    ICRetailSales.SetRange(RetailSalesHeader, SalesHeader."No.");
                    if ICRetailSales.FindSet() then begin
                        ICRetailSales.Status := ICRetailSales.Status::Open;
                        ICRetailSales.Modify();
                    end;

                    if SalesHeader."No." = 'FSO101074' then
                        Message('jjj');
                    begin
                        SalesLine.Reset();
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange("BOM Item", false);
                        if SalesLine.FindSet() then
                            repeat
                                if SalesTruthMgt.IsValideICSalesLine(SalesLine) and (SalesLine."Location Code" = '') then
                                    Error(Text2);
                            until Salesline.Next() = 0;
                        if SalesHeader."Location Code" = '' then begin
                            SalesLine.Reset();
                            SalesLine.SetRange("Document No.", SalesHeader."No.");
                            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                            if SalesLine.FindSet() then
                                SalesHeader."Location Code" := SalesLine."Location Code";
                            SalesHeader.Modify();
                        end;

                        // BOM Examination
                        if MainSalesLine.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
                            MainsalesLine.SetRange("Document Type", SalesHeader."Document Type");
                            MainSalesLine.SetRange("Document No.", SalesHeader."No.");
                            MainSalesLine.SetRange(Type, MainSalesLine.Type::Item);
                            MainSalesLine.SetRange("BOM Item", false);

                            if MainSalesLine.FindSet() then begin
                                repeat
                                    TempLineNo := MainSalesLine."Line No.";
                                    Item.Get(MainSalesLine."No.");
                                    if Item.Type = Item.Type::Inventory then begin
                                        BOMComponent.SetRange("Parent Item No.", Item."No.");
                                        if BOMComponent.FindSet() then
                                            repeat
                                                TempLineNo += 10000;
                                                if BOMSalesLine.Get(MainSalesLine."Document Type", MainSalesLine."Document No.", TempLineNo) then
                                                    if BOMSalesLine."No." <> BOMComponent."No." then begin
                                                        CorrectMainSalesLine := MainSalesLine;

                                                        MainSalesLine.Delete(true);
                                                        CorrectMainSalesLine.Insert(true);
                                                    end;
                                            // if BOMSalesLine.Get(MainSalesLine."Document Type", MainSalesLine."Document No.", TempLineNo) = false then begin
                                            //     CorrectMainSalesLine := MainSalesLine;
                                            //     MainSalesLine.Delete(true);
                                            //     CorrectMainSalesLine.Insert(true);
                                            // end;
                                            until BOMComponent.Next() = 0;
                                    end;
                                until MainSalesLine.Next() = 0;
                            end;
                        end;
                    end;

                    ICRetailSales.Reset();
                    ICRetailSales.ChangeCompany(SalesTruthMgt.InventoryCompany());
                    ICRetailSales.SetRange(RetailSalesHeader, SalesHeader."No.");
                    if ICRetailSales.FindSet() then begin
                        ICRetailSales.Status := ICRetailSales.Status::Released;
                        ICRetailSales.Modify();
                    end;
                    if PurchaseHeader.Get(SalesHeader."Document Type", SalesHeader."Automate Purch.Doc No.") then begin
                        PurchaseHeader.Status := SalesHeader.Status::Released;
                        PurchaseHeader.Modify();
                    end;
                    SalesHeader.Status := SalesHeader.Status::Released;
                    SalesHeader.Modify();
                until SalesHeader.Next() = 0;
    end;
}

