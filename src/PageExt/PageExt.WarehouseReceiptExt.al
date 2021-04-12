pageextension 50109 "Warehouse Receipt Ext" extends "Warehouse Receipt"
{


    actions
    {
        modify("Post Receipt")
        {
            trigger OnBeforeAction()
            var
                WarehouseReciptLine: Record "Warehouse Receipt Line";
            begin
                WarehouseReciptLine.Get(Rec."No.", 10000);
                SourceDocument := WarehouseReciptLine."Source No.";
            end;

            trigger OnAfterAction()
            var
                PutAway: Record "Warehouse Activity Header";
                PutAwayLine: Record "Warehouse Activity Line";
                Item: Record Item;
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
                PutAway.Reset();
                PutAway.SetRange(Type, PutAway.Type::"Put-away");
                PutAway.FindLast();
                //
                PutAwayLine.Reset();
                PutAwayLine.SetRange("Activity Type", PutAway.Type::"Put-away");
                PutAwayLine.SetRange("No.", PutAway."No.");
                if PutAwayLine.FindSet() then
                    repeat
                        if PutAwayLine."Unit of Measure Code" = '' then begin
                            Item.Get(PutAwayLine."Item No.");
                            PutAwayLine."Unit of Measure Code" := Item."Base Unit of Measure";
                            PutAwayLine.Modify();
                        end;
                    until PutAwayLine.Next() = 0;

                Continue := false;
                If Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
                    InventorySalesHeader.Get(InventorySalesHeader."Document Type"::"Return Order", SourceDocument);

                    RetailSalesOrder.Reset();
                    RetailSalesOrder.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
                    RetailSalesOrder.SetRange("Automate Purch.Doc No.", InventorySalesHeader."External Document No.");
                    RetailSalesOrder.FindSet();

                    InventorySalesHeader."External Document No." := '';
                    InventorySalesHeader.Modify();

                    RetailSalesOrder."External Document No." := InventorySalesHeader."No.";
                    RetailSalesOrder.Modify();

                    SessionID := 51;
                    StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesHeader."Sell-to Customer Name", RetailSalesOrder);
                end;
            end;
        }
    }



    var
        myInt: Integer;
        SourceDocument: Code[20];
}