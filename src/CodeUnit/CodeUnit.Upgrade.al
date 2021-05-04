codeunit 50109 ZoneUpgrade
{
    Subtype = Upgrade;

    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        PayableMgt: Codeunit PayableMgt;

    trigger OnCheckPreconditionsPerCompany()
    begin
        // Code to make sure company is OK to upgrade.
    end;

    trigger OnUpgradePerCompany()
    var
        Company: Record Company;
    begin
        LoadZoneTable();
        if Company.Name = SalesTruthMgt.InventoryCompany() then
            ClearPayable();
        // LoadPayable();
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

    local procedure LoadZoneTable()
    var
        ZoneTable: Record ZoneTable;
    begin
        if ZoneTable.FindSet() = false then begin
            ZoneTable."Order Price" := 1000;
            ZoneTable.Code := 'O1';
            ZoneTable."Delivery Fee" := 20;
            ZoneTable.L1 := 10;
            ZoneTable.L2 := 20;
            ZoneTable.L3 := 30;
            ZoneTable.Insert();

            ZoneTable."Order Price" := 2000;
            ZoneTable.Code := 'O2';
            ZoneTable."Delivery Fee" := 30;
            ZoneTable.L1 := 20;
            ZoneTable.L2 := 30;
            ZoneTable.L3 := 40;
            ZoneTable.Insert();

            ZoneTable."Order Price" := 3000;
            ZoneTable.Code := 'O3';
            ZoneTable."Delivery Fee" := 40;
            ZoneTable.L1 := 30;
            ZoneTable.L2 := 40;
            ZoneTable.L3 := 50;
            ZoneTable.Insert();

            ZoneTable."Order Price" := 4000;
            ZoneTable.Code := 'O4';
            ZoneTable."Delivery Fee" := 50;
            ZoneTable.L1 := 40;
            ZoneTable.L2 := 50;
            ZoneTable.L3 := 60;
            ZoneTable.Insert();
        end;
    end;

    local procedure LoadPayable()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader.Reset();
        if PurchaseHeader.FindSet() then
            repeat
                if PurchaseHeader."Sales Order Ref" = '' then
                    if NotContainPayable(PurchaseHeader) = false then begin
                        PayableMgt.PurchaseHeaderInsertPayable(PurchaseHeader);

                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        if PurchaseLine.FindSet() then
                            PayableMgt.PutPayableItem(PurchaseLine);
                    end;
            until PurchaseHeader.Next() = 0;
    end;

    local procedure NotContainPayable(PurchaseHeader: Record "Purchase Header"): Boolean
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


    trigger OnValidateUpgradePerCompany()
    begin
        // Code to make sure that upgrade was successful for each company
    end;




}