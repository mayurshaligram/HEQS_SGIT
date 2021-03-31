codeunit 50101 "Sales Truth Mgt"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    procedure IsRetailSalesHeader(var RetailSalesHeader: Record "Sales Header"): Boolean;
    var
        TempSalesLine: Record "Sales Line";
        TempItem: Record Item;
        IsValid: Boolean;
    begin
        IsValid := false;
        if RetailSalesHeader.CurrentCompany <> InventoryCompanyName then begin
            TempSalesLine.SetRange("Document Type", RetailSalesHeader."Document Type");
            TempSalesLine.SetRange("Document No.", RetailSalesHeader."No.");
            TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
            if TempSalesLine.FindSet() then
                repeat
                    TempItem.Get(TempSalesLine."No.");
                    if TempItem.Type = TempItem.Type::Inventory then IsValid := true;
                until TempSalesLine.Next() = 0;
        end;
        exit(IsValid);
    end;

    procedure IsICSalesHeader(var ICSalesHeader: Record "Sales Header"): Boolean;
    var
        IsICSalesHeader: Boolean;
    begin
        IsICSalesHeader := false;
        if (ICSalesHeader.CurrentCompany = InventoryCompanyName) and (ICSalesHeader."External Document No." <> '') then
            IsICSalesHeader := true;

        exit(IsICSalesHeader);
    end;

    local procedure DeleteBOMSalesLine(Var SalesLine: Record "Sales Line");
    var
        BOMSalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        BOMPurchaseLine: Record "Purchase Line";
        BOMICSalesLine: Record "Sales Line";
        ICSalesHeader: Record "Sales Header";

        ExistIC: Boolean;
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ExistIC := false;
        ICSalesHeader.ChangeCompany(InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
        if ICSalesHeader.FindSet() then
            ExistIC := true;
        BOMSalesLine.SetRange("Document Type", SalesLine."Document Type");
        BOMSalesLine.SetRange("Document No.", SalesLine."Document No.");
        BOMSalesLine.SetRange(Type, BOMSalesLine.Type::Item);
        BOMSalesLine.SetRange("BOM Item", true);
        BOMSalesLine.SetRange("Main Item Line", SalesLine."Line No.");
        if BOMSalesLine.FindSet() then
            repeat
                BOMPurchaseLine.Get(BOMSalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", BOMSalesLine."Line No.");
                BOMPurchaseLine.Delete();
                if ExistIC then begin
                    BOMICSalesLine.ChangeCompany(InventoryCompany());
                    BOMICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", BOMSalesLine."Line No.");
                    BOMICSalesLine.Delete();
                end;

                BOMSalesLine.Delete();
            until BOMSalesLine.Next() = 0;
    end;

    local procedure DeletePurchaseLine(var SalesLine: Record "Sales Line");
    var
        SalesHeader: Record "Sales Header";
        PurchaseLine: Record "Purchase Line";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        PurchaseLine.Get(PurchaseLine."Document Type"::Order, SalesHeader."Automate Purch.Doc No.", SalesLine."Line No.");
        PurchaseLine.Delete();
    end;

    local procedure DeleteICSalesLine(var SalesLine: Record "Sales Line");
    var
        ICSalesHeader: Record "Sales Header";
        ICSalesLine: Record "Sales Line";
    begin
        ICSalesHeader.ChangeCompany(InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
        ICSalesHeader.FindSet();
        ICSalesLine.ChangeCompany(InventoryCompany());
        ICSalesLine.Get(SalesLine."Document Type", ICSalesHeader."No.", SalesLine."Line No.");
        ICSalesLine.Delete();
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnDeleteBOMPurchIC', '', false, false)]
    local procedure DeleteBOM_Purch_IC(var SalesLine: Record "Sales Line");
    var
        ICSalesHeader: Record "Sales Header";
        ExistIC: Boolean;
    begin
        ExistIC := false;
        if ICSalesHeader.ChangeCompany(InventoryCompany()) then begin
            ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
            if ICSalesHeader.FindSet() then
                ExistIC := true;
        end;
        DeleteBOMSalesLine(SalesLine);
        DeletePurchaseLine(SalesLine);
        if ExistIC then
            DeleteICSalesLine(SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreateSalesDocument', '', false, false)]
    local procedure AfterCreateSalesDocument(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header"; HandledICInboxSalesHeader: Record "Handled IC Inbox Sales Header");
    var
        RetailSalesHeader: Record "Sales Header";
        RetailSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        TempDeliveryItem: Text[200];
        TempDeliveryItemWithoutBOM: Text[200];
        TempCubage: Decimal;
        TempAssemble: Boolean;
        TempAssembleHour: Decimal;
        ZoneCode: Record ZoneTable;
        TempAssemblyItem: Text[200];
        TempAssemblyItemWithoutBOM: Text[200];

    begin
        TempAssemble := false;
        RetailSalesHeader.ChangeCompany(SalesHeader."Sell-to Customer Name");
        RetailSalesHeader.SetRange("Automate Purch.Doc No.", SalesHeader."External Document No.");
        RetailSalesHeader.FindSet();

        RetailSalesHeader.CalcFields("Work Description");
        SalesHeader."Work Description" := RetailSalesHeader."Work Description";
        SalesHeader."Location Code" := RetailSalesHeader."Location Code";
        SalesHeader."Requested Delivery Date" := RetailSalesHeader."Requested Delivery Date";
        SalesHeader."Promised Delivery Date" := RetailSalesHeader."Promised Delivery Date";
        SalesHeader."Sell-to Contact" := RetailSalesHeader."Sell-to Contact";
        SalesHeader."Sell-to Phone No." := RetailSalesHeader."Sell-to Phone No.";
        SalesHeader.RetailSalesHeader := RetailSalesHeader."No.";
        SalesHeader."Ship-to Phone No." := RetailSalesHeader."Ship-to Phone No.";
        SalesHeader."Ship-to City" := RetailSalesHeader."Ship-to City";
        ZoneCode."Order Price" := SalesHeader.Amount;
        if ZoneCode.Find('>') then
            SalesHeader.ZoneCode := ZoneCode.Code;


        RetailSalesLine.ChangeCompany(SalesHeader."Sell-to Customer Name");
        RetailSalesLine.SetRange("Document Type", RetailSalesHeader."Document Type");
        RetailSalesLine.SetRange("Document No.", RetailSalesHeader."No.");
        if RetailSalesLine.FindSet() then
            repeat
                if IsValideICSalesLine(RetailSalesLine) then begin
                    SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", RetailSalesLine."Line No.");
                    SalesLine."Location Code" := RetailSalesLine."Location Code";
                    SalesLine."BOM Item" := RetailSalesLine."BOM Item";
                    if RetailSalesLine.NeedAssemble then
                        TempAssemblyItem := TempAssemblyItem + 'Yes' + '\'
                    else
                        TempAssemblyItem := TempAssemblyItem + 'No' + '\';
                    TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + '\';
                    if SalesLine."BOM Item" = false then begin
                        TempDeliveryItemWithoutBOM := TempDeliveryItemWithoutBOM + Format(SalesLine.Quantity) + '*' + SalesLine.Description + '\';
                        if RetailSalesLine.NeedAssemble then
                            TempAssemblyItemWithoutBOM := TempAssemblyItemWithoutBOM + 'Yes' + '\'
                        else
                            TempAssemblyItemWithoutBOM := TempAssemblyItemWithoutBOM + 'No' + '\';
                    end;
                    TempCubage := TempCubage + SalesLine."Unit Volume" * SalesLine.Quantity;
                    TempAssembleHour := TempAssembleHour + SalesLine.AssemblyHour;
                    if SalesLine.NeedAssemble = true then
                        TempAssemble := true;
                    SalesLine.Modify();
                end;
            until RetailSalesLine.Next() = 0;
        SalesHeader."Estimate Assembly Time(hour)" := TempAssembleHour;
        // SalesHeader.Note := GetWorkDescription(RetailSalesHeader);
        SalesHeader.NeedAssemble := TempAssemble;
        SalesHeader.Cubage := TempCubage;
        SalesHeader."Delivery Item" := TempDeliveryItem;
        SalesHeader."Delivery without BOM Item" := TempDeliveryItemWithoutBOM;
        SalesHeader."Assembly Item without BOM Item" := TempAssemblyItemWithoutBOM;
        SalesHeader.Delivery := RetailSalesHeader.Delivery;
        SalesHeader."Assembly Item" := TempAssemblyItem;
        SalesHeader.Modify();
        ReleaseSalesDoc.PerformManualRelease(SalesHeader);
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
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            NoSeriesCode := PurchPaySetup."Order Nos."
        else
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                NoSeriesCode := PurchPaySetup."Return Order Nos.";
        NoSeries.Get(NoSeriesCode);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);

        if NoSeriesLine.FindSet() = false then
            Error('Please Create No series line in Purchase & Payable setup');
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

    [EventSubscriber(ObjectType::Table, 37, 'onUpdatePurchICBOM', '', false, false)]
    local procedure UpdatePurchICBOM(var SalesLine: Record "Sales Line");
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
    begin
        UpdateBOMSalesLine(SalesLine);
        if SalesLine.CurrentCompany <> 'HEQS International Pty Ltd' then begin
            UpdatePurchLine(SalesLine);
            UpdateICSalesLine(SalesLine);
        end;

    end;

    [EventSubscriber(ObjectType::Table, 5741, 'onUpdateBOM', '', false, false)]
    local procedure UpdateBOM(var TransferLine: Record "Transfer Line");
    begin
        if TransferLine."BOM Item" <> true then
            UpdateBOMTransferLine(TransferLine);
    end;

    local procedure UpdateBOMTransferLine(var TransferLine: Record "Transfer Line");
    var
        BOMComponent: Record "BOM Component";
        BOMTransferLine: Record "Transfer Line";
    begin
        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", TransferLine."Item No.");
        if BOMComponent.FindSet() then
            repeat
                BOMTransferLine.Reset();
                BOMTransferLine.SetRange("Document No.", TransferLine."Document No.");
                BOMTransferLine.SetRange("Item No.", BOMComponent."No.");
                BOMTransferLine.SetRange("BOM Item", true);
                BOMTransferLine.SetRange("Main Item Line", TransferLine."Line No.");
                if BOMTransferLine.FindSet() then
                    repeat
                        BOMTransferLine.Validate(Quantity, TransferLine.Quantity * BOMComponent."Quantity per");
                        BOMTransferLine.Modify();
                    until BOMTransferLine.Next() = 0;
            until BOMComponent.Next() = 0;
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
                BOMSalesLine.SetRange("Main Item Line", SalesLine."Line No.");
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
        NeedRecursion: Boolean;
    begin
        Item.Get(SalesLine."No.");
        if Item.Type = Item.Type::Service then
            exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");

        TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
        TempSalesLine.SetRange("Document No.", SalesLine."Document No.");

        if TempSalesLine.FindSet() then
            repeat
                if PurchaseLine.Get(TempSalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", TempSalesLine."Line No.") = false then begin
                    InsertPurchaseLine(TempSalesLine);
                end
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


    [EventSubscriber(ObjectType::Table, 37, 'onInsertPurchICBOM', '', false, false)]
    local procedure InsertPurchICBOM(var SalesLine: Record "Sales Line");
    begin
        if SalesLine.CurrentCompany = InventoryCompanyName then
            ExplodeBOM(SalesLine);
        if (SalesLine.CurrentCompany <> InventoryCompanyName) and (SalesLine.Type = SalesLine.Type::Item) then begin
            InsertPurchaseLine(SalesLine);
            CreateICSalesLine(SalesLine);
            ExplodeBOM(SalesLine);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'onInsertBOM', '', false, false)]
    local procedure InsertBOM(var TransferLine: Record "Transfer Line");
    begin
        if TransferLine.CurrentCompany = InventoryCompanyName then
            ExplodeTransferBOM(TransferLine);
    end;

    local procedure ExplodeTransferBOM(TransferLine: Record "Transfer Line");
    var
        Item: Record Item;
        TempLineNo: Integer;
        TransferHeader: Record "Transfer Header";
        BOMComponent: Record "BOM Component";
        LineSpacing: Integer;
        ToTransferLine: Record "Transfer Line";
        NextLineNo: Integer;
    begin
        // Find Line No
        TransferHeader.Reset();
        TransferHeader.Get(TransferLine."Document No.");
        TempLineNo := TransferLine."Line No.";
        ToTransferLine.Reset();
        ToTransferLine.SetRange("Document No.", TransferLine."Document No.");
        ToTransferLine."Document No." := TransferLine."Document No.";
        NextLineNo := TransferLine."Line No.";
        if ToTransferLine.FindLast() then
            if ToTransferLine."Line No." >= NextLineNo then
                NextLineNo := ToTransferLine."Line No.";
        LineSpacing := 10000;
        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", TransferLine."Item No.");
        if BOMComponent.FindSet then
            repeat
                ToTransferLine.Init();
                NextLineNo := NextLineNo + LineSpacing;
                ToTransferLine."Line No." := NextLineNo;

                Item.Get(BOMComponent."No.");
                // ToTransferLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
                ToTransferLine.Validate(Quantity, TransferLine.Quantity * BOMComponent."Quantity per");

                if TransferHeader."Shipment Date" <> TransferLine."Shipment Date" then
                    ToTransferLine.Validate("Shipment Date", TransferLine."Shipment Date");
                ToTransferLine.Description := BOMComponent.Description;

                // Modify Place, Only Give Item Type
                ToTransferLine."Document No." := TransferLine."Document No.";
                ToTransferLine.Validate("Item No.", BOMComponent."No.");
                ToTransferLine."BOM Item" := true;
                ToTransferLine."Main Item Line" := TransferLine."Line No.";
                ToTransferLine.Insert();
            until BOMComponent.Next = 0;

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
                ToSalesLine."Main Item Line" := SalesLine."Line No.";
                ToSalesLine.Insert();

                if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine.Reserve = ToSalesLine.Reserve::Always) then
                    ToSalesLine.AutoReserve();


                InsertPurchaseLine(ToSalesLine);
                CreateICSalesLine(ToSalesLine);
            until BOMComponent.Next = 0;

    end;

    local procedure IsValideICSalesLine(var SalesLine: Record "Sales Line"): Boolean;
    var
        IsValid: Boolean;
        Item: Record Item;
    begin
        IsValid := false;
        if SalesLine.Type = SalesLine.Type::Item then begin
            Item.Get(SalesLine."No.");
            if Item.Type = Item.Type::Inventory then IsValid := true;
        end;

        exit(IsValid);
    end;

    local procedure InsertPurchaseLine(SalesLine: Record "Sales Line");
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        Vendor: Record Vendor;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        IsMainItem: Boolean;
    begin
        if IsValideICSalesLine(SalesLine) = false then exit;

        Item.Get(SalesLine."No.");

        Vendor."Search Name" := 'HEQS INTERNATIONAL PTY LTD';
        Vendor.FindSet();

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");
        PurchaseLine.Reset();
        PurchaseLine.Init();
        PurchaseLine."Document Type" := SalesLine."Document Type";
        PurchaseLine."Document No." := SalesHeader."Automate Purch.Doc No.";
        PurchaseLine."Line No." := SalesLine."Line No.";
        PurchaseLine.Type := SalesLine.Type;
        PurchaseLine.Validate("No.", SalesLine."No.");
        PurchaseLine."BOM Item" := SalesLine."BOM Item";
        PurchaseLine.Validate(Quantity, SalesLine.Quantity);
        PurchaseLine.Insert();
        if (Item."Unit Cost" = 0) and (PurchaseLine."BOM Item" = false) then
            Error('Please Set Purchase Price for item %1', Item."No.");
    end;

    local procedure CreateICSalesLine(SalesLine: Record "Sales Line");
    var
        ICSalesLine: Record "Sales Line";
        ICSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
    begin
        if IsValideICSalesLine(SalesLine) = false then exit;

        Item.Get(SalesLine."No.");

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
            ICSalesLine.Validate("No.", SalesLine."No.");
            ICSalesLine."Location Code" := SalesLine."Location Code";
            ICSalesLine."BOM Item" := SalesLine."BOM Item";
            ICSalesLine.Insert();
        end;

    end;

    procedure InventoryCompany(): Text;
    begin
        exit(InventoryCompanyName);
    end;
}