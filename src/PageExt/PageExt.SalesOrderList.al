pageextension 50101 "Sales Order List" extends "Sales Order List"
{
    Editable = true;

    layout
    {
        addafter("External Document No.")
        {

            field("Your Reference"; Rec."Your Reference")
            {
                Caption = 'Your Reference';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Reference';
                Visible = Not IsInventoryCompany;
            }
        }
        addafter("No.")
        {
            field("Retail SalesHeader"; Rec."RetailSalesHeader")
            {
                Caption = 'Original SO';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the Retail Sales header No';
                Visible = IsInventoryCompany;
            }

            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate PurchOrder No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the automated generated purchorder No';
                Visible = Not IsInventoryCompany;
            }
        }
        addafter(Status)
        {
            field(IsDeliveried; FORMAT(Rec.IsDeliveried))
            {
                Caption = 'IsDeliveried/IsPicked';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the Sales Order has been deliveried.';
                Visible = true;
            }
        }
        addafter("Location Code")
        {
            field(Delivery; Rec.Delivery)
            {
                Caption = 'Delivery Type';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies delivery or pick up';
                Visible = false;
            }
        }
    }
    actions
    {

        modify(Post)
        {
            Visible = false;
        }
        modify(PostAndSend)
        {
            Visible = false;
        }
        modify("Post &Batch")
        {
            Visible = false;
        }
        modify("Preview Posting")
        {
            Visible = Not IsInventoryCompany;
        }
        modify(Release)
        {
            Visible = IsPei;
        }
        addbefore(Post)
        {
            action("TESTING FOR SalesPostYESNOEXT")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Testing for sales Post yes no ext';
                Image = PostOrder;
                Visible = true;
                Promoted = true;
                PromotedCategory = Category7;
                trigger OnAction();
                var
                    SalesPostYesNoExt: Codeunit "Sales-Post (Yes/No) Ext";
                begin
                    SalesPostYesNoExt.Run(Rec);
                end;
            }
            action("Auto Post Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Auto Post Invoice';
                Image = PostOrder;
                Visible = Not IsInventoryCompany;
                Promoted = true;
                PromotedCategory = Category7;
                // PromotedOnly = true;
                // PromotedIsBig = true;
                trigger OnAction();
                var
                    SalesLine: Record "Sales Line";
                    WarehouseRequest: Record "Warehouse Request";
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    InventorySalesOrder: Record "Sales Header";
                    SessionId: Integer;
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseLine: Record "Purchase Line";
                    PostedSalesInvoiceHeader: Record "Sales Invoice Header";
                    NoSeries: Record "No. Series";
                    NoSeriesMgt: Codeunit NoSeriesManagement;
                    RetailSalesLine: Record "Sales Line";
                    VendorInvoiceNo: Code[20];
                    TempText: Text[20];
                    TempNum: Text[20];
                    TempInteger: Integer;
                    TempSalesLine: Record "Sales Line";
                    TempItem: Record Item;
                    IsValideIC: Boolean;
                    Text1: Label 'Please only post invoice in the retail company %1';
                    PostedPurchaseInvoice: Record "Purch. Inv. Header";
                    // Only the Sales Header associated with more then one inventory item sale line could be pass
                    Shipped: Boolean;
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SetSelectionFilter(SalesHeader);
                    if SalesHeader.FindSet() then
                        repeat
                            SalesTruthMgt.AutoPost(SalesHeader);
                        until SalesHeader.Next() = 0;
                end;

            }
        }
        addfirst(processing)
        {
            action("&Import")
            {
                Caption = '&Import';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = IsFurniture;
                ToolTip = 'Import data from excel.';

                trigger OnAction()
                var
                begin
                    page.run(50111);
                end;
            }
        }
        modify("Create &Warehouse Shipment")
        {
            trigger OnBeforeAction();
            var
                WhseRequestMgt: Codeunit WhseRequestMgt;
                Nothing: Integer;
                WhseRequest: Record "Warehouse Request";
                NewWhseRequest: Record "Warehouse Request";
            begin
                Nothing := 1;
                WhseRequestMgt.ValidateWhseRequest(Rec);
                // WhseRequest.Reset();
                // WhseRequest.SetRange("Source No.", Rec."No.");
                // if WhseRequest.FindFirst() then begin
                //     if WhseRequest."Location Code" <> REc."Location Code" then begin
                //         NewWhseRequest.Reset();
                //         NewWhseRequest := WhseRequest;
                //         NewWhseRequest."Location Code" := Rec."Location Code";
                //         WhseRequest.Delete();
                //         Database.Commit();
                //         NewWhseRequest.Insert();
                //         Database.Commit();
                //     end
                // end;
            end;

            trigger OnAfterAction();
            var
                WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
                BOMComponent: Record "BOM Component";
                SalesLine: Record "Sales Line";
            begin
                if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then begin
                    WarehouseShipmentLine.SetRange("Source No.", Rec."No.");
                    if WarehouseShipmentLine.FindSet() then
                        repeat
                            BOMComponent.SetRange("Parent Item No.", WarehouseShipmentLine."Item No.");
                            if BOMComponent.findset() then
                                WarehouseShipmentLine."Pick-up Item" := false
                            else
                                WarehouseShipmentLine."Pick-up Item" := true;
                            WarehouseShipmentLine."Original SO" := Rec.RetailSalesHeader;
                            WarehouseShipmentLine.Modify();

                        until WarehouseShipmentLine.Next() = 0;
                    Rec.Status := Rec.Status::Released;
                    Rec.Modify();
                end;
            end;
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        IsPei: Boolean;
        IsFurniture: Boolean;

    trigger OnOpenPage();
    var
        SalesHeader: Record "Sales Header";
        SalesPostExt: Codeunit "Sales-Post (Yes/No) Ext";
        PurchaseHeader: Record "Purchase Header";

        SessionID: Integer;
        OK: Boolean;
        User: Record User;
    begin
        IsFurniture := false;
        if Rec.CurrentCompany = 'HEQS Furniture Pty Ltd' then
            IsFurniture := true;
        User.Get(Database.UserSecurityId());
        if User."Full Name" = 'Pei Xu' then IsPei := true;
        if SalesHeader.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            if SalesHeader.FindSet() then
                repeat
                    if SalesHeader."External Document No." <> '' then begin
                        OK := STARTSESSION(SessionId, CODEUNIT::RetailBatchPostShipment);
                        // SalesPostExt.Run(SalesHeader);
                        if OK = false then
                            ERROR('The session was not started successfully.');
                        // SalesHeader."External Document No." := '';
                        // SalesHeader.Modify();
                    end;
                until SalesHeader.Next() = 0;
        end;

        IsInventoryCompany := false;
        if Rec.CurrentCompany = InventoryCompanyName then begin
            IsInventoryCompany := true;
        end;

        // Check Empty Auto Purchase Order 
        SalesHeader.Reset();
        if SalesHeader.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            SalesHeader.SetRange("Automate Purch.Doc No.", '');
        if SalesHeader.FindSet() then
            repeat
                PurchaseHeader.Reset();
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                PurchaseHeader.SetRange("Sales Order Ref", SalesHeader."No.");
                if PurchaseHeader.FindSet() then
                    SalesHeader."Automate Purch.Doc No." := PurchaseHeader."No.";
                SalesHeader.Modify();
            until SalesHeader.Next = 0;

        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;
}