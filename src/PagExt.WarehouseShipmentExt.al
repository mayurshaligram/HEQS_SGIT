pageextension 50112 "Warehouse Shipment_Ext" extends "Warehouse Shipment"
{
    Caption = 'Warehouse Shipment_Ext';
    actions
    {
        modify("P&ost Shipment")
        {
            ApplicationArea = Warehouse;
            Caption = 'P&ost Shipment';
            Promoted = true;
            PromotedCategory = Category6;
            PromotedIsBig = true;
            ShortCutKey = 'F9';
            ToolTip = 'Post the items as shipped. Related pick documents are registered automatically.';

            // Check the Sales Order Posting Part first, and then go and copy the most of the same content.
            // Do the shipment post partfirst
            // Need to post the Warehouse shipment first and then goes to the post in the sales order

            trigger OnAfterAction()
            var
                InventorySalesOrder: Record "Sales Header";
                RetailPurchaseOrder: Record "Purchase Header";
                RetailSalesOrder: Record "Sales Header";
                RetailSalesOrderPage: Page "Sales Order";
                SessionID: Integer;
                Temp: Text;
                OK: Boolean;
            begin
                If Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
                    // What is the shipment extener no
                    InventorySalesOrder.Reset();
                    InventorySalesOrder.SetRange("External Document No.", Rec."External Document No.");
                    InventorySalesOrder.FindSet();
                    //
                    RetailPurchaseOrder.Reset();
                    RetailPurchaseOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
                    RetailPurchaseOrder.Get(InventorySalesOrder."Document Type", Rec."External Document No.");
                    //
                    RetailSalesOrder.Reset();
                    RetailSalesOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
                    RetailSalesOrder.Get(RetailPurchaseOrder."Document Type", RetailPurchaseOrder."Sales Order Ref");
                    RetailSalesOrder."External Document No." := InventorySalesOrder."No.";
                    RetailSalesOrder."Automate Purch.Doc No." := '';
                    RetailSalesOrder.Modify();
                    //
                    Message('Posting Retail Company Sales Order.');
                    // What about just open the page
                    // RetailSalesOrderPage.SetRecord(RetailSalesOrder);
                    // RetailSalesOrderPage.Run();
                    Temp := InventorySalesOrder."External Document No.";
                    InventorySalesOrder."External Document No." := '';
                    InventorySalesOrder.Modify();
                    SessionID := 50;
                    StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesOrder."Sell-to Customer Name", RetailSalesOrder);
                    // StopSession(SessionId, 'Logoff cache stress test session');
                    // BackSession Didn't Work Try using Codeunit to Post Sales Header in Retail Company first.
                    // InventorySalesOrder."External Document No." := Temp;
                    // InventorySalesOrder.Modify();
                end;
            end;
            // trigger OnAfterAction()
            // var
            //     SalesPostYesNo: Codeunit ;
            //     RetailSalesOrder: Record "Sales Header";
            //     RetailPurchaseOrder: Record "Purchase Header";
            // begin
            //     if Rec."External Document No." <> '' then begin
            //         // OK := StartSession(SessionId, CodeUnit::"Cache Stress Test", CompanyName, CacheStressTestRec);
            //         //
            //         RetailPurchaseOrder.ChangeCompany(Rec."Sell-to Customer Name");
            //         RetailPurchaseOrder.Get(Rec."Document Type", Rec."External Document No.");
            //         //
            //         RetailSalesOrder.ChangeCompany(Rec."Sell-to Customer Name");
            //         RetailSalesOrder.Get(Rec."Document Type", RetailPurchaseOrder."Sales Order Ref");
            //         //
            //         CurrPage.SetRecord(RetailSalesOrder);
            //         Message('Go to Retail And Post the Sales Order.');
            //         SalesPostYesNo.Run(RetailSalesOrder);
            //     end;
            // end;
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
                // message('Here is after create Pick');
            end;
        }
    }
}