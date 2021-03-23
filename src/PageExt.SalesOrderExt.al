pageextension 50103 "Sales Order_Ext" extends "Sales Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                PurchaseHeader: Record "Purchase Header";
                ErrorMessage: Label 'Please release the current Sales Order(%1) in Sales Order at Retail Company';
                SalesOrder: Text;
                TempText: Text;
            begin
                if Rec.CurrentCompany = InventoryCompanyName then
                    if Rec."External Document No." <> '' then begin
                        Error(ErrorMessage);
                    end;
                if Rec.CurrentCompany <> InventoryCompanyName then begin
                    if PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") = False then begin
                        PurchaseHeader.Init();
                        PurchaseHeader."Document Type" := Rec."Document Type";
                        PurchaseHeader."No." := Rec."Automate Purch.Doc No.";
                        PurchaseHeader.Insert();
                        Rec.UpdatePurchaseHeader(PurchaseHeader);
                    end;
                end;
            end;

            trigger OnAfterAction()
            var
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                PurchaseHeader: Record "Purchase Header";
                SORecord: Record "Sales Header";
                ICRec: Record "Sales Header";
                SLrec: Record "Sales Line";
                ISLrec: Record "Sales Line";
                ISOsrec: Record "Sales Header";
                Whship: Record "Warehouse Request";
                TempText: Text[20];
                hasPO: Boolean;
                InventoryICInboxTransaction: Record "IC Inbox Transaction";
                ICPage: Page "IC Inbox Transactions";
            begin
                if Rec.CurrentCompany <> InventoryCompanyName then begin
                    PurchaseHeader.Get(Rec."Document Type"::Order, Rec."Automate Purch.Doc No.");
                    Rec.UpdatePurchaseHeader(PurchaseHeader);
                    SORecord.ChangeCompany(InventoryCompanyName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if not (SORecord.findset) then
                        if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                    InventoryICInboxTransaction.ChangeCompany(InventoryCompanyName);
                    if InventoryICInboxTransaction.FindSet() then
                        repeat
                            InventoryICInboxTransaction."Line Action" := InventoryICInboxTransaction."Line Action"::Accept;
                            InventoryICInboxTransaction.Validate("Line Action", InventoryICInboxTransaction."Line Action"::Accept);
                            InventoryICInboxTransaction.Modify();
                            ICAutomate(InventoryICInboxTransaction);
                        until InventoryICInboxTransaction.Next() = 0;
                    SORecord.ChangeCompany(InventoryCompanyName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", PurchaseHeader."No.");
                    if (SORecord.findset) then
                        repeat
                            Whship.ChangeCompany(InventoryCompanyName);
                            Whship.Init();
                            Whship."Source Document" := Whship."Source Document"::"Sales Order";
                            Whship."Source No." := SORecord."No.";
                            Whship."External Document No." := SORecord."External Document No.";
                            Whship."Destination Type" := Whship."Destination Type"::Customer;
                            Whship."Destination No." := SORecord."Sell-to Customer No.";
                            Whship."Shipping Advice" := Whship."Shipping Advice"::Partial;
                            Whship.Insert();
                            ICrec.ChangeCompany(InventoryCompanyName);
                            ICRec.Get(SORecord."Document type", SORecord."No.");
                            if Rec.Status = Rec.Status::Released then
                                if ICRec.Status <> Rec.Status then
                                    ICRec.Status := Rec.Status;
                            // ReleaseSalesDoc.PerformManualRelease(ICrec);
                            ICrec."Work Description" := Rec."Work Description";
                            Rec.CALCFIELDS("Work Description");
                            ICrec."Work Description" := Rec."Work Description";
                            ICrec.Status := Rec.Status;
                            ICREC.Modify();
                        until (SORecord.next() = 0);
                    // ISL updata
                end;
            end;
        }
        modify(Reopen)
        {
            trigger OnBeforeAction();
            var
                SalesOrder: Text;
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in Sales Order at Retail Company';
            begin
                if Rec.CurrentCompany = InventoryCompanyName then
                    if Rec."External Document No." <> '' then begin
                        Error(ErrorMessage, Rec."No.");
                    end;
            end;

            trigger OnAfterAction();
            var
                AssociatedPurchaseHeader: Record "Purchase Header";
                IntercompanySalesHeader: Record "Sales Header";
            begin
                IntercompanySalesHeader.ChangeCompany('HEQS International Pty Ltd');
                IntercompanySalesHeader.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                if IntercompanySalesHeader.FindSet() then begin
                    IntercompanySalesHeader.Status := IntercompanySalesHeader.Status::Open;
                end;
            end;
        }
        modify("Create &Warehouse Shipment")
        {
            trigger OnBeforeAction();
            var
                SalesLine: Record "Sales Line";
                WarehouseRequest: Record "Warehouse Request";
                TempInteger: Integer;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
            begin
                Rec.Status := Rec.Status::Open;
                Rec.Modify();
                // Rec.RecreateSalesLines('Sell-to Customer');
                SalesLine.SetRange("Document No.", Rec."No.");
                if SalesLine.FindSet() then
                    repeat
                        SalesLine."Location Code" := 'NSW';
                        SalesLine.Modify();
                    until SalesLine.Next() = 0;
                TempInteger := 37;
                // message('OnBeforeActionCreating');
                // ReleaseSalesDoc.PerformManualRelease(Rec);
                Rec.Status := Rec.Status::Released;
                Rec.Modify();
                if WarehouseRequest.get(WarehouseRequest.Type::Outbound, SalesLine."Location Code", TempInteger, WarehouseRequest."Source Subtype"::"1", Rec."No.") then begin
                    // message('Please take a look how it is the 5763');
                    WarehouseRequest."Source Document" := WarehouseRequest."Source Document"::"Sales Order";
                    WarehouseRequest."Source No." := Rec."No.";
                    WarehouseRequest."Source Subtype" := 1;
                    WarehouseRequest."External Document No." := Rec."External Document No.";
                    WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Customer;
                    WarehouseRequest."Destination No." := Rec."Sell-to Customer No.";
                    WarehouseRequest."Shipping Advice" := WarehouseRequest."Shipping Advice"::Partial;
                    WarehouseRequest."Shipment Date" := Rec."Document Date";
                    WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
                    WarehouseRequest."Source Type" := 37;
                    WarehouseRequest."Location Code" := SalesLine."Location Code";
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Modify();
                end
                else begin
                    WarehouseRequest.Init();
                    WarehouseRequest."Source Document" := WarehouseRequest."Source Document"::"Sales Order";
                    WarehouseRequest."Source No." := Rec."No.";
                    WarehouseRequest."Source Subtype" := 1;
                    WarehouseRequest."External Document No." := Rec."External Document No.";
                    WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Customer;
                    WarehouseRequest."Destination No." := Rec."Sell-to Customer No.";
                    WarehouseRequest."Shipping Advice" := WarehouseRequest."Shipping Advice"::Partial;
                    WarehouseRequest."Shipment Date" := Rec."Document Date";
                    WarehouseRequest.Type := WarehouseRequest.Type::Outbound;
                    WarehouseRequest."Source Type" := 37;
                    WarehouseRequest."Location Code" := SalesLine."Location Code";
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Insert();
                    message('WR insert');
                end;

            end;

            trigger OnAfterAction();
            var
                WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
                BOMComponent: Record "BOM Component";
                SalesLine: Record "Sales Line";
            begin
                WarehouseShipmentLine.SetRange("Source No.", Rec."No.");
                if WarehouseShipmentLine.FindSet() then
                    repeat
                        BOMComponent.SetRange("Parent Item No.", WarehouseShipmentLine."Item No.");
                        if BOMComponent.findset() then
                            WarehouseShipmentLine."Pick-up Item" := false
                        else
                            WarehouseShipmentLine."Pick-up Item" := true;
                        WarehouseShipmentLine.Modify();
                    until WarehouseShipmentLine.Next() = 0;
            end;
        }
        // modify(Post)
        // {
        //     ApplicationArea = Warehouse;
        //     Caption = 'P&ost Shipment';
        //     Promoted = true;
        //     PromotedCategory = Category6;
        //     PromotedIsBig = true;
        //     ShortCutKey = 'F9';
        //     ToolTip = 'Post the items as shipped. Related pick documents are registered automatically.';

        //     // Check the Sales Order Posting Part first, and then go and copy the most of the same content.
        //     // Do the shipment post partfirst
        //     // Need to post the Warehouse shipment first and then goes to the post in the sales order

        //     trigger OnAfterAction()
        //     var
        //         InventorySalesOrder: Record "Sales Header";
        //         RetailPurchaseOrder: Record "Purchase Header";
        //         RetailSalesOrder: Record "Sales Header";
        //         RetailSalesOrderPage: Page "Sales Order";
        //         SessionID: Integer;
        //         Temp: Text;
        //         OK: Boolean;
        //     begin
        //         If Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
        //             // What is the shipment extener no
        //             InventorySalesOrder.Reset();
        //             InventorySalesOrder.SetRange("External Document No.", Rec."External Document No.");
        //             InventorySalesOrder.FindSet();
        //             //
        //             RetailPurchaseOrder.Reset();
        //             RetailPurchaseOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailPurchaseOrder.Get(InventorySalesOrder."Document Type", Rec."External Document No.");
        //             //
        //             RetailSalesOrder.Reset();
        //             RetailSalesOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailSalesOrder.Get(RetailPurchaseOrder."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //             RetailSalesOrder."External Document No." := InventorySalesOrder."No.";
        //             RetailSalesOrder.Modify();
        //             //
        //             Message('Posting Retail Company Sales Order.');
        //             // What about just open the page
        //             // RetailSalesOrderPage.SetRecord(RetailSalesOrder);
        //             // RetailSalesOrderPage.Run();
        //             Temp := InventorySalesOrder."External Document No.";
        //             InventorySalesOrder."External Document No." := '';
        //             InventorySalesOrder.Modify();
        //             SessionID := 50;
        //             StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesOrder."Sell-to Customer Name", RetailSalesOrder);
        //             // StopSession(SessionId, 'Logoff cache stress test session');
        //             // BackSession Didn't Work Try using Codeunit to Post Sales Header in Retail Company first.
        //             // InventorySalesOrder."External Document No." := Temp;
        //             // InventorySalesOrder.Modify();
        //         end;
        //     end;
        //     // trigger OnAfterAction()
        //     // var
        //     //     SalesPostYesNo: Codeunit ;
        //     //     RetailSalesOrder: Record "Sales Header";
        //     //     RetailPurchaseOrder: Record "Purchase Header";
        //     // begin
        //     //     if Rec."External Document No." <> '' then begin
        //     //         // OK := StartSession(SessionId, CodeUnit::"Cache Stress Test", CompanyName, CacheStressTestRec);
        //     //         //
        //     //         RetailPurchaseOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailPurchaseOrder.Get(Rec."Document Type", Rec."External Document No.");
        //     //         //
        //     //         RetailSalesOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailSalesOrder.Get(Rec."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //     //         //
        //     //         CurrPage.SetRecord(RetailSalesOrder);
        //     //         Message('Go to Retail And Post the Sales Order.');
        //     //         SalesPostYesNo.Run(RetailSalesOrder);
        //     //     end;
        //     // end;
        // }
        // modify(PostAndNew)
        // {
        //     ApplicationArea = Warehouse;
        //     Caption = 'P&ost Shipment';
        //     Promoted = true;
        //     PromotedCategory = Category6;
        //     PromotedIsBig = true;
        //     ShortCutKey = 'F9';
        //     ToolTip = 'Post the items as shipped. Related pick documents are registered automatically.';

        //     // Check the Sales Order Posting Part first, and then go and copy the most of the same content.
        //     // Do the shipment post partfirst
        //     // Need to post the Warehouse shipment first and then goes to the post in the sales order

        //     trigger OnAfterAction()
        //     var
        //         InventorySalesOrder: Record "Sales Header";
        //         RetailPurchaseOrder: Record "Purchase Header";
        //         RetailSalesOrder: Record "Sales Header";
        //         RetailSalesOrderPage: Page "Sales Order";
        //         SessionID: Integer;
        //         Temp: Text;
        //         OK: Boolean;
        //     begin
        //         If Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
        //             // What is the shipment extener no
        //             InventorySalesOrder.Reset();
        //             InventorySalesOrder.SetRange("External Document No.", Rec."External Document No.");
        //             InventorySalesOrder.FindSet();
        //             //
        //             RetailPurchaseOrder.Reset();
        //             RetailPurchaseOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailPurchaseOrder.Get(InventorySalesOrder."Document Type", Rec."External Document No.");
        //             //
        //             RetailSalesOrder.Reset();
        //             RetailSalesOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailSalesOrder.Get(RetailPurchaseOrder."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //             RetailSalesOrder."External Document No." := InventorySalesOrder."No.";
        //             RetailSalesOrder.Modify();
        //             //
        //             Message('Posting Retail Company Sales Order.');
        //             // What about just open the page
        //             // RetailSalesOrderPage.SetRecord(RetailSalesOrder);
        //             // RetailSalesOrderPage.Run();
        //             Temp := InventorySalesOrder."External Document No.";
        //             InventorySalesOrder."External Document No." := '';
        //             InventorySalesOrder.Modify();
        //             SessionID := 50;
        //             StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesOrder."Sell-to Customer Name", RetailSalesOrder);
        //             // StopSession(SessionId, 'Logoff cache stress test session');
        //             // BackSession Didn't Work Try using Codeunit to Post Sales Header in Retail Company first.
        //             // InventorySalesOrder."External Document No." := Temp;
        //             // InventorySalesOrder.Modify();
        //         end;
        //     end;
        //     // trigger OnAfterAction()
        //     // var
        //     //     SalesPostYesNo: Codeunit ;
        //     //     RetailSalesOrder: Record "Sales Header";
        //     //     RetailPurchaseOrder: Record "Purchase Header";
        //     // begin
        //     //     if Rec."External Document No." <> '' then begin
        //     //         // OK := StartSession(SessionId, CodeUnit::"Cache Stress Test", CompanyName, CacheStressTestRec);
        //     //         //
        //     //         RetailPurchaseOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailPurchaseOrder.Get(Rec."Document Type", Rec."External Document No.");
        //     //         //
        //     //         RetailSalesOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailSalesOrder.Get(Rec."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //     //         //
        //     //         CurrPage.SetRecord(RetailSalesOrder);
        //     //         Message('Go to Retail And Post the Sales Order.');
        //     //         SalesPostYesNo.Run(RetailSalesOrder);
        //     //     end;
        //     // end;
        // }
        // modify(PostAndSend)
        // {
        //     ApplicationArea = Warehouse;
        //     Caption = 'P&ost Shipment';
        //     Promoted = true;
        //     PromotedCategory = Category6;
        //     PromotedIsBig = true;
        //     ShortCutKey = 'F9';
        //     ToolTip = 'Post the items as shipped. Related pick documents are registered automatically.';

        //     // Check the Sales Order Posting Part first, and then go and copy the most of the same content.
        //     // Do the shipment post partfirst
        //     // Need to post the Warehouse shipment first and then goes to the post in the sales order

        //     trigger OnAfterAction()
        //     var
        //         InventorySalesOrder: Record "Sales Header";
        //         RetailPurchaseOrder: Record "Purchase Header";
        //         RetailSalesOrder: Record "Sales Header";
        //         RetailSalesOrderPage: Page "Sales Order";
        //         SessionID: Integer;
        //         Temp: Text;
        //         OK: Boolean;
        //     begin
        //         If Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
        //             // What is the shipment extener no
        //             InventorySalesOrder.Reset();
        //             InventorySalesOrder.SetRange("External Document No.", Rec."External Document No.");
        //             InventorySalesOrder.FindSet();
        //             //
        //             RetailPurchaseOrder.Reset();
        //             RetailPurchaseOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailPurchaseOrder.Get(InventorySalesOrder."Document Type", Rec."External Document No.");
        //             //
        //             RetailSalesOrder.Reset();
        //             RetailSalesOrder.ChangeCompany(InventorySalesOrder."Sell-to Customer Name");
        //             RetailSalesOrder.Get(RetailPurchaseOrder."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //             RetailSalesOrder."External Document No." := InventorySalesOrder."No.";
        //             RetailSalesOrder.Modify();
        //             //
        //             Message('Posting Retail Company Sales Order.');
        //             // What about just open the page
        //             // RetailSalesOrderPage.SetRecord(RetailSalesOrder);
        //             // RetailSalesOrderPage.Run();
        //             Temp := InventorySalesOrder."External Document No.";
        //             InventorySalesOrder."External Document No." := '';
        //             InventorySalesOrder.Modify();
        //             SessionID := 50;
        //             StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext", InventorySalesOrder."Sell-to Customer Name", RetailSalesOrder);
        //             // StopSession(SessionId, 'Logoff cache stress test session');
        //             // BackSession Didn't Work Try using Codeunit to Post Sales Header in Retail Company first.
        //             // InventorySalesOrder."External Document No." := Temp;
        //             // InventorySalesOrder.Modify();
        //         end;
        //     end;
        //     // trigger OnAfterAction()
        //     // var
        //     //     SalesPostYesNo: Codeunit ;
        //     //     RetailSalesOrder: Record "Sales Header";
        //     //     RetailPurchaseOrder: Record "Purchase Header";
        //     // begin
        //     //     if Rec."External Document No." <> '' then begin
        //     //         // OK := StartSession(SessionId, CodeUnit::"Cache Stress Test", CompanyName, CacheStressTestRec);
        //     //         //
        //     //         RetailPurchaseOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailPurchaseOrder.Get(Rec."Document Type", Rec."External Document No.");
        //     //         //
        //     //         RetailSalesOrder.ChangeCompany(Rec."Sell-to Customer Name");
        //     //         RetailSalesOrder.Get(Rec."Document Type", RetailPurchaseOrder."Sales Order Ref");
        //     //         //
        //     //         CurrPage.SetRecord(RetailSalesOrder);
        //     //         Message('Go to Retail And Post the Sales Order.');
        //     //         SalesPostYesNo.Run(RetailSalesOrder);
        //     //     end;
        //     // end;
        // }
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    // trigger OnClosePage();
    // var
    //     TempText: Text[20];
    //     hasPO: Boolean;
    //     POrecord: Record "Purchase Header";
    //     SORecord: Record "Sales Header";
    //     icrec: Record "sales Header";
    //     ISLrec: Record "Sales Line";
    //     SLrec: Record "Sales Line";
    //     ReleaseSalesDoc: Codeunit "Release Sales Document";
    // begin
    //     if (Rec.CurrentCompany <> InventoryCompanyName) and (Rec."No." <> '') then begin
    //         if POrecord.Get(Porecord."Document Type"::Order, Rec."Automate Purch.Doc No.") then begin
    //             Rec.UpdatePurchaseHeader(POrecord);
    //         end;

    //         // Action 2 SO
    //         SORecord.ChangeCompany(InventoryCompanyName);
    //         SORecord.SetCurrentKey("External Document No.");
    //         SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
    //         if (SORecord.findset) then
    //             repeat
    //                 ICrec.ChangeCompany(InventoryCompanyName);
    //                 ICRec.get(SORecord."Document type", SORecord."No.");
    //                 if Rec.Status = Rec.Status::Released then
    //                     if ICrec.status = Rec.Status::Released then
    //                         ReleaseSalesDoc.PerformManualRelease(ICrec);
    //                 ICrec."Ship-to Name" := Rec."Ship-to Name";
    //                 ICrec."Ship-to Address" := Rec."Ship-to Address";
    //                 ICrec.Ship := Rec.ship;
    //                 ICrec."Work Description" := Rec."Work Description";
    //                 Rec.CALCFIELDS("Work Description");
    //                 ICrec."Work Description" := Rec."Work Description";
    //                 ICRec.Status := Rec.Status;
    //                 ICREC.Modify();
    //                 SLrec.SetCurrentKey("Document No.");
    //                 SLrec.SetRange("Document No.", Rec."No.");
    //                 ISLrec.ChangeCompany(InventoryCompanyName);
    //                 if (SLrec.findset) then
    //                     repeat
    //                         if SLrec.Type = SLrec.Type::Item then begin
    //                             if ISLrec.Get(SLrec."Document Type", ICREC."No.", SLrec."Line No.") then begin
    //                                 // UPdata
    //                                 ISLrec.Type := SLrec.Type::Item;
    //                                 ISLrec."No." := SLrec."No.";
    //                                 ISLrec."Document Type" := SLrec."Document Type";
    //                                 ISLrec."Document No." := ICREC."No.";
    //                                 ISLrec.Type := SLrec.Type::Item;
    //                                 ISLrec."Line No." := SLrec."Line No.";
    //                                 ISLrec."No." := SLrec."No.";
    //                                 ISLrec."Description" := SLrec."Description";
    //                                 ISLrec.Quantity := SLrec.Quantity;
    //                                 ISLrec."Location Code" := SLrec."Location Code";
    //                                 ISLrec."Unit of Measure" := SLrec."Unit of Measure";
    //                                 ISLrec."Bin Code" := SLrec."Bin Code";
    //                                 // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
    //                                 ISLrec."BOM Item" := SLrec."BOM Item";
    //                                 ISLrec."Unit Price" := SLrec."Unit Price";
    //                                 ISLrec."Qty. to Ship" := SLrec."Qty. to Ship";
    //                                 ISLrec."Quantity Shipped" := SLrec."Quantity Shipped";
    //                                 ISLrec."Qty. to Invoice" := SLrec."Qty. to Invoice";
    //                                 // ISLrec.UpdateAmounts();
    //                                 ISLrec.Modify()
    //                             end
    //                             else begin
    //                                 ISLrec.Type := SLrec.Type::Item;
    //                                 ISLrec."No." := SLrec."No.";
    //                                 ISLrec."Document Type" := SLrec."Document Type";
    //                                 ISLrec."Document No." := ICREC."No.";
    //                                 ISLrec.Type := SLrec.Type::Item;
    //                                 ISLrec."Line No." := SLrec."Line No.";
    //                                 ISLrec."No." := SLrec."No.";
    //                                 ISLrec."Description" := SLrec."Description";
    //                                 ISLrec.Quantity := SLrec.Quantity;
    //                                 ISLrec."Location Code" := SLrec."Location Code";
    //                                 ISLrec."Unit of Measure" := SLrec."Unit of Measure";
    //                                 ISLrec."Bin Code" := SLrec."Bin Code";
    //                                 // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
    //                                 ISLrec."BOM Item" := Slrec."BOM Item";
    //                                 ISLrec."Unit Price" := SLrec."Unit Price";
    //                                 ISLrec."Qty. to Ship" := SLrec."Qty. to Ship";
    //                                 ISLrec."Quantity Shipped" := SLrec."Quantity Shipped";
    //                                 ISLrec."Qty. to Invoice" := SLrec."Qty. to Invoice";
    //                                 // ISLrec.UpdateAmounts();
    //                                 ISLrec.Insert();
    //                             end;
    //                         end;
    //                     until (SLrec.Next() = 0);
    //             until (SORecord.next() = 0);
    //     end;
    // end;


    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
        RetailSalesOrder: Record "Sales Header";
    begin
        IsICSalesHeader := false;
        if (Rec.CurrentCompany = InventoryCompanyName) and (Rec."External Document No." <> '') then
            IsICSalesHeader := true;

        if IsICSalesHeader then begin
            UpdateStatus();
            Currpage.Editable(false);
        end;
    end;

    local procedure UpdateStatus();
    var
        RetailSalesOrder: Record "Sales Header";
    begin
        RetailSalesOrder.ChangeCompany(Rec."Sell-to Customer Name");
        RetailSalesOrder.SetRange("Automate Purch.Doc No.", Rec."External Document No.");
        if RetailSalesOrder.FindSet() then
            Rec.Status := RetailSalesOrder.Status;
        Rec.Modify();
    end;

    local procedure ICAutomate(ICInboxTransaction: Record "IC Inbox Transaction");

    begin
        ICInboxTransaction.ChangeCompany('HEQS International Pty Ltd');
        // ICInboxTransaction.TestField("Transaction Source", ICInboxTransaction."Transaction Source"::"Created by Partner");
        // ICInboxTransaction.Validate("Line Action", ICInboxTransaction."Line Action"::Accept);
        // ICInboxTransaction.Modify();

        RunInboxTransactions(ICInboxTransaction);
    end;

    procedure RunInboxTransactions(var ICInboxTransaction: Record "IC Inbox Transaction")
    var
        ICInboxTransactionCopy: Record "IC Inbox Transaction";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        RunReport: Boolean;
    begin
        ICInboxTransaction.ChangeCompany('HEQS International Pty Ltd');
        ICInboxTransactionCopy.ChangeCompany('HEQS International Pty Ltd');

        ICInboxTransactionCopy.Copy(ICInboxTransaction);
        ICInboxTransactionCopy.SetRange("Source Type", ICInboxTransactionCopy."Source Type"::Journal);

        // if not ICInboxTransactionCopy.IsEmpty then
        //     RunReport := true;
        Commit();
        // REPORT.RunModal(REPORT::"Complete IC Inbox Action", RunReport, false, ICInboxTransaction);
    end;
}
