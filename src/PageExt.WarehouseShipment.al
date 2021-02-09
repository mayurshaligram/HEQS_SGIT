pageextension 50112 "Warehouse Shipment_Ext" extends "Warehouse Shipment"
{
    Caption = 'Warehouse Shipment_Ext';
    actions
    {
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
                message('Here is after create Pick');
            end;
        }
    }
}