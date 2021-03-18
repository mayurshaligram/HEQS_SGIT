codeunit 50101 "Sales Truth Mgt"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    // OnAfterInsert Trigger
    [EventSubscriber(ObjectType::Table, 36, 'OnCreatePurchaseOrder', '', false, false)]
    local procedure CreatePurchaseOrder(var SalesHeader: Record "Sales Header");
    var
        TempText: Text;
        PurchPaySetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        PurchaseOrder: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        if SalesHeader.CurrentCompany <> InventoryCompanyName then begin
            PurchPaySetup.Get('');
            NoSeriesCode := PurchPaySetup."Order Nos.";
            NoSeries.Get(NoSeriesCode);
            NoSeriesLine.SetRange("Series Code", NoSeries.Code);

            if NoSeriesLine.FindSet() = false then
                Error('Please Create No series line');
            begin
                PurchaseOrder.Init();
                PurchaseOrder."Document Type" := SalesHeader."Document Type";
                PurchaseOrder."No." := NoSeriesMgt.DoGetNextNo(NoSeries.Code, System.Today(), true, true);
                PurchaseOrder."Sales Order Ref" := SalesHeader."No.";
                TempText := 'HEQS INTERNATIONAL PTY LTD';
                Vendor."Search Name" := TempText;
                Vendor.FindSet();
                PurchaseOrder."Buy-from Vendor No." := Vendor."No.";
                PurchaseOrder."Buy-from Vendor Name" := Vendor.Name;
                PurchaseOrder.Insert();
                SalesHeader.UpdatePurchaseHeader(PurchaseOrder);
                SalesHeader."Automate Purch.Doc No." := PurchaseOrder."No.";
                SalesHeader.Modify();
            end;
        end
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
        PurchaseLine.Insert();
        if (PurchaseLine."Direct Unit Cost" = 0) and (PurchaseLine."BOM Item" = false) then
            Error('Please Set Purchase Price for item %1', Item."No.");
    end;

    local procedure CreateICSalesLine(SalesLine: Record "Sales Line");
    var
        ICSalesLine: Record "Sales Line";
        ICSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
    begin
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
        end;

    end;
}