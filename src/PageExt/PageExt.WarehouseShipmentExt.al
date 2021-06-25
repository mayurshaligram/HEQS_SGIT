pageextension 50105 "Warehouse Shipment_Ext" extends "Warehouse Shipment"
{
    actions
    {
        modify("P&ost Shipment")
        {
            trigger OnAfterAction()
            var
                ICSalesHeader: Record "Sales Header";
                SalesHeader: Record "Sales Header";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
            begin
                WhseShipPExtMgt.PostShipmentInInventory(Rec);
            end;
        }
        // Partial Pick Option Choise stop auto fill Handle qty
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
                AssignPickOriginalSO();
            end;
        }
    }

    var
        WhseShipPExtMgt: Codeunit WhseShipPExtMgt;

    local procedure AssignPickOriginalSO();
    var
        WhsePickHeader: Record "Warehouse Activity Header";
        WhsePickLines: Record "Warehouse Activity Line";
        SourceNo: Record "Sales Header";
    begin
        Clear(WhsePickHeader);
        WhsePickHeader.SetRange(Type, WhsePickHeader.Type::Pick);
        if WhsePickHeader.FindLast() then
            repeat
                Clear(WhsePickLines);
                WhsePickLines.SetRange("No.", WhsePickHeader."No.");
                if WhsePickLines.FindSet() then
                    repeat
                        if WhsePickLines."Source Document" = WhsePickLines."Source Document"::"Sales Order" then begin
                            Clear(SourceNo);
                            if SourceNo.Get(SourceNo."Document Type"::Order, WhsePickLines."Source No.") then begin
                                WhsePickLines."Original SO" := SourceNo.RetailSalesHeader;
                                WhsePickLines.Modify();
                            end;
                        end;
                    until WhsePickLines.Next() = 0;
            until WhsePickHeader.Next() = 0;
    end;
}