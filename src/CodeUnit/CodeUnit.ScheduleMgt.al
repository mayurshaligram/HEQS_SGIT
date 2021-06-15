codeunit 50114 "Schedule Mgt"
{
    // This codeunit contains the function for schedule
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        NoSeriesMgt: Codeunit NoSeriesManagement;

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
        Schedule."Ship-to City" := SalesHeader."Location Code";
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
}