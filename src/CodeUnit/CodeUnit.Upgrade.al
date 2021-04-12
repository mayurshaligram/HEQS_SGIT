codeunit 50110 ZoneUpgrade
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin
        // Code to make sure company is OK to upgrade.
    end;

    trigger OnUpgradePerCompany()
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

    trigger OnValidateUpgradePerCompany()
    begin
        // Code to make sure that upgrade was successful for each company
    end;
}