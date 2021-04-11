codeunit 50109 WhseShipPExtMgt
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
        RetallPurchaseLine: Record "Purchase Line";

        Continue: Boolean;
    begin
        // Continue := false;
        // Modify Purchase Receipt
        // Post Purchase Receipt 
        // Modify Purchase Receipt
        // Post Sales Shipment
        If WhseShipment.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
            InventorySalesHeader.SetRange("External Document No.", WhseShipment."External Document No.");
            InventorySalesHeader.FindSet();

            RetailSalesOrder.Reset();
            RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
            RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
            RetailSalesOrder.FindSet();

            // InventorySalesLine.SetRange("Document Type", );


            InventorySalesHeader."External Document No." := '';
            InventorySalesHeader.Modify();

            RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
            RetailSalesOrder.Modify();

            SessionID := 50;
            StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);

        end;
    end;
}