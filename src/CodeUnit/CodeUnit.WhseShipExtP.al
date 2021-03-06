codeunit 50108 WhseShipPExtMgt
{
    procedure PostShipmentInInventory(WhseShipment: Record "Warehouse Shipment Header");
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

        WhseShipmentLine: Record "Posted Whse. Shipment Line";
        TempCode: Code[20];
        Continue: Boolean;
    begin
        // Continue := false;
        // Modify Purchase Receipt
        // Post Purchase Receipt 
        // Modify Purchase Receipt
        // Post Sales Shipment
        // If WhseShipment.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
        //     WhseShipmentLine.Reset();
        //     WhseShipmentLine.SetRange("No.", WhseShipment."No.");
        //     if (WhseShipmentLine.FindSet()) and (TempCode <> WhseShipmentLine."Source No.") then begin
        //         repeat
        //             InventorySalesHeader.SetRange("No.", TempCode);
        //             if InventorySalesHeader.FindSet() then begin
        //                 RetailSalesOrder.Reset();
        //                 RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //                 RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
        //                 if RetailSalesOrder.FindSet() then begin
        //                     RetailPurchaseHeader.Reset();
        //                     RetailPurchaseHeader.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //                     RetailPurchaseHeader.SetRange("No.", InventorySalesHeader."External Document No.");
        //                     if RetailPurchaseHeader.FindSet() then begin
        //                         InventorySalesLine.SetRange("Document Type", InventorySalesHeader."Document Type");
        //                         InventorySalesLine.SetRange("Document No.", InventorySalesHeader."No.");
        //                         // if InventorySalesLine.FindSet() then
        //                         //     repeat
        //                         //         RetailPurchaseLine.Reset();
        //                         //         RetailPurchaseLine.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //                         //         RetailPurchaseLine.Get(InventorySalesHeader."Document Type", RetailPurchaseHeader."No.", InventorySalesLine."Line No.");
        //                         //         RetailPurchaseLine."Quantity Received" := InventorySalesLine."Quantity Shipped";
        //                         //         RetailPurchaseLine."Qty. to Receive" := RetailPurchaseLine."Qty. to Receive" - RetailPurchaseLine."Quantity Received";
        //                         //         RetailPurchaseLine."Qty. to Invoice" := InventorySalesLine."Qty. to Invoice";
        //                         //         RetailPurchaseLine.Modify();

        //                         //     until InventorySalesLine.Next() = 0;


        //                         InventorySalesHeader."External Document No." := '';
        //                         InventorySalesHeader.Modify();

        //                         RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
        //                         RetailSalesOrder.Modify();

        //                         SessionID := 50;
        //                         StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);
        //                     end;
        //                 end;
        //             end;
        //             TempCode := WhseShipmentLine."No.";
        //         until WhseShipmentLine.Next() = 0;
        //     end;
        // end;
    end;
}