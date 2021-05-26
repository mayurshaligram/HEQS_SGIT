codeunit 50101 "Sales Truth Mgt"
{
    Permissions = TableData "Sales Invoice Header" = imd,
                    TableData "Purch. Inv. Header" = imd;
    EventSubscriberInstance = StaticAutomatic;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    //////////////////////////////////////////////////////////////
    /// 
    /// Sales Header:             Inventory Fiex Reopen Measure of Unit
    ///     BOM Item Fixed;
    ///     Main Item Fixed;
    ///     
    /// Purchase Header:
    ///     BOM Item Fixed;
    /// 
    /// 
    /// 
    /// //////////////////////////////////////////////////////////
    /// 
    procedure ReturnAutoPost(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        InventorySalesOrder: Record "Sales Header";
        SessionId: Integer;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NoSeries: Record "No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailSalesLine: Record "Sales Line";
        VendorInvoiceNo: Code[20];
        TempText: Text[20];
        TempNum: Text[20];
        TempInteger: Integer;
        TempSalesLine: Record "Sales Line";
        TempItem: Record Item;
        IsValideIC: Boolean;
        Text1: Label 'Please only post invoice in the retail company %1';

        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        // Only the Sales Header associated with more then one inventory item sale line could be pass
        Shipped: Boolean;
    begin
        Shipped := false;
        if SalesHeader.CurrentCompany = InventoryCompany() then
            Error(Text1, SalesHeader."Sell-to Customer Name");
        IsValideIC := false;
        TempSalesLine.SetRange("Document No.", SalesHeader."No.");
        TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
        if TempSalesLine.FindSet() then
            repeat
                TempItem.Get(TempSalesLine."No.");
                if TempItem.Type = TempItem.Type::Inventory then IsValideIC := true;
                if TempSalesLine."Quantity Shipped" <> 0 then Shipped := true;
                if TempSalesLine."Document Type" = TempSalesLine."Document Type"::"Return Order" then
                    if TempSalesLine."Return Qty. Received" <> 0 then Shipped := true;
            ////////
            /// 
            ///  Test the Sales line  has Quantity to Shpment
            ///     
            /// //
            until TempSalesLine.Next() = 0;

        if IsValideIC = false then Error('Please Only use the normal Posting');
        if Shipped = false then Error('This Order has nothing to post');


        PostedSalesCrMemoHeader.ChangeCompany('HEQS International Pty Ltd');
        if PostedSalesCrMemoHeader.FindLast() then begin
            VendorInvoiceNo := PostedSalesCrMemoHeader."No.";

            TempText := Format(VendorInvoiceNo);
            TempNum := TempText.Substring(6);
            Evaluate(TempInteger, TempNum);
            TempInteger += 1;
            VendorInvoiceNo := 'INTAD' + Format(TempInteger);
        end
        else
            VendorInvoiceNo := 'INTAD100001';

        PurchCrMemoHdr.Reset();
        if PurchCrMemoHdr.FindLast() then
            if VendorInvoiceNo = PurchCrMemoHdr."Vendor Cr. Memo No." then begin
                VendorInvoiceNo := VendorInvoiceNo + '*';
            end;



        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Sales Order Ref", SalesHeader."No.");
        if PurchaseHeader.FindSet() and (VendorInvoiceNo <> '') then begin
            PurchaseHeader."Due Date" := SalesHeader."Due Date";

            PurchaseHeader."Gen. Bus. Posting Group" := 'DOMESTIC';
            PurchaseHeader.Modify();

            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseLine.FindSet() then
                repeat
                    PurchaseLine."Gen. Bus. Posting Group" := 'DOMESTIC';
                    PurchaseLine.Modify();
                until PurchaseLine.Next() = 0;

            NoSeries.ChangeCompany(InventoryCompany());
            NoSeries.Get('S-INV+');
            PurchaseHeader."Vendor Cr. Memo No." := VendorInvoiceNo;
            PurchaseHeader.Modify();
            Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", PurchaseHeader);
        end;

        Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext Inv", SalesHeader);

        SessionId := 51;
        InventorySalesOrder.Reset();
        InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
        InventorySalesOrder.SetRange("Document Type", SalesHeader."Document Type");
        InventorySalesOrder.SetRange(RetailSalesHeader, SalesHeader."No.");

        if InventorySalesOrder.FindLast() then
            StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext Inv",
                                       'HEQS International Pty Ltd', InventorySalesOrder);

    end;

    procedure AutoPost(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        InventorySalesOrder: Record "Sales Header";
        SessionId: Integer;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedSalesInvoiceHeader: Record "Sales Invoice Header";
        NoSeries: Record "No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailSalesLine: Record "Sales Line";
        VendorInvoiceNo: Code[20];
        TempText: Text[20];
        TempNum: Text[20];
        TempInteger: Integer;
        TempSalesLine: Record "Sales Line";
        TempItem: Record Item;
        IsValideIC: Boolean;
        Text1: Label 'Please only post invoice in the retail company %1';

        PostedPurchaseInvoice: Record "Purch. Inv. Header";
        // Only the Sales Header associated with more then one inventory item sale line could be pass
        Shipped: Boolean;
    begin
        Shipped := false;
        if SalesHeader.CurrentCompany = InventoryCompany() then
            Error(Text1, SalesHeader."Sell-to Customer Name");
        IsValideIC := false;
        TempSalesLine.SetRange("Document No.", SalesHeader."No.");
        TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
        if TempSalesLine.FindSet() then
            repeat
                TempItem.Get(TempSalesLine."No.");
                if TempItem.Type = TempItem.Type::Inventory then IsValideIC := true;
                if TempSalesLine."Quantity Shipped" <> 0 then Shipped := true;
                if TempSalesLine."Document Type" = TempSalesLine."Document Type"::"Return Order" then
                    if TempSalesLine."Return Qty. Received" <> 0 then Shipped := true;
            ////////
            /// 
            ///  Test the Sales line  has Quantity to Shpment
            ///     
            /// //
            until TempSalesLine.Next() = 0;



        if IsValideIC = false then Error('Please Only use the normal Posting');
        if Shipped = false then Error('This Order has nothing to post');

        PostedSalesInvoiceHeader.ChangeCompany('HEQS International Pty Ltd');
        if PostedSalesInvoiceHeader.FindLast() then begin
            VendorInvoiceNo := PostedSalesInvoiceHeader."No.";

            TempText := Format(VendorInvoiceNo);
            TempNum := TempText.Substring(7);
            Evaluate(TempInteger, TempNum);
            TempInteger += 1;
            VendorInvoiceNo := 'INTPSI' + Format(TempInteger);
        end
        else
            VendorInvoiceNo := 'INTPSI100000';

        PostedPurchaseInvoice.Reset();
        if PostedPurchaseInvoice.FindLast() then
            if VendorInvoiceNo = PostedPurchaseInvoice."Vendor Invoice No." then begin
                VendorInvoiceNo := VendorInvoiceNo + '*';
            end;


        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Sales Order Ref", SalesHeader."No.");
        if PurchaseHeader.FindSet() and (VendorInvoiceNo <> '') then begin
            PurchaseHeader."Due Date" := SalesHeader."Due Date";

            PurchaseHeader."Gen. Bus. Posting Group" := 'DOMESTIC';
            PurchaseHeader.Modify();

            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseLine.FindSet() then
                repeat
                    PurchaseLine."Gen. Bus. Posting Group" := 'DOMESTIC';
                    PurchaseLine.Modify();
                until PurchaseLine.Next() = 0;

            NoSeries.ChangeCompany(InventoryCompany());
            NoSeries.Get('S-INV+');
            PurchaseHeader."Vendor Invoice No." := VendorInvoiceNo;
            PurchaseHeader.Modify();
            Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", PurchaseHeader);
        end;


        Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext Inv", SalesHeader);

        SessionId := 51;
        InventorySalesOrder.Reset();
        InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
        InventorySalesOrder.SetRange("Document Type", SalesHeader."Document Type");
        InventorySalesOrder.SetRange(RetailSalesHeader, SalesHeader."No.");

        if InventorySalesOrder.FindLast() then
            StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext Inv",
                                       'HEQS International Pty Ltd', InventorySalesOrder);



    end;

    procedure QuickFix(var SalesHeader: Record "Sales Header");
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        BOMSalesLine: Record "Sales Line";
        BOMComponent: Record "BOM Component";
        TempLineNo: Integer;
        WhseShipLine: Record "Warehouse Shipment Line";
        PostWhseShipLine: Record "Posted Whse. Shipment Line";
        TempPrice: Decimal;

        PurchaseLine: Record "Purchase Line";
        ICSalesHeader: Record "Sales Header";
        RetailSalesLine: Record "Sales Line";
    begin
        if SalesLine.CurrentCompany <> InventoryCompany() then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("BOM Item", false);

            if SalesLine.FindSet() then begin
                repeat
                    TempLineNo := SalesLine."Line No.";
                    Item.Get(SalesLine."No.");
                    if Item.Type = Item.Type::Inventory then begin
                        BOMComponent.SetRange("Parent Item No.", Item."No.");
                        if BOMComponent.FindSet() then
                            repeat
                                TempLineNo += 10000;
                                BOMSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo);
                                BOMSalesLine."BOM Item" := true;
                                BOMSalesLine."Main Item Line" := SalesLine."Line No.";
                                BOMSalesLine.Modify();
                            until BOMComponent.Next() = 0;
                    end;
                until SalesLine.Next() = 0;
            end;
        end
        else begin
            WhseShipLine.Reset();
            PostWhseShipLine.Reset();

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet() then begin
                WhseShipLine.SetRange("Source No.", SalesLine."Document No.");
                PostWhseShipLine.SetRange("Source No.", SalesLine."Document No.");
                if (WhseShipLine.FindSet() = false) and (PostWhseShipLine.FindSet() = false) then
                    repeat
                        TempPrice := SalesLine."Unit Price";
                        SalesLine.Validate(SalesLine."No.");
                        SalesLine.Validate("Unit Price", TempPrice);
                        SalesLine.Modify(true);
                    until SalesLine.Next() = 0;
            end;

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet() then
                repeat
                    // if SalesLine."Unit Price" = 0 then begin
                    if ICSalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") = false then
                        exit;

                    PurchaseLine.Reset();
                    PurchaseLine.ChangeCompany(ICSalesHeader."Sell-to Customer Name");
                    if PurchaseLine.Get(SalesLine."Document Type", ICSalesHeader."External Document No.", SalesLine."Line No.") = false then
                        exit;
                    SalesLine.Validate("Unit Price", PurchaseLine."Direct Unit Cost");
                    SalesLine."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                    RetailSalesLine.Reset();
                    RetailSalesLine.ChangeCompany(ICSalesHeader."Sell-to Customer Name");
                    if RetailSalesLine.Get(SalesLine."Document Type", ICSalesHeader.RetailSalesHeader, SalesLine."Line No.") = false then
                        exit;
                    SalesLine.NeedAssemble := RetailSalesLine.NeedAssemble;
                    SalesLine.Modify();
                // end;
                until SalesLine.Next() = 0;
        end;
    end;


    // Helper Function to Assign BOM to Purchase Line
    procedure BOMAssignPurchase(var PurchaseHeader: Record "Purchase Header");
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        BOMPurchaseLine: Record "Purchase Line";
        BOMComponent: Record "BOM Component";
        TempLineNo: Integer;
        TempPrice: Decimal;
    begin
        if PurchaseLine.CurrentCompany <> InventoryCompany() then begin
            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetRange("BOM Item", false);

            if PurchaseLine.FindSet() then begin
                repeat
                    TempLineNo := PurchaseLine."Line No.";
                    Item.Get(PurchaseLine."No.");
                    if Item.Type = Item.Type::Inventory then begin
                        BOMComponent.SetRange("Parent Item No.", Item."No.");
                        if BOMComponent.FindSet() then
                            repeat
                                TempLineNo += 10000;
                                BOMPurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", TempLineNo);
                                BOMPurchaseLine."BOM Item" := true;
                                BOMPurchaseLine.Modify();
                            until BOMComponent.Next() = 0;
                    end;
                until PurchaseLine.Next() = 0;
            end;
        end;
    end;

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

    procedure DeleteBOMSalesLine(Var SalesLine: Record "Sales Line");
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
                if BOMPurchaseLine.Get(BOMSalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", BOMSalesLine."Line No.") then
                    BOMPurchaseLine.Delete();
                if ExistIC then begin
                    BOMICSalesLine.ChangeCompany(InventoryCompany());
                    if BOMICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", BOMSalesLine."Line No.") then
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
        if PurchaseLine.Get(SalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", SalesLine."Line No.") then
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

    // OnBeforeCreateShptHeader(WhseShptHeader, "Warehouse Request", "Sales Line", IsHandled, Location, WhseShptLine, ActivitiesCreated, WhseHeaderCreated, RequestType);
    [EventSubscriber(ObjectType::Report, 5753, 'OnBeforeCreateShptHeader', '', false, false)]
    local procedure BeforeCreateShptHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request"; SalesLine: Record "Sales Line"; var IsHandled: Boolean; Location: Record Location; var WhseShptLine: Record "Warehouse Shipment Line"; var ActivitiesCreated: Integer; var WhseHeaderCreated: Boolean; var RequestType: Option Receive,Ship);
    var
        SalesHeader: Record "Sales Header";
        TempStatus: Enum "Sales Document Status";
    begin
        if (SalesLine.CurrentCompany = InventoryCompany()) and (SalesLine."Document Type" = SalesLine."Document Type"::Order) then begin
            if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then begin
                TempStatus := SalesHeader.Status;
                SalesHeader.Status := SalesHeader.Status::Open;
                SalesHeader.Modify();
                QuickFix(SalesHeader);
                SalesHeader.Status := TempStatus;
                SalesHeader.Modify();
            end;
        end;
    end;

    // OnBeforeCreateShptHeader(WhseShptHeader, "Warehouse Request", "Sales Line", IsHandled, Location, WhseShptLine, ActivitiesCreated, WhseHeaderCreated, RequestType);
    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateShipmentDate', '', false, false)]
    local procedure BeforeValidateShipmentDate(var IsHandled: boolean);
    begin
        IsHandled := true;
    end;



    //     [IntegrationEvent(false, false)]
    // local procedure OnBeforeWarehouseRequestOnAfterGetRecord(var WarehouseRequest: Record "Warehouse Request"; var WhseHeaderCreated: Boolean; var SkipRecord: Boolean; var BreakReport: Boolean; RequestType: Option Receive,Ship; var WhseReceiptHeader: Record "Warehouse Receipt Header"; var WhseShptHeader: Record "Warehouse Shipment Header"; OneHeaderCreated: Boolean)
    // begin
    // end;

    [EventSubscriber(ObjectType::Report, 5753, 'OnBeforeWarehouseRequestOnAfterGetRecord', '', false, false)]
    local procedure BeforeWarehouseRequestOnAfterGetRecord(var WarehouseRequest: Record "Warehouse Request"; var WhseHeaderCreated: Boolean; var SkipRecord: Boolean; var BreakReport: Boolean; RequestType: Option Receive,Ship; var WhseReceiptHeader: Record "Warehouse Receipt Header"; var WhseShptHeader: Record "Warehouse Shipment Header"; OneHeaderCreated: Boolean)
    var
        SalesHeader: Record "Sales Header";
        TempStatus: Enum "Sales Document Status";
    begin
        if (WarehouseRequest.CurrentCompany = InventoryCompany()) then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("No.", WarehouseRequest."Source No.");
            if SalesHeader.FindSet() then begin
                TempStatus := SalesHeader.Status;
                SalesHeader.Status := SalesHeader.Status::Open;
                SalesHeader.Modify();
                QuickFix(SalesHeader);
                SalesHeader.Status := TempStatus;
                SalesHeader.Modify();
            end;
        end;
    end;
    // var

    // begin

    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeSendICDocument(var SalesHeader: Record "Sales Header"; var ModifyHeader: Boolean; var IsHandled: Boolean)
    // begin
    // end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnFinalizePostingOnBeforeCreateOutboxSalesTrans', '', false, false)]
    local procedure FinalizePostingOnBeforeCreateOutboxSalesTrans(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; EverythingInvoiced: Boolean)
    begin
        if SalesHeader.CurrentCompany = InventoryCompany() then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterFinalizePosting', '', false, false)]
    local procedure OnAfterFinalizePosting(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    begin
        if PurchInvHeader."No." <> '' then begin
            PurchInvHeader."Vendor Shipment No." := PurchHeader."Vendor Shipment No.";
            PurchInvHeader.Modify();
        end;
    end;

    // [IntegrationEvent(false, false)]
    // local procedure OnAfterFinalizePosting(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    // begin
    // end;

    //     [IntegrationEvent(false, false)]
    // local procedure OnAfterPurchInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean)
    // begin
    // end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPurchInvLineInsert', '', false, false)]
    local procedure AfterPurchInvLineInsertvar(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean)
    var
        Payable: Record Payable;
        PostedWhseReceiptHeader: Record "Posted Whse. Receipt Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        Payable.Reset();
        Payable.ChangeCompany(InventoryCompany());
        if Payable.Get(PurchLine."Document No.") then begin
            Payable."Posted Invoice No" := PurchInvHeader."No.";
            Payable."USD" := PurchInvHeader."Remaining Amount";
            Payable.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5764, 'OnAfterConfirmPost', '', false, false)]
    local procedure AfterConfirmPost(WhseShipmentLine: Record "Warehouse Shipment Line"; Invoice: Boolean)
    var
        RetailPurchaseOrder: Record "Purchase Header";
        RetailSalesOrder: Record "Sales Header";
        RetailSalesOrderPage: Page "Sales Order";
        SessionID: Integer;
        Temp: Text;

        InventorySalesHeader: Record "Sales Header";
        OK: Boolean;
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        WarehouseLine: Record "Warehouse Shipment Line";

        InventorySalesLine: Record "Sales Line";
        RetailSalesLine: Record "Sales Line";
        RetailPurchaseHeader: Record "Purchase Header";
        RetailPurchaseLine: Record "Purchase Line";

        WhseShipmentLineLocal: Record "Warehouse Shipment Line";
        TempCode: Code[20];
        Continue: Boolean;
        WhseShipment: Record "Warehouse Shipment Header";
        Counter: Integer;
    begin
        WhseShipment.Get(WhseShipmentLine."No.");
        If WhseShipment.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
            WhseShipmentLineLocal.Reset();
            WhseShipmentLineLocal.SetRange("No.", WhseShipment."No.");
            if (WhseShipmentLineLocal.FindSet()) and (TempCode <> WhseShipmentLineLocal."Source No.") then begin
                repeat
                    InventorySalesHeader.SetRange("No.", WhseShipmentLineLocal."Source No.");
                    if InventorySalesHeader.FindSet() then begin
                        RetailSalesOrder.Reset();
                        RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
                        RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
                        if RetailSalesOrder.FindSet() then begin
                            RetailPurchaseHeader.Reset();
                            RetailPurchaseHeader.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
                            RetailPurchaseHeader.SetRange("No.", InventorySalesHeader."External Document No.");
                            if RetailPurchaseHeader.FindSet() then begin
                                InventorySalesLine.SetRange("Document Type", InventorySalesHeader."Document Type");
                                InventorySalesLine.SetRange("Document No.", InventorySalesHeader."No.");
                                // if InventorySalesLine.FindSet() then
                                //     repeat
                                //         RetailPurchaseLine.Reset();
                                //         RetailPurchaseLine.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
                                //         RetailPurchaseLine.Get(InventorySalesHeader."Document Type", RetailPurchaseHeader."No.", InventorySalesLine."Line No.");
                                //         RetailPurchaseLine."Quantity Received" := InventorySalesLine."Quantity Shipped";
                                //         RetailPurchaseLine."Qty. to Receive" := RetailPurchaseLine."Qty. to Receive" - RetailPurchaseLine."Quantity Received";
                                //         RetailPurchaseLine."Qty. to Invoice" := InventorySalesLine."Qty. to Invoice";
                                //         RetailPurchaseLine.Modify();

                                //     until InventorySalesLine.Next() = 0;


                                InventorySalesHeader."External Document No." := '';
                                InventorySalesHeader.Modify();

                                RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
                                RetailSalesOrder.Modify();

                                // SessionID := 50 + Counter;
                                // StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);
                            end;
                        end;
                    end;
                    TempCode := WhseShipmentLineLocal."Source No.";
                    Counter := Counter + 1;
                until WhseShipmentLineLocal.Next() = 0;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopySalesDocOnAfterCopySalesDocLines', '', false, false)]
    local procedure CopySalesDocOnAfterCopySalesDocLines(FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; FromSalesHeader: Record "Sales Header"; IncludeHeader: Boolean; var ToSalesHeader: Record "Sales Header")
    begin
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterSelltoCustomerNoOnAfterValidate', '', false, false)]
    local procedure AfterSelltoCustomerNoOnAfterValidate(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TempLineNo: Integer;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        BOMSalesLine: Record "Sales Line";
    begin
        if SalesLine.CurrentCompany <> InventoryCompany() then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("BOM Item", false);

            if SalesLine.FindSet() then begin
                repeat
                    TempLineNo := SalesLine."Line No.";
                    Item.Get(SalesLine."No.");
                    if Item.Type = Item.Type::Inventory then begin
                        BOMComponent.SetRange("Parent Item No.", Item."No.");
                        if BOMComponent.FindSet() then
                            repeat
                                TempLineNo += 10000;
                                BOMSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo);
                                BOMSalesLine."BOM Item" := true;
                                BOMSalesLine."Main Item Line" := SalesLine."Line No.";
                                BOMSalesLine.Modify();
                            until BOMComponent.Next() = 0;
                    end;
                until SalesLine.Next() = 0;
            end;

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("BOM Item", false);
            if SalesLine.FindSet() then
                repeat
                    if IsValideICSalesLine(SalesLine) then
                        SalesLine.Modify(true);
                until SalesLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5752, 'OnAfterGetSingleOutboundDoc', '', false, false)]
    local procedure AfterGetSingleOutboundDoc(var WarehouseShipmentHeader: Record "Warehouse Shipment Header");
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
    begin
        if (WarehouseShipmentHeader.CurrentCompany = InventoryCompanyName) then begin
            WhseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
            if WhseShipmentLine.FindSet() then
                repeat
                    if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                        SalesHeader.Get(SalesHeader."Document Type"::Order, WhseShipmentLine."Source No.");
                        WhseShipmentLine."Original SO" := SalesHeader.RetailSalesHeader;
                        WhseShipmentLine.Modify();
                    end;
                until WhseShipmentLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5752, 'OnBeforeGetSingleOutboundDoc', '', false, false)]
    local procedure OnBeforeGetSingleOutboundDoc(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var IsHandled: Boolean);
    var
        SalesHeader: Record "Sales Header";
        WhseRequestMgt: Codeunit WhseRequestMgt;
    begin
        SalesHeader.SetRange("Location Code", WarehouseShipmentHeader."Location Code");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                WhseRequestMgt.ValidateWhseRequest(SalesHeader);
            until SalesHeader.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure BeforeSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean);
    begin
        SalesInvLine."BOM Item" := SalesLine."BOM Item";
    end;

    [EventSubscriber(ObjectType::Codeunit, 63, 'OnBeforeOnRun', '', false, false)]
    local procedure BeforeOnRun(var SalesLine: Record "Sales Line"; var IsHandled: Boolean);
    begin
        DeleteBOMSalesLine(SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 63, 'OnExplodeBOMCompLinesOnAfterToSalesLineInsert', '', false, false)]
    local procedure ExplodeBOMCompLinesOnAfterToSalesLineInsert(ToSalesLine: Record "Sales Line"; SalesLine: Record "Sales Line"; FromBOMComp: Record "BOM Component");
    begin
        InsertPurchaseLineWithoutPriceCheck(ToSalesLine);
        if ExistIC(ToSalesLine) then
            CreateICSalesLine(ToSalesLine);
    end;

    local procedure ExistIC(var SalesLine: Record "Sales Line"): Boolean;
    var
        ICSalesHeader: Record "Sales Header";
        ExistIC: Boolean;
    begin
        ExistIC := false;
        ICSalesHeader.ChangeCompany(InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
        if ICSalesHeader.FindSet() then
            ExistIC := true;
        exit(ExistIC);
        // Update Shipment
        // Update Schedules
    end;


    [EventSubscriber(ObjectType::Codeunit, 63, 'OnAfterOnRun', '', false, false)]
    local procedure AfterOnRun(ToSalesLine: Record "Sales Line"; SalesLine: Record "Sales Line")
    var
        ICSalesHeader: Record "Sales Header";
    begin
        DeletePurchaseLine(SalesLine);
        ICSalesHeader.ChangeCompany(InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
        if ICSalesHeader.FindSet() then
            DeleteICSalesLine(SalesLine);
        UpdateICSalesHeader(ToSalesLine);
    end;


    [EventSubscriber(ObjectType::Table, 37, 'OnDeleteBOMPurchIC', '', false, false)]
    procedure DeleteBOM_Purch_IC(var SalesLine: Record "Sales Line");
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
        if ExistIC then begin
            DeleteICSalesLine(SalesLine);
            UpdateICSalesHeader(SalesLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforeDeleteAfterPosting', '', false, false)]
    local procedure BeforeDeleteAfterPosting(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SkipDelete: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean)
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if TempSalesInvoiceHeader.Get(SalesInvoiceHeader."No.") = false then exit;
        SalesInvoiceHeader.RetailSalesHeader := SalesHeader.RetailSalesHeader;
        SalesInvoiceHeader."Ship-to City" := SalesHeader."Ship-to City";
        SalesInvoiceHeader.ZoneCode := SalesHeader.ZoneCode;
        SalesInvoiceHeader.TempDate := SalesHeader.TempDate;
        SalesInvoiceHeader."Delivery Hour" := SalesHeader."Delivery Hour";
        SalesInvoiceHeader."Delivery Item" := SalesHeader."Delivery Item";
        SalesInvoiceHeader."Delivery without BOM Item" := SalesHeader."Delivery without BOM Item";
        SalesInvoiceHeader."Assembly Item" := SalesInvoiceHeader."Assembly Item";
        SalesInvoiceHeader."Assembly Item without BOM Item" := SalesInvoiceHeader."Assembly Item without BOM Item";
        SalesInvoiceHeader.Stair := SalesHeader.Stair;


        SalesInvoiceHeader."Sell-to Contact" := SalesHeader."Sell-to Contact";
        SalesInvoiceHeader."Ship-to Phone No." := SalesHeader."Ship-to Phone No.";
        SalesInvoiceHeader."Vehicle NO" := SalesHeader."Vehicle NO";
        SalesInvoiceHeader.IsScheduled := SalesInvoiceHeader.IsScheduled;
        SalesInvoiceHeader.Delivery := SalesInvoiceHeader.Delivery;
        SalesInvoiceHeader.TripSequence := SalesHeader.TripSequence;


        SalesInvoiceHeader.IsDeliveried := SalesHeader.IsDeliveried;
        SalesInvoiceHeader.Cubage := SalesHeader.Cubage;
        SalesInvoiceHeader."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        SalesInvoiceHeader."Sell-to Customer Name" := SalesInvoiceHeader."Sell-to Customer Name";
        SalesInvoiceHeader.Driver := SalesInvoiceHeader.Driver;
        SalesInvoiceHeader."Sell-to Post Code" := SalesHeader."Sell-to Post Code";

        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader."Ship-to Code" := SalesHeader."Ship-to Code";
        SalesInvoiceHeader."Ship-to Name" := SalesInvoiceHeader."Ship-to Name";
        SalesInvoiceHeader."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        SalesInvoiceHeader."Ship-to Contact" := SalesHeader."Ship-to Contact";

        SalesInvoiceHeader."Shipping Agent Code" := SalesHeader."Shipping Agent Code";
        SalesInvoiceHeader."Sell-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
        SalesInvoiceHeader."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        SalesInvoiceHeader."Bill-to Name" := SalesHeader."Bill-to Name";
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;
        SalesInvoiceHeader.NeedCollectPayment := SalesHeader.NeedCollectPayment;
        SalesInvoiceHeader.Note := SalesHeader.Note;

        SalesInvoiceHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreateSalesDocument', '', false, false)]
    local procedure AfterCreateSalesDocument(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header"; HandledICInboxSalesHeader: Record "Handled IC Inbox Sales Header");
    var
        RetailSalesHeader: Record "Sales Header";
        RetailSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        TempDeliveryItem: Text[2000];
        TempDeliveryItemWithoutBOM: Text[2000];
        TempCubage: Decimal;
        TempAssemble: Boolean;
        TempAssembleHour: Decimal;
        ZoneCode: Record ZoneTable;
        TempAssemblyItem: Text[2000];
        TempAssemblyItemWithoutBOM: Text[2000];
        WarehouseRequest: Record "Warehouse Request";

        TempLine: Integer;
        TempInt: Integer;
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
        SalesHeader."Shipping Agent Code" := RetailSalesHeader."Shipping Agent Code";
        // For Return Order, Also need to carry the same Reason Code
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
            SalesHeader."Reason Code" := RetailSalesHeader."Reason Code";
        RetailSalesHeader.CalcFields("Amount Including VAT");
        TempInt := ROUND(RetailSalesHeader."Amount Including VAT", 1, '=');
        ZoneCode.SetRange("Order Price", TempInt, 999999);
        if ZoneCode.FindFirst() then
            SalesHeader.ZoneCode := ZoneCode.Code;


        RetailSalesLine.ChangeCompany(SalesHeader."Sell-to Customer Name");
        RetailSalesLine.SetRange("Document Type", RetailSalesHeader."Document Type");
        RetailSalesLine.SetRange("Document No.", RetailSalesHeader."No.");
        if RetailSalesLine.FindSet() then
            repeat
                if IsValideICSalesLine(RetailSalesLine) then begin
                    SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", RetailSalesLine."Line No.");
                    // RetailSalesLineToICSalesLineCopy(SalesLine, RetailSalesLine);
                    SalesLine."Location Code" := RetailSalesLine."Location Code";
                    SalesLine."BOM Item" := RetailSalesLine."BOM Item";
                    SalesLine.NeedAssemble := RetailSalesLine.NeedAssemble;
                    SalesLine.AssemblyHour := RetailSalesLine.AssemblyHour;
                    SalesLine.UnitAssembleHour := RetailSalesLine.UnitAssembleHour;
                    if SalesLine."Document Type" = SalesLine."Document Type"::"Return Order" then
                        SalesLine."Return Reason Code" := RetailSalesLine."Return Reason Code";
                    if RetailSalesLine.NeedAssemble then
                        TempAssemblyItem := TempAssemblyItem + 'Yes' + '\'
                    else
                        TempAssemblyItem := TempAssemblyItem + 'No' + '\';
                    if (Text.StrLen(TempDeliveryItem) + Text.StrLen(TempDeliveryItem) + Text.StrLen(SalesLine.Description) + 5) < 1995 then
                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + '\'
                    else
                        if (Text.StrLen(TempDeliveryItem) + 3 < 2000) then
                            TempDeliveryItem := TempDeliveryItem + '.';
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
                end
                else
                    TempLine += 10000;
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

        WarehouseRequest.SetRange("Source No.", SalesHeader."No.");
        WarehouseRequest.FindSet();
        WarehouseRequest."Original SO" := SalesHeader.RetailSalesHeader;
        WarehouseRequest.Modify();
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
            if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order" then
                PurchaseHeader."Reason Code" := SalesHeader."Reason Code";
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
            UpdateICSalesHeader(SalesLine);
        end;

    end;

    local procedure UpdateICSalesHeader(var SalesLine: Record "Sales Line");
    var
        ICSalesHeader: Record "Sales Header";
        ICSalesLine: Record "Sales Line";

        TempDeliveryItem: Text[2000];
        TempDeliveryItemWithoutBOM: Text[2000];
        TempCubage: Decimal;
        TempAssemble: Boolean;
        TempAssembleHour: Decimal;
        ZoneCode: Record ZoneTable;
        TempAssemblyItem: Text[2000];
        TempAssemblyItemWithoutBOM: Text[2000];
        TempInt: Integer;
    begin
        ICSalesHeader.ChangeCompany(InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."Document No.");
        if ICSalesHeader.FindSet() = false then exit;

        ICSalesLine.ChangeCompany(InventoryCompany());
        ICSalesLine.SetRange("Document Type", ICSalesHeader."Document Type");
        ICSalesLine.SetRange("Document No.", ICSalesHeader."No.");
        if ICSalesLine.FindSet() then
            repeat
                if ICSalesLine.NeedAssemble then
                    TempAssemblyItem := TempAssemblyItem + 'Yes' + '\'
                else
                    TempAssemblyItem := TempAssemblyItem + 'No' + '\';
                if (Text.StrLen(TempDeliveryItem) + Text.StrLen(TempDeliveryItem) + Text.StrLen(ICSalesLine.Description) + 5) < 1900 then
                    TempDeliveryItem := TempDeliveryItem + Format(ICSalesLine.Quantity) + '*' + ICSalesLine.Description + '\'
                else
                    if (Text.StrLen(TempDeliveryItem) + 3 < 2000) then
                        TempDeliveryItem := TempDeliveryItem + '.';
                // TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + ICSalesLine.Description + '\';
                if ICSalesLine."BOM Item" = false then begin
                    TempDeliveryItemWithoutBOM := TempDeliveryItemWithoutBOM + Format(ICSalesLine.Quantity) + '*' + ICSalesLine.Description + '\';
                    if ICSalesLine.NeedAssemble then
                        TempAssemblyItemWithoutBOM := TempAssemblyItemWithoutBOM + 'Yes' + '\'
                    else
                        TempAssemblyItemWithoutBOM := TempAssemblyItemWithoutBOM + 'No' + '\';
                    TempCubage := TempCubage + ICSalesLine."Unit Volume" * ICSalesLine.Quantity;
                    TempAssembleHour := TempAssembleHour + ICSalesLine.AssemblyHour;
                    if SalesLine.NeedAssemble = true then
                        TempAssemble := true;
                end;
            until ICSalesLine.Next() = 0;
        ICSalesHeader."Estimate Assembly Time(hour)" := TempAssembleHour;
        // SalesHeader.Note := GetWorkDescription(RetailSalesHeader);
        ICSalesHeader.NeedAssemble := TempAssemble;
        ICSalesHeader.Cubage := TempCubage;
        ICSalesHeader."Delivery Item" := TempDeliveryItem;
        ICSalesHeader."Delivery without BOM Item" := TempDeliveryItemWithoutBOM;
        ICSalesHeader."Assembly Item without BOM Item" := TempAssemblyItemWithoutBOM;
        ICSalesHeader."Assembly Item" := TempAssemblyItem;
        ICSalesHeader.CalcFields("Amount Including VAT");
        TempInt := ROUND(ICSalesHeader."Amount Including VAT", 1, '=');
        ZoneCode.SetRange("Order Price", TempInt, 999999);
        if ZoneCode.FindFirst() then
            ICSalesHeader.ZoneCode := ZoneCode.Code;
        ICSalesHeader.Modify();
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
                        BOMSalesLine.NeedAssemble := SalesLine.NeedAssemble;
                        BOMSalesLine."Return Reason Code" := SalesLine."Return Reason Code";
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
                    if PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Return Order" then
                        PurchaseLine."Return Reason Code" := TempSalesLine."Return Reason Code";
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
        PurchaseLine: Record "Purchase Line";
    begin
        Item.Get(SalesLine."No.");
        if Item.Type = Item.Type::Service then
            exit;
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ICSalesHeader.ChangeCompany('HEQS International Pty Ltd');
        ICSalesHeader.SetRange("External Document No.", SalesHeader."Automate Purch.Doc No.");
        if ICSalesHeader.FindSet() = false then exit;

        PurchaseLine.SetRange("Document Type", SalesLine."Document Type");
        PurchaseLine.SetRange("Document No.", SalesHeader."Automate Purch.Doc No.");
        TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
        TempSalesLine.SetRange("Document No.", SalesLine."Document No.");
        if TempSalesLine.FindSet() then begin
            repeat
                if TempSalesLine.Type = TempSalesLine.Type::" " then begin
                end
                else begin

                    Item.Get(TempSalesLine."No.");
                    if Item.Type <> Item.Type::Service then
                        ICSalesLine.ChangeCompany('HEQS International Pty Ltd');
                    if ICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", TempSalesLine."Line No.") = false then begin
                        if PurchaseLine.Get(ICSalesHeader."Document Type", SalesHeader."Automate Purch.Doc No.", TempSalesLine."Line No.") = true then
                            CreateICSalesLine(TempSalesLine)
                    end
                    else begin
                        // ICSalesLine.Validate("No.", TempSalesLine."No.");
                        ICSalesLine."No." := TempSalesLine."No.";
                        ICSalesLine.Description := TempSalesLine.Description;
                        ICSalesLine."BOM Item" := TempSalesLine."BOM Item";
                        ICSalesLine.Quantity := TempSalesLine.Quantity;
                        ICSalesLine."Location Code" := TempSalesLine."Location Code";
                        ICSalesLine.NeedAssemble := TempSalesLine.NeedAssemble;
                        ICSalesLine.AssemblyHour := TempSalesLine.AssemblyHour;
                        ICSalesLine."Package Tracking ID" := TempSalesLine."Package Tracking ID";
                        ICSalesLine."Car ID" := TempSalesLine."Car ID";
                        ICSalesLine.UnitAssembleHour := TempSalesLine.UnitAssembleHour;
                        ICSalesLine."Main Item Line" := TempSalesLine."Main Item Line";
                        ICSalesLine."VAT Bus. Posting Group" := TempSalesLine."VAT Bus. Posting Group";
                        ICSalesLine."VAT Prod. Posting Group" := TempSalesLine."VAT Prod. Posting Group";
                        if PurchaseLine.Get(TempSalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", TempSalesLine."Line No.") then
                            ICSalesLine."Unit Price" := PurchaseLine."Direct Unit Cost";
                        // ICSalesLine."Unit Price" := TempSalesLine."Unit Price";
                        ICSalesLine.Type := SalesLine.Type;
                        ICSalesLine."Quantity (Base)" := ICSalesLine."Quantity (Base)";
                        ICSalesLine."Outstanding Quantity" := ICSalesLine."Outstanding Quantity";
                        ICSalesLine."Outstanding Qty. (Base)" := ICSalesLine."Outstanding Qty. (Base)";
                        ICSalesLine."Shipment Date" := SalesLine."Shipment Date";
                        ICSalesLine."Qty. to Ship" := SalesLine."Qty. to Ship";
                        ICSalesLine."Qty. to Invoice" := SalesLine."Qty. to Invoice";
                        ICSalesLine."Line Amount" := SalesLine."Line Amount";
                        ICSalesLine."Unit of Measure" := SalesLine."Unit of Measure";
                        ICSalesLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                        if ICSalesLine."Document Type" = ICSalesLine."Document Type"::"Return Order" then
                            ICSalesLine."Return Reason Code" := TempSalesLine."Return Reason Code";
                        ICSalesLine.Modify();
                    end;

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
    procedure InsertPurchICBOM(var SalesLine: Record "Sales Line");
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
                ToTransferLine."Unit of Measure Code" := BOMComponent."Unit of Measure Code";
                ToTransferLine.Quantity := TransferLine.Quantity * BOMComponent."Quantity per";

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
                ToSalesLine.NeedAssemble := SalesLine.NeedAssemble;
                ToSalesLine.Validate("Qty. to Assemble to Order");
                ToSalesLine."Main Item Line" := SalesLine."Line No.";
                ToSalesLine.Insert();

                if (ToSalesLine.Type = ToSalesLine.Type::Item) and (ToSalesLine.Reserve = ToSalesLine.Reserve::Always) then
                    ToSalesLine.AutoReserve();


                InsertPurchaseLine(ToSalesLine);
                CreateICSalesLine(ToSalesLine);
            until BOMComponent.Next = 0;

    end;

    procedure IsValideICSalesLine(var SalesLine: Record "Sales Line"): Boolean;
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
        PurchasePrice: Record "Purchase Price";
        PurchaseHeader: Record "Purchase Header";
        User: Record User;
    begin
        if IsValideICSalesLine(SalesLine) = false then exit;

        Item.Get(SalesLine."No.");
        PurchasePrice.Reset();
        PurchasePrice.SetRange("Item No.", Item."No.");
        Vendor."Search Name" := 'HEQS INTERNATIONAL PTY LTD';
        Vendor.FindSet();
        PurchasePrice.SetRange("Vendor No.", Vendor."No.");

        SalesHeader.Get(SalesLine."Document Type", SalesLIne."Document No.");
        PurchaseLine.Reset();
        PurchaseLine.Init();
        PurchaseLine."Document Type" := SalesLine."Document Type";
        PurchaseLine."Document No." := SalesHeader."Automate Purch.Doc No.";
        if SalesHeader."Automate Purch.Doc No." <> '' then begin
            PurchaseLine."Line No." := SalesLine."Line No.";
            PurchaseLine.Type := SalesLine.Type;
            if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
                if PurchaseHeader."Currency Factor" = 0 then begin
                    PurchaseHeader."Currency Factor" := 1;
                    PurchaseHeader.Modify();
                end;

            end;
            PurchaseLine.Validate("No.", SalesLine."No.");
            PurchaseLine."BOM Item" := SalesLine."BOM Item";
            PurchaseLine.Validate(Quantity, SalesLine.Quantity);
            if PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Return Order" then
                PurchaseLine."Return Reason Code" := SalesLine."Return Reason Code";
            PurchaseLine.Insert();
            User.Get(Database.UserSecurityId());
            if User."Full Name" <> 'Pei Xu' then
                if (PurchasePrice.FindSet() = false) and (PurchaseLine."BOM Item" = false) then
                    Error('Please Set Purchase Price Entry for item %1', Item."No.");
        end;
    end;

    local procedure InsertPurchaseLineWithoutPriceCheck(SalesLine: Record "Sales Line");
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        Vendor: Record Vendor;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        IsMainItem: Boolean;
        PurchasePrice: Record "Purchase Price";
    begin
        if IsValideICSalesLine(SalesLine) = false then exit;

        Item.Get(SalesLine."No.");
        PurchasePrice.Reset();
        PurchasePrice.SetRange("Item No.", Item."No.");
        Vendor."Search Name" := 'HEQS INTERNATIONAL PTY LTD';
        Vendor.FindSet();
        PurchasePrice.SetRange("Vendor No.", Vendor."No.");

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
        // if (PurchasePrice.FindSet() = false) and (PurchaseLine."BOM Item" = false) then
        //     Error('Please Set Purchase Price Entry for item %1', Item."No.");
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
            ICSalesLine."Document No." := ICSalesHeader."No.";
            ICSalesLine."Line No." := SalesLine."Line No.";
            ICSalesLine.Type := SalesLine.Type;
            ICSalesLine."No." := SalesLine."No.";
            ICSalesLine.Quantity := SalesLine.Quantity;
            ICSalesLine."Quantity (Base)" := ICSalesLine."Quantity (Base)";
            ICSalesLine."Outstanding Quantity" := ICSalesLine."Outstanding Quantity";
            ICSalesLine."Outstanding Qty. (Base)" := ICSalesLine."Outstanding Qty. (Base)";
            ICSalesLine."Location Code" := SalesLine."Location Code";
            ICSalesLine."BOM Item" := SalesLine."BOM Item";
            ICSalesLine.Description := SalesLine.Description;
            ICSalesLine."Shipment Date" := SalesLine."Shipment Date";
            ICSalesLine."Qty. to Ship" := SalesLine."Qty. to Ship";
            ICSalesLine."Qty. to Invoice" := SalesLine."Qty. to Invoice";
            ICSalesLine."Line Amount" := SalesLine."Line Amount";
            ICSalesLine."Unit of Measure" := SalesLine."Unit of Measure";
            if ICSalesLine."Document Type" = ICSalesLine."Document Type"::"Return Order" then
                ICSalesLine."Return Reason Code" := SalesLine."Return Reason Code";
            ICSalesLine.Insert();
            // if ICSalesLine."Document Type" = ICSalesLine."Document Type"::Order then
            //     CreateWhseShipLine(ICSalesLine);
        end;

    end;

    local procedure CreateWhseShipLine(var ICSalesLine: Record "Sales Line");
    var
        WhseShipLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
        WhseShipHeader: Record "Warehouse Shipment Header";
    begin
        SalesHeader.Reset();
        SalesHeader.ChangeCompany(InventoryCompanyName);
        SalesHeader.Get(ICSalesLine."Document Type", ICSalesLine."Document No.");
        WhseShipHeader.ChangeCompany(InventoryCompanyName);
        WhseShipHeader.SetRange("External Document No.", SalesHeader."External Document No.");
        if WhseShipHeader.FindSet() then begin
            WhseShipLine.ChangeCompany(InventoryCompanyName);
            WhseShipLine."No." := WhseShipHeader."No.";
            WhseShipLine."Line No." := ICSalesLine."Line No.";
            WhseShipLine."Source Type" := 37;
            WhseshipLine."Source Subtype" := 1;
            WhseShipLine."Source No." := ICSalesLine."Document No.";
            WhseShipLine."Source Line No." := ICSalesLine."Line No.";
            WhseShipLine."Source Document" := WhseShipLine."Source Document"::"Sales Order";
            WhseShipLine."Location Code" := ICSalesLine."Location Code";
            WhseShipLine."Item No." := ICSalesLine."No.";
            WhseShipLine."Qty. (Base)" := ICSalesLine."Quantity (Base)";
            WhseShipLine."Qty. Outstanding" := ICSalesLine."Outstanding Quantity";
            WhseShipLine."Qty. Outstanding (Base)" := ICSalesLine."Outstanding Qty. (Base)";
            WhseShipLine."Unit of Measure Code" := ICSalesLine."Unit of Measure Code";
            WhseShipLine."Qty. per Unit of Measure" := ICSalesLine."Qty. per Unit of Measure";
            WhseShipLine.Description := ICSalesLine.Description;
            WhseShipLine."Sorting Sequence No." := ICSalesLine."Line No.";
            WhseShipLine."Due Date" := ICSalesLine."Shipment Date";
            WhseShipLine.Insert();
        end;
    end;

    procedure InventoryCompany(): Text;
    begin
        exit(InventoryCompanyName);
    end;

    local procedure RetailSalesLineToICSalesLineCopy(var RetailSalesLine: Record "Sales Line"; var ICSalesLine: Record "Sales Line");
    begin
        //System Field
        ICSalesLine.Validate("No.", RetailSalesLine."No.");
        ICSalesLine.Validate(Quantity, RetailSalesLine.Quantity);
        ICSalesLine.Validate("Location Code", RetailSalesLine."Location Code");
        ICSalesLine."VAT Bus. Posting Group" := RetailSalesLine."VAT Bus. Posting Group";
        ICSalesLine."VAT Prod. Posting Group" := RetailSalesLine."VAT Prod. Posting Group";
        ICSalesLine."Unit Price" := RetailSalesLine."Unit Price";
        //Customize Field
        ICSalesLine."BOM Item" := RetailSalesLine."BOM Item";
        ICSalesLine.NeedAssemble := RetailSalesLine.NeedAssemble;
        ICSalesLine.AssemblyHour := RetailSalesLine.AssemblyHour;
        ICSalesLine."Package Tracking ID" := RetailSalesLine."Package Tracking ID";
        ICSalesLine."Car ID" := RetailSalesLine."Car ID";
        ICSalesLine.UnitAssembleHour := RetailSalesLine.UnitAssembleHour;
        ICSalesLine."Main Item Line" := ICSalesLine."Main Item Line";
    end;

    procedure RequirFieldTesting(var SalesHeader: Record "Sales Header");
    begin
        if SalesHeader.Delivery = SalesHeader.Delivery::" " then
            Error('Please select the delivery option')
        else
            if SalesHeader.Delivery = SalesHeader.Delivery::Delivery then begin
                if SalesHeader."Ship-to Address" = '' then begin
                    Error('Please Give Ship-to to address');
                end
            end;
    end;
}