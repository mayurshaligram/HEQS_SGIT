codeunit 50101 "Sales Truth Mgt"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreateSalesDocument', '', false, false)]
    local procedure AfterCreateSalesDocument(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header"; HandledICInboxSalesHeader: Record "Handled IC Inbox Sales Header");
    var
        RetailSalesHeader: Record "Sales Header";
    begin
        RetailSalesHeader.ChangeCompany(SalesHeader."Sell-to Customer Name");
        RetailSalesHeader.SetRange("Automate Purch.Doc No.", SalesHeader."External Document No.");
        RetailSalesHeader.FindSet();

        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader."Work Description" := RetailSalesHeader."Work Description";
        SalesHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnInsertPurchaseHeader', '', false, false)]
    local procedure InsertPurchaseHeader(var SalesHeader: Record "Sales Header");
    var
        TempText: Text;
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        PurchPaySetup.Get('');
        NoSeriesCode := PurchPaySetup."Order Nos.";
        NoSeries.Get(NoSeriesCode);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);

        if NoSeriesLine.FindSet() = false then
            Error('Please Create No series line');
        begin
            PurchaseHeader.Init();
            PurchaseHeader."Document Type" := SalesHeader."Document Type";
            PurchaseHeader."No." := NoSeriesMgt.DoGetNextNo(NoSeries.Code, System.Today(), true, true);
            PurchaseHeader."Sales Order Ref" := SalesHeader."No.";
            TempText := 'HEQS INTERNATIONAL PTY LTD';
            Vendor."Search Name" := TempText;
            Vendor.FindSet();
            PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
            PurchaseHeader."Due Date" := System.Today();
            PurchaseHeader."Currency Factor" := SalesHeader."Currency Factor";
            PurchaseHeader."Buy-from Vendor No." := Vendor."No.";
            PurchaseHeader."Buy-from Vendor Name" := Vendor.Name;
            // Update Based on SO
            PurchaseHeader."Pay-to Vendor No." := Vendor."No.";
            PurchaseHeader."Pay-to Name" := Vendor.Name;
            PurchaseHeader."VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
            PurchaseHeader."Order Date" := System.Today();

            PurchaseHeader."Document Date" := SalesHeader."Document Date";
            PurchaseHeader."Location Code" := SalesHeader."Location Code";
            PurchaseHeader.Amount := SalesHeader.Amount;
            SalesHeader.CALCFIELDS("Work Description");
            PurchaseHeader."Work Description" := SalesHeader."Work Description";
            PurchaseHeader."Ship-to Address" := SalesHeader."Ship-to Address";
            PurchaseHeader."Ship-to Contact" := SalesHeader."Ship-to Contact";
            PurchaseHeader."Currency Code" := SalesHeader."Currency Code";
            PurchaseHeader."Ship-to Name" := SalesHeader."Ship-to Name";
            PurchaseHeader."Ship-to Address" := SalesHeader."Ship-to Address";
            PurchaseHeader."Send IC Document" := true;
            PurchaseHeader."Posting Date" := SalesHeader."Posting Date";
            PurchaseHeader."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
            PurchaseHeader."Status" := SalesHeader."Status";
            PurchaseHeader.Insert();
            SalesHeader."Automate Purch.Doc No." := PurchaseHeader."No.";
            SalesHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'onUpdatePurch_IC_BOM', '', false, false)]
    local procedure UpdatePurch_IC_BOM(var SalesLine: Record "Sales Line");
    begin
        UpdateBOMSalesLine(SalesLine);
        if SalesLine.CurrentCompany <> 'HEQS International Pty Ltd' then begin
            UpdatePurchLine(SalesLine);
            UpdateICSalesLine(SalesLine);
        end;

    end;

    local procedure UpdateBOMSalesLine(var SalesLine: Record "Sales Line");
    var
        BOMComponent: Record "BOM Component";
        BOMSalesLine: Record "Sales Line";
    begin
        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", SalesLine."No.");
        if BOMComponent.FindSet() then
            repeat
                BOMSalesLine.Reset();
                BOMSalesLine.SetRange("Document Type", SalesLine."Document Type");
                BOMSalesLine.SetRange("Document No.", SalesLine."Document No.");
                BOMSalesLine.SetRange("No.", BOMComponent."No.");
                BOMSalesLine.SetRange("BOM Item", true);
                if BOMSalesLine.FindSet() then
                    repeat
                        BOMSalesLine.Validate("Location Code", SalesLine."Location Code");
                        BOMSalesLine.Validate(Quantity, SalesLine.Quantity * BOMComponent."Quantity per");
                        BOMSalesLine.Modify();
                    until BOMSalesLine.Next() = 0;
            until BOMComponent.Next() = 0;
    end;

    local procedure UpdatePurchLine(var SalesLine: Record "Sales Line");
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PurchaseLine: Record "Purchase Line";
        TempSalesLine: Record "Sales Line";
    begin
        Item.Get(SalesLine."No.");
        if Item.Type = Item.Type::Service then
            exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");

        TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
        TempSalesLine.SetRange("Document No.", SalesLine."Document No.");

        if TempSalesLine.FindSet() then
            repeat
                if PurchaseLine.Get(TempSalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", TempSalesLine."Line No.") = false then
                    CreatePurchaseLine(TempSalesLine)
                else begin
                    PurchaseLine.Validate("No.", TempSalesLine."No.");
                    PurchaseLine."BOM Item" := TempSalesLine."BOM Item";
                    PurchaseLine.Validate(Quantity, TempSalesLine.Quantity);
                    PurchaseLine.Validate("Location Code", TempSalesLine."Location Code");
                    PurchaseLine."VAT Bus. Posting Group" := TempSalesLine."VAT Bus. Posting Group";
                    PurchaseLine."VAT Prod. Posting Group" := TempSalesLine."VAT Prod. Posting Group";

                    Item.Get(TempSalesLine."No.");
                    PurchaseLine."Direct Unit Cost" := Item."Unit Cost";
                    PurchaseLine.Modify();
                end;
            until TempSalesLine.Next() = 0;
    end;

    local procedure UpdateICSalesLine(var SalesLine: Record "Sales Line");
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        ICSalesHeader: Record "Sales Header";
        TempSalesLine: Record "Sales Line";
        ICSalesLine: Record "Sales Line";
    begin
        Item.Get(SalesLine."No.");
        if Item.Type = Item.Type::Service then
            exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");

        ICSalesHeader.ChangeCompany('HEQS International Pty Ltd');
        ICSalesHeader.SetRange("External Document No.", SalesHeader."Automate Purch.Doc No.");
        if ICSalesHeader.FindSet() = false then exit;

        TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
        TempSalesLine.SetRange("Document No.", SalesLine."Document No.");

        if TempSalesLine.FindSet() then begin
            Item.Get(TempSalesLine."No.");
            if Item.Type <> Item.Type::Service then
                repeat
                    ICSalesLine.ChangeCompany('HEQS International Pty Ltd');
                    if ICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", TempSalesLine."Line No.") = false then
                        CreateICSalesLine(TempSalesLine)
                    else begin
                        ICSalesLine.Validate("No.", TempSalesLine."No.");
                        ICSalesLine."BOM Item" := TempSalesLine."BOM Item";
                        ICSalesLine.Validate(Quantity, TempSalesLine.Quantity);
                        ICSalesLine.Validate("Location Code", TempSalesLine."Location Code");
                        ICSalesLine."VAT Bus. Posting Group" := TempSalesLine."VAT Bus. Posting Group";
                        ICSalesLine."VAT Prod. Posting Group" := TempSalesLine."VAT Prod. Posting Group";
                        ICSalesLine."Unit Price" := TempSalesLine."Unit Price";
                        ICSalesLine.Modify();
                    end;
                until TempSalesLine.Next() = 0;
        end;
    end;



    local procedure UpdateICSalesOrder(var ICSalesHeader: Record "Sales Header");
    var
        RetailSalesOrder: Record "Sales Header";
        RetailSalesLine: Record "Sales Line";
        ICSalesLine: Record "Sales Line";
    begin
        if ICSalesHeader."External Document No." = '' then
            exit;

        RetailSalesOrder.Reset();
        RetailSalesOrder.ChangeCompany(ICSalesHeader."Sell-to Customer Name");
        RetailSalesOrder.SetRange("Automate Purch.Doc No.", ICSalesHeader."External Document No.");
        RetailSalesOrder.Find();

        ICSalesHeader.Validate("Work Description", RetailSalesOrder."Work Description");
        ICSalesHeader.Validate("Location Code", RetailSalesOrder."Location Code");
        ICSalesHeader."Due Date" := RetailSalesOrder."Due Date";
        ICSalesHeader.Status := RetailSalesOrder.Status::Released;
        ICSalesHeader.Modify();

        RetailSalesLine.Reset();
        RetailSalesLine.ChangeCompany(ICSalesHeader."Sell-to Customer Name");
        RetailSalesLine.SetRange("Document Type", RetailSalesOrder."Document Type");
        RetailSalesLine.SetRange("Document No.", RetailSalesOrder."No.");
        if RetailSalesLine.FindSet() then
            repeat
                ICSalesLine.Reset();
                ICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", RetailSalesLine."Line No.");
                ICSalesLine.Validate("No.", RetailSalesLine."No.");
                ICSalesLine.Validate("Location Code", RetailSalesLine."Location Code");
                ICSalesLine.Validate(Quantity, RetailSalesLine.Quantity);
                ICSalesLine.Validate("BOM Item", RetailSalesLine."BOM Item");
                ICSalesLine.Modify();
            until RetailSalesLine.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Table, 37, 'OnCreatePurch_IC_BOM', '', false, false)]
    local procedure CreatePurch_IC_BOM(var SalesLine: Record "Sales Line");
    begin
        if SalesLine.CurrentCompany = InventoryCompanyName then
            ExplodeBOM(SalesLine);
        if (SalesLine.CurrentCompany <> InventoryCompanyName) and (SalesLine.Type = SalesLine.Type::Item) then begin
            CreatePurchaseLine(SalesLine);
            CreateICSalesLine(SalesLine);
            ExplodeBOM(SalesLine);
        end;
    end;

    local procedure ExplodeBOM(SalesLine: Record "Sales Line");
    var
        PreviousSalesLine: Record "Sales Line";
        ToSalesLine: Record "Sales Line";
        NextLineNo: Integer;
        InsertLinesBetween: Boolean;
        LineSpacing: Integer;
        NoOfBOMComp: Integer;
        BOMComponent: Record "BOM Component";
        Text001: Label 'There is not enough space to explode the BOM.';
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        ItemTranslation: Record "Item Translation";
        // Not Neccessary
        Resource: Record Resource;
    begin
        SalesHeader.Reset();
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ToSalesLine.Reset();
        ToSalesLine.SetRange("Document Type", SalesLine."Document Type");
        ToSalesLine.SetRange("Document No.", SalesLine."Document No.");
        ToSalesLine := SalesLine;
        NextLineNo := SalesLine."Line No.";
        InsertLinesBetween := false;
        if ToSalesLine.Find('>') then
            // Attached to Line No in System is Always 0 (If Not Using the Extent Text Function)
            if ToSalesLine."Attached to Line No." = SalesLine."Line No." then begin
                ToSalesLine.SetRange("Attached to Line No.", SalesLine."Line No.");
                ToSalesLine.FindLast;
                ToSalesLine.SetRange("Attached to Line No.");
                NextLineNo := ToSalesLine."Line No.";
                InsertLinesBetween := ToSalesLine.Find('>');
            end else
                InsertLinesBetween := true;
        if InsertLinesBetween then
            LineSpacing := (ToSalesLine."Line No." - NextLineNo) div (1 + NoOfBOMComp)
        else
            LineSpacing := 10000;
        if LineSpacing = 0 then
            Error(Text001);

        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", SalesLine."No.");
        if BOMComponent.FindSet then
            repeat
                ToSalesLine.Init();
                NextLineNo := NextLineNo + LineSpacing;
                ToSalesLine."Line No." := NextLineNo;

                case BOMComponent.Type of
                    BOMComponent.Type::" ":
                        ToSalesLine.Type := ToSalesLine.Type::" ";
                    BOMComponent.Type::Item:
                        ToSalesLine.Type := ToSalesLine.Type::Item;
                    BOMComponent.Type::Resource:
                        ToSalesLine.Type := ToSalesLine.Type::Resource;
                end;
                if ToSalesLine.Type <> ToSalesLine.Type::" " then begin
                    BOMComponent.TestField("No.");
                    ToSalesLine.Validate("No.", BOMComponent."No.");
                    if SalesHeader."Location Code" <> SalesLine."Location Code" then
                        ToSalesLine.Validate("Location Code", SalesLine."Location Code");
                    // For Item Variant, Here Most Likely won't assigned
                    if BOMComponent."Variant Code" <> '' then
                        ToSalesLine.Validate("Variant Code", BOMComponent."Variant Code");
                    if ToSalesLine.Type = ToSalesLine.Type::Item then begin
                        ToSalesLine."Drop Shipment" := SalesLine."Drop Shipment";
                        Item.Get(BOMComponent."No.");
                        ToSalesLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
                        ToSalesLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, ToSalesLine."Unit of Measure Code");
                        ToSalesLine.Validate(Quantity,
                          Round(
                            SalesLine."Quantity (Base)" * BOMComponent."Quantity per" *
                            UOMMgt.GetQtyPerUnitOfMeasure(
                              Item, ToSalesLine."Unit of Measure Code") / ToSalesLine."Qty. per Unit of Measure",
                            UOMMgt.QtyRndPrecision));
                    end else
                        //  Less Likely happend to have component Resource
                        if ToSalesLine.Type = ToSalesLine.Type::Resource then begin
                            Resource.Get(BOMComponent."No.");
                            ToSalesLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
                            ToSalesLine."Qty. per Unit of Measure" :=
                              UOMMgt.GetResQtyPerUnitOfMeasure(Resource, ToSalesLine."Unit of Measure Code");
                            ToSalesLine.Validate(Quantity,
                              Round(
                                SalesLine."Quantity (Base)" * BOMComponent."Quantity per" *
                                UOMMgt.GetResQtyPerUnitOfMeasure(
                                  Resource, ToSalesLine."Unit of Measure Code") / ToSalesLine."Qty. per Unit of Measure",
                                UOMMgt.QtyRndPrecision));
                        end else
                            ToSalesLine.Validate(Quantity, SalesLine."Quantity (Base)" * BOMComponent."Quantity per");

                    if SalesHeader."Shipment Date" <> SalesLine."Shipment Date" then
                        ToSalesLine.Validate("Shipment Date", SalesLine."Shipment Date");
                end;
                if SalesHeader."Language Code" = '' then
                    ToSalesLine.Description := BOMComponent.Description
                else
                    if not ItemTranslation.Get(BOMComponent."No.", BOMComponent."Variant Code", SalesHeader."Language Code") then
                        ToSalesLine.Description := BOMComponent.Description;

                // Modify Place, Only Give Item Type
                ToSalesLine."Document No." := SalesLine."Document No.";
                ToSalesLine."Document Type" := SalesLine."Document Type";
                ToSalesLine.Type := ToSalesLine.Type::Item;
                ToSalesLine."BOM Item" := true;
                ToSalesLine."Location Code" := SalesLine."Location Code";
                ToSalesLine.Validate("Qty. to Assemble to Order");
                ToSalesLine.Insert();

                if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine.Reserve = ToSalesLine.Reserve::Always) then
                    ToSalesLine.AutoReserve();


                CreatePurchaseLine(ToSalesLine);
                CreateICSalesLine(ToSalesLine);
            until BOMComponent.Next = 0;

    end;

    local procedure CreatePurchaseLine(SalesLine: Record "Sales Line");
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        Vendor: Record Vendor;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        IsMainItem: Boolean;

    begin
        Item.Get(SalesLine."No.");
        If Item.Type = Item.Type::Service then
            exit;
        Vendor."Search Name" := 'HEQS INTERNATIONAL PTY LTD';
        Vendor.FindSet();

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");
        PurchaseLine.Reset();
        PurchaseLine.Init();
        PurchaseLine."Document Type" := SalesLine."Document Type";
        PurchaseLine."Document No." := SalesHeader."Automate Purch.Doc No.";
        PurchaseLine."Line No." := SalesLine."Line No.";
        PurchaseLine.Type := SalesLine.Type;
        // Validate No, System will trigger onValide to update unit price, and unit of measure
        PurchaseLine.Validate("No.", SalesLine."No.");
        PurchaseLine."BOM Item" := SalesLine."BOM Item";
        // Fix Problem of not carry quantiti to receive 
        PurchaseLine.Validate(Quantity, SalesLine.Quantity);
        PurchaseLine.Validate("Location Code", SalesLine."Location Code");
        PurchaseLine.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseLine."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
        PurchaseLine."VAT Prod. Posting Group" := PurchaseLine."VAT Prod. Posting Group";
        PurchaseLine."Direct Unit Cost" := Item."Unit Cost";
        PurchaseLine.Insert();
        if (PurchaseLine."Direct Unit Cost" = 0) and (PurchaseLine."BOM Item" = false) then
            Error('Please Set Purchase Price for item %1', Item."No.");
    end;

    local procedure CreateICSalesLine(SalesLine: Record "Sales Line");
    var
        ICSalesLine: Record "Sales Line";
        ICSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
    begin
        Item.Get(SalesLine."No.");
        if Item.Type = Item.Type::Service then exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        ICSalesHeader.ChangeCompany(InventoryCompanyName);
        ICSalesHeader.SetRange("External Document No.", SalesHeader."Automate Purch.Doc No.");
        if ICSalesHeader.FindSet() then begin
            ICSalesLine.Reset();
            ICSalesLine.ChangeCompany(InventoryCompanyName);
            ICSalesLine."Document Type" := SalesLine."Document Type";
            ICSalesLine."Document No." := SalesLine."Document No.";
            ICSalesLine."Line No." := SalesLine."Line No.";
            ICSalesLine.Type := SalesLine.Type;
            ICSalesLine."BOM Item" := SalesLine."BOM Item";
            ICSalesLine.Insert();
        end;

    end;
}