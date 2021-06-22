codeunit 50114 "Schedule Mgt"
{
    // This codeunit contains the function for schedule
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        NoSeriesMgt: Codeunit NoSeriesManagement;


    // Initialize the Schedule Item in Existing Business Central
    // 1. Sales Order Initialize
    // 2. Sales Return Initialize
    // 3. Transfer Order Initalize
    // 4. There are no previous Pure Warranty Sales Order
    procedure Initialize()
    begin
        // Before Initialize First Setup No Series for Schedule and Trip 
        if Database.CompanyName() <> SalesTruthMgt.InventoryCompany() then
            Error('Please Only Initialize the schedule item in the inventory company');
        LoadSalesOrder();
        TransferOrder();
    end;

    // Load Sales [Return] Order in International 
    // Two Types: 1. IsDeliverd -- Completed
    //            2. Others -- Norm
    local procedure LoadSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        Schedule: Record Schedule;
    begin
        SalesHeader.Reset();
        if SalesHeader.FindSet() then
            repeat
                CreateScheduleItem(SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    local procedure TransferOrder()
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.Reset();
        if TransferHeader.FindSet() then
            repeat
                CreateTransferItem(TransferHeader);
            until TransferHeader.Next() = 0;
    end;

    procedure CreateTransferItem(TransferHeader: Record "Transfer Header");
    var
        Schedule: Record Schedule;
        TransferLine: Record "Transfer Line";
        TempDeliveryItem: Text[2000];
    begin
        Clear(Schedule);
        Schedule."Source Type" := Schedule."Source Type"::"Transfer Order";
        Schedule."Source No." := TransferHeader."No.";
        Schedule."Delivery Date" := TransferHeader."Shipment Date";
        Schedule.Assemble := false;
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindSet() then
            repeat
                if IsMainItemLineTrans(TransferLine) then
                    if StrLen(TempDeliveryItem) < 1900 then
                        TempDeliveryItem := TempDeliveryItem + Format((TransferLine.Quantity)) + '*' + TransferLine.Description + ', ';
            until TransferLine.Next() = 0;
        Schedule.Status := Schedule.Status::Norm;
        Schedule."From Location Code" := TransferHeader."Transfer-from Code";
        Schedule."Delivery Items" := TempDeliveryItem;
        Schedule."To Location Code" := TransferHeader."Transfer-to Code";
        Schedule."Subsidiary Source No." := TransferHeader."No.";
        Schedule.Insert(true);
    end;

    local procedure IsMainItemLineTrans(Transfer: Record "Transfer Line"): Boolean;
    var
        TempItem: Record Item;
    begin
        TempItem.Reset();
        if TempItem.Get(Transfer."Item No.") = false then
            exit(false);
        TempItem.CalcFields("Assembly BOM");
        if TempItem."Assembly BOM" then
            exit(true);
    end;


    procedure CreateWarrantyItem(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        Schedule: Record Schedule;
        TempDeliveryItem: Text[2000];
        NewNo: Code[20];

        TempSchedule: Record Schedule;
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            Schedule.ChangeCompany(SalesTruthMgt.InventoryCompany());
            Schedule."Source Type" := Schedule."Source Type"::"Warranty Service";
            LoadInforSalesOrder(SalesHeader, Schedule);
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("No.", '9050000');
            if SalesLine.FindSet() then
                repeat
                    if StrLen(TempDeliveryItem) < 1900 then
                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
                until SalesLine.Next() = 0;
            Schedule."Delivery Items" := TempDeliveryItem;
            Schedule."Subsidiary Source No." := 'WAR' + SalesHeader."Your Reference";
            Schedule."Source No." := SalesHeader."No.";
            Schedule."No." := SalesHeader."No.";
            Schedule."To Location Code" := SalesHeader."Location Code";
            if TempSchedule.Get(Schedule."No.") = false then
                Schedule.Insert();
        end;
    end;

    procedure CreateScheduleItem(var SalesHeader: Record "Sales Header");
    var
        SubsidarySalesHeader: Record "Sales Header";

        Zone: Record ZoneTable;
        TempInt: Integer;
        TempDeliveryItem: Text[2000];
        TempDeliveryItemWithoutBom: Text[2000];

        SalesLine: Record "Sales Line";

        TempAssemble: Boolean;
        TempAssemblyItem: Text[2000];
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            CreateSalesOrderScheduleItem(SalesHeader);
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
            CreateSalesReturnScheduleItem(SalesHeader);
    end;

    procedure CreateSalesOrderScheduleItem(var SalesHeader: Record "Sales Header");
    var
        Schedule: Record Schedule;
        TempInt: Integer;
        Zone: Record ZoneTable;
        SalesLine: Record "Sales Line";
        TempAssemble: Boolean;
        TempDeliveryItem: Text[2000];
    begin
        Schedule."Source Type" := Schedule."Source Type"::"Sales Order";

        LoadInforSalesOrder(SalesHeader, Schedule);


        TempInt := Round(SalesHeader."Amount Including VAT", 1, '=');
        Zone.SetRange("Order Price", TempInt, 999999);
        if Zone.FindSet() then
            Schedule.Zone := Zone.Code;

        // Load Work Description From Original Retail Order
        LoadWorkDescriptionFromOriginalRetailOrder(SalesHeader, Schedule);
        Schedule.Insert(true);
    end;

    procedure CreateSalesReturnScheduleItem(var SalesHeader: Record "Sales Header");
    var
        Schedule: Record Schedule;
    begin
        Schedule."Source Type" := Schedule."Source Type"::"Sales Return Order";

        LoadInforSalesOrder(SalesHeader, Schedule);

        Schedule.Insert(true);
    end;

    procedure LoadWarrantyLine(var SalesHeader: Record "Sales Header"; var Schedule: Record Schedule): Text;
    var
        SalesLine: Record "Sales Line";
        TempDeliveryItem: Text[2000];
    begin
        SalesLine.ChangeCompany(SalesHeader."Sell-to Customer Name");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader.RetailSalesHeader);
        SalesLine.SetRange("No.", '9050000');
        if SalesLine.FindSet() then
            repeat
                if StrLen(TempDeliveryItem) < 1900 then
                    TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
            until SalesLine.Next() = 0;
        exit(TempDeliveryItem);
    end;

    procedure LoadInforSalesOrder(var SalesHeader: Record "Sales Header"; var Schedule: Record Schedule);
    var
        TempInt: Integer;
        Zone: Record ZoneTable;
        SalesLine: Record "Sales Line";
        TempAssemble: Boolean;
        TempDeliveryItem: Text[2000];
        TempText: Text[2000];
    begin
        Schedule."Source No." := SalesHeader."No.";
        Schedule."Subsidiary Source No." := SalesHeader.RetailSalesHeader;
        Schedule."Ship-to City" := SalesHeader."Ship-to City";
        if Schedule."Ship-to City" = '' then
            Schedule."Ship-to City" := SalesHeader."Sell-to City";
        SalesHeader.CalcFields("Amount Including VAT");
        Schedule."Delivery Date" := SalesHeader."Promised Delivery Date";
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.NeedAssemble then
                    TempAssemble := true;
                if IsMainItemLine(SalesLine) then
                    if StrLen(TempDeliveryItem) < 1900 then
                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
            until SalesLine.Next() = 0;

        if Schedule."Source Type" = Schedule."Source Type"::"Sales Order" then
            TempDeliveryItem += LoadWarrantyLine(SalesHeader, Schedule);


        Schedule."Delivery Items" := TempDeliveryItem;
        Schedule.Assemble := TempAssemble;
        Schedule.Customer := SalesHeader."Ship-to Contact";
        Schedule."Phone No." := SalesHeader."Ship-to Phone No.";
        Schedule.Remote := false;
        if SalesHeader.IsDeliveried = true then
            Schedule.Status := Schedule.Status::Completed
        else
            Schedule.Status := Schedule.Status::Norm;
        Schedule.Status := Schedule.Status::Norm;
        Schedule."From Location Code" := SalesHeader."Location Code";
        Schedule."Subsidiary Source No." := SalesHeader.RetailSalesHeader;
    end;

    local procedure IsMainItemLine(SalesLine: Record "Sales Line"): Boolean;
    var
        TempItem: Record Item;
    begin
        TempItem.Reset();
        if TempItem.Get(SalesLine."No.") = false then
            exit(false);
        TempItem.CalcFields("Assembly BOM");
        if TempItem."Assembly BOM" then
            exit(true);
    end;

    procedure AssignTrip(var Schedule: Record Schedule; TripNo: Code[20]);
    var
        TempBool: Boolean;
    begin
        TempBool := ComfirmChange(Schedule);
        if TempBool then
            AssignTripNo(Schedule, TripNo);
    end;

    procedure ComfirmChange(var
                                Schedule: Record Schedule): Boolean;

    var
        ConfirmStr: Text;
    begin
        if Schedule."Trip No." <> '' then begin
            ConfirmStr := Schedule."Source No." + ' has already in Trip ' + Schedule."Trip No." + ' do you want to move it to the new trip?';
            if Confirm(ConfirmStr) = false then
                exit(false);
        end;
        exit(true);
    end;


    procedure AssignTripNo(var Schedule: Record Schedule; TripNo: Code[20]);
    var
        Trip: Record Trip;
    begin
        Schedule.Get(Schedule."No.");
        Schedule."Trip No." := TripNo;
        Trip.Get(TripNo);
        Trip.CalcFields("Total Schedule");
        Schedule."Trip Sequece" := Trip."Total Schedule";
        Schedule.Modify();
    end;

    procedure LoadWorkDescriptionFromOriginalRetailOrder(ICSalesHeader: Record "Sales Header"; var Schedule: Record Schedule);
    var
        RetailSalesHeader: Record "Sales Header";
        TempText: Text[2000];
    begin
        RetailSalesHeader.ChangeCompany(ICSalesHeader."Sell-to Customer Name");
        if RetailSalesHeader.Get(ICSalesHeader."Document Type", ICSalesHeader.RetailSalesHeader) then begin
            RetailSalesHeader.CalcFields("Work Description");
            TempText := GetWorkDescription(RetailSalesHeader);
            Schedule."Delivery Date" := RetailSalesHeader."Requested Delivery Date";
            Schedule."Delivery Time" += TempText;
            Schedule."Subsidiary Name" := RetailSalesHeader.CurrentCompany();
        end;
    end;

    procedure GetWorkDescription(var SalesHeader: Record "Sales Header"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        SalesHeader.CalcFields("Work Description");
        SalesHeader."Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;
}