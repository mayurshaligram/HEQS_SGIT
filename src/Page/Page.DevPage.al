page 50105 "DevPage"
{
    Caption = 'DevPage';
    Editable = true;
    PageType = List;
    SourceTable = Driver;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'DevPage';
    Permissions = TableData 112 = rimd, TableData "Purch. Inv. Header" = imd;

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
                        SalesHeader: Record "Sales Header";
                        PayableMgt: Record Payable;
                        WhseRequest: Record "Warehouse Request";
                        NewWhseRequest: Record "Warehouse Request";
                    begin
                        if Password = '0' then
                            if Dialog.Confirm('Reload Item unit of measure in international company') then
                                ReloadItemUnitOfMeasure();
                        // if Password = '1' then
                        //     if Dialog.Confirm('Add Test Case') then
                        //         AddTestCase();

                        // if Password = '2' then
                        //     if Dialog.Confirm('Reload the Payable Table') then begin

                        //         LoadPayable;
                        //         LoadPayableForPurchInv;
                        //     end;


                        // if Password = 'Heqs326688' then
                        // if Dialog.Confirm('RemoveLink') then
                        //     RemoveLink();

                        // if Password = Correct then begin
                        //     Message('Password Correct.');
                        //     // Delete all the WarehouseEntry in the Batch NSWWIJ
                        //     WarehouseEntry.Reset();
                        //     WarehouseJournal.Reset();
                        //     // WarehouseJournal.SetRange(Quantity, 0);
                        //     if WarehouseEntry.FindSet() then
                        //         repeat
                        //             WarehouseEntry.Delete();
                        //         until WarehouseEntry.Next() = 0;
                        //     if WarehouseJournal.FindSet() then
                        //         repeat
                        //             WarehouseJournal.Delete();
                        //         until WarehouseJournal.Next() = 0;
                        //     DeletePilloW();
                        // end

                        // else
                        //     if Password = LineFixPassword then begin
                        //         Message('This for line discount fix');
                        //         LineFix();
                        //         Message('This for delete item 7030003 and 7030013');
                        //         DeleteItem();
                        //     end;
                        // if Password = ExternalMovingPassword then
                        //     ExternalMoving();

                        // if Password = DeletePurchaseLinePassword then
                        //     if Dialog.Confirm('Delete PurchaseLine Password') then
                        //         DeletePurchaseLine();

                        // if Password = TurnWarehouseRequestReleasePassword then
                        //     if Dialog.Confirm('Delete PurchaseLine Password') then
                        //         TurnWarehouseRequestRelease();

                        // if Password = GiveBackExternalPassword then
                        //     if Dialog.Confirm('Give Back to external password') then
                        //         GiveBackExternal();
                        // if Password = ReleaseWhseRequesPassword then
                        //     if Dialog.Confirm('Release Whse Request') then
                        //         ReleaseWhseRequest();
                        // if Password = DeleteAllWhseShipmentLinePassword then
                        //     if Dialog.Confirm('Delete all whse shipment line') then
                        //         DeleteAllWhseShipmentLine();
                        // if Password = QuickFixPassword then
                        //     if Dialog.Confirm('Quick Fix all the sales header') then
                        //         QuickFix();
                        // if Password = ReleaseReOpenPassword then
                        //     if Dialog.Confirm('Release Reopen all the sales Header to fix BOM') then
                        //         ReleaseReOpen();
                        // if Password = HardReleaseAndPost25Password then
                        //     if Dialog.Confirm('Start the function to hardrelease 25') then
                        //         HardReleaseAndPost25();
                        // if Password = DeleteSalesLinePassword then
                        //     if Dialog.Confirm('Start the function to delete the salesline for 25') then
                        //         DeleteSalesLine();
                        // if Password = AutoPurchaseFixedPassword then
                        //     if Dialog.Confirm('Start the function to AutoPurchaseHeader for 85') then
                        //         AutoPurchaseFixed();
                        // if Password = DeleteAllSalesLineForCertainOrderPassword then
                        //     if Dialog.Confirm('Start delete all sales line for sales order 27') then begin
                        //         SalesHeader.Get(SalesHeader."Document Type"::Order, 'FSO101027');
                        //         DeleteAllSalesLineForCertainOrder(SalesHeader);
                        //     end;
                        // if Password = DeleteAllICPassword then
                        //     if Dialog.Confirm(('Start Delte ic ')) then
                        //         DeleteAllIC();
                        // if Password = Release25Password then
                        //     if Dialog.Confirm('Release the FSO101007') then
                        //         release07();
                        // if Password = 'SUPER' then
                        //     if Dialog.Confirm('Super Task you sure?') then
                        //         HOTFIX.Run();
                        // if Password = 'Delete60' then
                        //     if Dialog.Confirm('Delete 60') then
                        //         Delete60();
                        // if Password = ChangeBillingAddressPassword then
                        //     if Dialog.Confirm('Change Billing Address') then
                        //         ChangeBillingAddress();
                    end;

                }
            }
        }

    }
    // trigger OnAfterGetCurrRecord();
    // begin
    //     ChangeWarehouseRequest();
    // end;
    local procedure addtestcase();
    var
        Test: Record "Item Unit of Measure";
    begin
        Test."Item No." := '7010004-B2 OF 2';
        Test.Code := 'BOX';
        Test.Insert();
    end;

    local procedure ReloadItemUnitOfMeasure();
    var
        Test: Record "Item Unit of Measure";
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        NewItemUOM: Record "Item Unit of Measure";
        OtherCompanyRecord: Record Company;
    begin
        if ItemUOM.FindSet() then
            repeat
                if ItemUOM.CurrentCompany = 'HEQS International Pty Ltd' then begin
                    OtherCompanyRecord.Reset();
                    if OtherCompanyRecord.Find('-') then
                        repeat
                            NewItemUOM.Reset();
                            NewItemUOM.ChangeCompany(OtherCompanyRecord.Name);
                            if NewItemUOM.Get(ItemUOM."Item No.", ItemUOM.Code) = false then begin
                                Item.Reset();
                                Item.ChangeCompany(OtherCompanyRecord.Name);
                                if Item.Get(ItemUOM."Item No.") then begin
                                    NewItemUOM := ItemUOM;
                                    NewItemUOM.Insert(true);
                                end;
                            end;
                        until OtherCompanyRecord.Next() = 0;
                end;
            until ItemUOM.Next() = 0;
    end;

    local procedure LoadVendorShipmentNo();
    var
        PostedPurchInvoice: Record "Purch. Inv. Header";
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        Clear(PostedPurchInvoice);
        if PostedPurchInvoice.FindSet() then
            repeat
                Clear(PurchaseHeaderArchive);
                PurchaseHeaderArchive.SetRange("No.", PostedPurchInvoice."Order No.");
                if PurchaseHeaderArchive.FindLast() then begin
                    PostedPurchInvoice."Vendor Invoice No." := PurchaseHeaderArchive."Vendor Invoice No.";
                    PostedPurchInvoice."Vendor Shipment No." := PurchaseHeaderArchive."Vendor Shipment No.";
                    PostedPurchInvoice.Modify()
                end;
            until PostedPurchInvoice.Next() = 0;
    end;

    local procedure RemoveLink();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany() = 'HEQS Wholesale Pty Ltd' then begin
            SalesHeader.Get(SalesHeader."Document Type"::Order, 'WSO100005');
            SalesHeader."Automate Purch.Doc No." := '';
            SalesHeader.Modify();
        end;

    end;

    local procedure GiveAUD();
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                SalesHeader."Currency Code" := 'AUD';
                SalesHeader."Currency Factor" := 1;
                SalesHeader.Modify();
            until SalesHeader.Next() = 0;
    end;

    local procedure ChangeWarehouseRequest();
    var
        NewWhseRequest: Record "Warehouse Request";
        WhseRequest: Record "Warehouse Request";
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then begin
            WhseRequest.Reset();
            WhseRequest.SetRange("Source No.", SalesHeader."No.");
            if WhseRequest.FindSet() then begin
                if WhseRequest."Location Code" <> SalesHeader."Location Code" then begin
                    NewWhseRequest := WhseRequest;
                    WhseRequest.Delete();
                    NewWhseRequest."Location Code" := SalesHeader."Location Code";
                    NewWhseRequest.Insert();
                end;
            end;
        end;
    end;

    local procedure ChangeBillingAddress();
    var
        TargetInvoice: Record "Sales Invoice Header";
    begin
        TargetInvoice.ChangeCompany('HEQS Furniture Pty Ltd');
        TargetInvoice.Get('FPSI103042');
        TargetInvoice."Ship-to Name" := 'Helena Read';
        TargetInvoice.Modify();
    end;

    var
        ChangeBillingAddressPassword: Code[20];
        HOTFIX: Codeunit HotFix;
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
        HardReleaseAndPost25Password: Code[20];
        DeleteSalesLinePassword: Code[20];
        AutoPurchaseFixedPassword: Code[20];
        DeleteAllSalesLineForCertainOrderPassword: Code[20];
        DeleteAllICPassword: Code[20];
        Release25Password: Code[20];

    trigger OnOpenPage();
    var
        User: Record User;
    begin
        User.Get(Database.UserSecurityId());
        if User."Full Name" <> 'Pei Xu' then
            Error('This page is for administrator only, Thank you. If have any concern about that please contact Pei');
    end;

    local procedure ClearPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        if PurchaseHeader.FindSet() then
            repeat
                if (PurchaseHeader."Buy-from Vendor Name" = 'HEQS International Pty Ltd') or (PurchaseHeader."Buy-from Vendor Name" = 'HEQS International') then
                    PurchaseHeader.Delete(true);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure ClearPayable()
    var
        Payable: Record Payable;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.FindSet() then
            repeat
                Payable.Delete()
            until Payable.Next() = 0;
    end;

    var
        PayableMgt: Codeunit PayableMgt;

    local procedure LoadPayable()
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        PurchaseLine: Record "Purchase Line";
        OtherCompanyRecord: Record Company;

    begin



        if OtherCompanyRecord.Find('-') then
            repeat
                PurchaseHeader.Reset();
                PurchaseHeader.ChangeCompany(OtherCompanyRecord.Name);
                SalesHeader.Reset();
                SalesHeader.ChangeCompany(OtherCompanyRecord.Name);
                if PurchaseHeader.FindSet() then
                    repeat
                        if PurchaseHeader."Sales Order Ref" = '' then begin
                            SalesHeader.SetRange("Document Type", PurchaseHeader."Document Type");
                            SalesHeader.SetRange("Automate Purch.Doc No.", PurchaseHeader."No.");
                            if SalesHeader.FindSet() = false then
                                if NotContainPayable(PurchaseHeader) = false then begin
                                    PayableMgt.PurchaseHeaderInsertPayable(PurchaseHeader);

                                    PurchaseLine.Reset();
                                    PurchaseLine.ChangeCompany(OtherCompanyRecord.Name);
                                    PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                                    if PurchaseLine.FindSet() then
                                        PayableMgt.PutPayableItem(PurchaseLine);
                                end;
                        end;
                    until PurchaseHeader.Next() = 0;
            until OtherCompanyRecord.Next() = 0;
    end;


    local procedure LoadPayableForPurchInv()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        OtherCompanyRecord: Record Company;
    begin
        if OtherCompanyRecord.Find('-') then
            repeat
                PurchInvHeader.Reset();
                PurchInvHeader.ChangeCompany(OtherCompanyRecord.Name);
                if PurchInvHeader.FindSet() then
                    repeat
                        if NotContainPayableForPurchInv(PurchInvHeader) = false then begin
                            PayableMgt.PurchInvHeaderInsertPayable(PurchInvHeader);
                        end;

                    until PurchInvHeader.Next() = 0;
            until OtherCompanyRecord.Next() = 0;
    end;


    local procedure NotContainPayable(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        Payable: Record Payable;
        TempBoolean: Boolean;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseHeader."No.") then
            TempBoolean := true;
        exit(TempBoolean);
    end;

    local procedure NotContainPayableForPurchInv(var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        Payable: Record Payable;
        TempBoolean: Boolean;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchInvHeader."No.") then
            TempBoolean := true;
        exit(TempBoolean);
    end;



    local procedure Deletearbitaryauto();
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, 'IFSO101533');
        SalesHeader."Automate Purch.Doc No." := '';
        SalesHeader.Modify();
    end;

    local procedure ChainChangeBOM();
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ICSalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        if SalesLine.CurrentCompany = 'HEQS Furniture Pty Ltd' then begin
            SalesLine.Get(SalesLine."Document Type"::Order, 'FSO101103', 80000);
            SalesLine."No." := '7010003 - B1 OF 1';
            SalesLine.Quantity := 1;
            SalesLine."Unit of Measure" := 'BOX';
            SalesLine."Unit of Measure Code" := 'BOX';
            SalesLine.Modify();

            PurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000103', 80000);
            PurchaseLine."No." := '7010003 - B1 OF 1';
            PurchaseLine.Quantity := 1;
            PurchaseLine."Unit of Measure" := 'BOX';
            PurchaseLine."Unit of Measure Code" := 'BOX';
            PurchaseLine.Modify();

            ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
            ICSalesLine.Get(SalesLine."Document Type"::Order, 'INT101546', 80000);
            ICSalesLine."No." := '7010003 - B1 OF 1';
            ICSalesLine.Quantity := 1;
            ICSalesLine."Unit of Measure" := 'BOX';
            ICSalesLine."Unit of Measure Code" := 'BOX';
            ICSalesLine.Modify();
        end;

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

    local procedure HardReleaseAndPost25();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany() = 'HEQS Furniture Pty Ltd' then begin
            SalesHeader.Get(SalesHeader."Document Type"::Order, 'FSO101025');
            SalesHeader.Status := SalesHeader.Status::Released;
            SalesHeader.Modify();
        end;
    end;

    local procedure DeleteSalesLine();
    var
        SalesLine: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        NewPurchaseLine: Record "Purchase Line";
        ICSalesLine: Record "Sales Line";
        NewICSalesLine: Record "Sales Line";
    begin
        if SalesLine.CurrentCompany() = 'HEQS Furniture Pty Ltd' then begin
            // Deleted Sales Line
            SalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 40000);
            NewSalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 30000);
            SalesLine.Delete();
            NewSalesLine."No." := '1220002- P1 OF 1';
            NewSalesLine."Unit of Measure Code" := 'PIECES';
            NewSalesLine."Line No." := 40000;
            // NewSalesLine.Quantity := 1;
            // NewSalesLine."Qty. to Ship" := 1;
            // NewSalesLine."Qty. to Invoice" := 1;
            // NewSalesLine."Quantity (Base)" := 1;
            // NewSalesLine."Outstanding Qty. (Base)" := 1;
            // NewSalesLine."Qty. to Invoice (Base)" := 1;
            // NewSalesLine."Qty. to Ship (Base)" := 1;
            NewSalesLine.Insert();
            // Deleted Purchase Line
            PurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 40000);
            NewPurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 40000);
            PurchaseLine.Delete();
            NewPurchaseLine."No." := '1220002- P1 OF 1';
            NewPurchaseLine."Unit of Measure Code" := 'PIECES';
            NewPurchaseLine."Line No." := 40000;
            // NewPurchaseLine.Quantity := 1;
            // NewPurchaseLine."Qty. to Receive" := 1;
            // NewPurchaseLine."Qty. to Invoice" := 1;
            // NewPurchaseLine."Quantity (Base)" := 1;
            NewPurchaseLine.Insert();
            // Deleted ICSales Line
            ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
            ICSalesLine.Get(ICSalesLine."Document Type"::Order, 'INT101142', 40000);
            ICSalesLine := NewSalesLine;
            ICSalesLine."Document No." := 'INT101142';
            ICSalesLine.Modify();


            SalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 60000);
            NewSalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 50000);
            SalesLine.Delete();
            NewSalesLine."No." := '4030035- B1 OF 1';
            NewSalesLine."Unit of Measure Code" := 'BOX';
            NewSalesLine."Line No." := 60000;
            // NewSalesLine.Quantity := 1;
            // NewSalesLine."Qty. to Ship" := 1;
            // NewSalesLine."Qty. to Invoice" := 1;
            // NewSalesLine."Quantity (Base)" := 1;
            // NewSalesLine."Outstanding Qty. (Base)" := 1;
            // NewSalesLine."Qty. to Invoice (Base)" := 1;
            // NewSalesLine."Qty. to Ship (Base)" := 1;
            NewSalesLine.Insert();
            // Deleted Purchase Line
            PurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 60000);
            NewPurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 50000);
            PurchaseLine.Delete();
            NewPurchaseLine."No." := '4030035- B1 OF 1';
            NewPurchaseLine."Unit of Measure Code" := 'BOX';
            NewSalesLine."Line No." := 60000;
            // NewPurchaseLine.Quantity := 1;
            // NewPurchaseLine."Qty. to Receive" := 1;
            // NewPurchaseLine."Qty. to Invoice" := 1;
            // NewPUrchaseLine."Quantity (Base)" := 1;
            NewPurchaseLine.Insert();
            // Deleted ICSales Line
            ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
            ICSalesLine.Get(ICSalesLine."Document Type"::Order, 'INT101142', 60000);
            ICSalesLine := NewSalesLine;
            ICSalesLine."Document No." := 'INT101142';
            ICSalesLine.Modify();

            SalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 80000);
            NewSalesLine.Get(SalesLine."Document Type"::Order, 'FSO101025', 70000);
            SalesLine.Delete();
            NewSalesLine."No." := '4010065- B1 OF 1';
            NewSalesLine."Line No." := 80000;
            // NewSalesLine.Quantity := 1;
            // NewSalesLine."Qty. to Ship" := 1;
            // NewSalesLine."Qty. to Invoice" := 1;
            // NewSalesLine."Quantity (Base)" := 1;
            // NewSalesLine."Outstanding Qty. (Base)" := 1;
            // NewSalesLine."Qty. to Invoice (Base)" := 1;
            // NewSalesLine."Qty. to Ship (Base)" := 1;
            NewSalesLine.Insert();
            // Deleted Purchase Line
            PurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 80000);
            NewPurchaseLine.Get(PurchaseLine."Document Type"::Order, 'FPO000025', 70000);
            PurchaseLine.Delete();
            NewPurchaseLine."No." := '4010065- B1 OF 1';
            NewPurchaseLine."Line No." := 80000;
            // NewPurchaseLine.Quantity := 1;
            // NewPurchaseLine."Qty. to Receive" := 1;
            // NewPurchaseLine."Qty. to Invoice" := 1;
            // NewPurchaseLine."Quantity (Base)" := 1;
            NewPurchaseLine.Insert();
            // Deleted ICSales Line
            ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
            ICSalesLine.Get(ICSalesLine."Document Type"::Order, 'INT101142', 80000);
            ICSalesLine := NewSalesLine;
            ICSalesLine."Document No." := 'INT101142';
            ICSalesLine.Modify();
        end;
    end;

    local procedure AutoPurchaseFixed();
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        if SalesHeader.CurrentCompany = 'Iflow Network Pty Ltd' then begin
            SalesHeader.Get(SalesHeader."Document Type"::Order, 'IFSO101285');
            SalesHeader."Automate Purch.Doc No." := 'IFPO100285';
            SalesHeader.Modify();
        end;
    end;

    local procedure DeleteAllSalesLineForCertainOrder(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";

        ICSalesHeader: Record "Sales Header";
        ICSalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                SalesLine.Delete()
            until SalesLine.Next() = 0;

        PurchaseLine.SetRange("Document Type", SalesHeader."Document Type");
        PurchaseLine.SetRange("Document No.", SalesHeader."Automate Purch.Doc No.");
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine.Delete()
            until PurchaseLine.Next() = 0;

        // ICSalesHeader.Reset();
        // ICSalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        // ICSalesHeader.SetRange(RetailSalesHeader, SalesHeader."No.");
        // ICSalesLine.Reset();
        // ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
        // ICSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        // ICSalesLine.SetRange("Document No.", ICSalesHeader."No.");
        // if ICSalesLine.FindSet() then
        //     repeat
        //         ICSalesLine.Delete()
        //     until ICSalesLine.Next() = 0;
    end;

    local procedure DeleteAllIC()
    var
        ICSalesHeader: Record "Sales Header";
        ICSalesLine: Record "Sales Line";
    begin
        ICSalesLine.SetRange("Document Type", ICSalesHeader."Document Type"::Order);
        ICSalesLine.SetRange("Document No.", 'INT101098');
        if ICSalesLine.FindSet() then
            repeat
                ICSalesLine.Delete()
            until ICSalesLine.Next() = 0;
    end;

    local procedure Release25();
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ICSalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, 'FSO101025');
        PurchaseHeader.Get(SalesHeader."Document Type"::Order, 'FPO000025');
        ICSalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        ICSalesHeader.Get(ICSalesHeader."Document Type"::Order, 'INT101142');
        SalesHeader.Status := SalesHeader.Status::Released;
        PurchaseHeader.Status := PurchaseHeader.Status::Released;
        ICSalesHeader.Status := ICSalesHeader.Status::Released;
        SalesHeader.Modify();
        PurchaseHeader.Modify();
        ICSalesHeader.Modify();
    end;

    local procedure release07();
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ICSalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, 'FSO101007');
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, 'FPO000057');
        PurchaseHeader.Status := PurchaseHeader.Status::Released;
        PurchaseHeader.Modify();
    end;

    local procedure Delete60();
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Get(SalesLine."Document Type"::Order, 'FSO101060', 40000);
        SalesLine.Delete();
    end;
}

