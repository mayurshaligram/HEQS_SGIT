pageextension 50104 "Warehouse Shipment_Ext" extends "Warehouse Shipment"
{
    actions
    {
        modify("P&ost Shipment")
        {
            trigger OnAfterAction()
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
                Continue: Boolean;
            begin
                Continue := false;
                If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
                    InventorySalesHeader.SetRange("External Document No.", Rec."External Document No.");
                    InventorySalesHeader.FindSet();

                    RetailSalesOrder.Reset();
                    RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
                    RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
                    RetailSalesOrder.FindSet();

                    InventorySalesHeader."External Document No." := '';
                    InventorySalesHeader.Modify();

                    RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
                    RetailSalesOrder.Modify();

                    SessionID := 50;
                    StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);

                end;
            end;
        }
        modify("Create Pick")
        {
            trigger OnAfterAction()
            var
                WarehouseActivityLine: Record "Warehouse Activity Line";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
            begin
                WarehouseShipmentLine.SetRange("No.", Rec."No.");
                if WarehouseShipmentLine.FindSet() then
                    repeat
                        WarehouseActivityLine.SetRange("Source No.", WarehouseShipmentLine."Source No.");
                        WarehouseActivityLine.SetRange("Item No.", WarehouseShipmentLine."Item No.");
                        if WarehouseActivityLine.FindSet() then
                            repeat
                                WarehouseActivityLine."Pick-up Item" := WarehouseShipmentLine."Pick-up Item";
                                WarehouseActivityLine.Modify();
                            until WarehouseActivityLine.Next() = 0;
                    until WarehouseShipmentLine.Next() = 0;
            end;
        }
    }
}