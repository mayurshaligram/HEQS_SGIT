pageextension 50100 "Sales Order List" extends "Sales Order List"
{

    layout
    {
        addafter("No.")
        {
            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate PurchOrder No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the automated generated purchorder no';
                Visible = IsInventoryCompany;
            }
        }
    }
    actions
    {
        addbefore(Post)
        {
            action("Auto Post Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Auto Post Invoice';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    SalesLine: Record "Sales Line";
                    WarehouseRequest: Record "Warehouse Request";
                    TempInteger: Integer;
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    InventorySalesOrder: Record "Sales Header";
                    SessionId: Integer;
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseLine: Record "Purchase Line";

                    RetailSalesLine: Record "Sales Line";

                    TempSalesLine: Record "Sales Line";
                    TempItem: Record Item;
                    IsValideIC: Boolean;
                // Only the Sales Header associated with more then one inventory item sale line could be pass
                begin
                    IsValideIC := false;
                    TempSalesLine.SetRange("Document No.", Rec."No.");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    if TempSalesLine.FindSet() then
                        repeat
                            TempItem.Get(TempSalesLine."No.");
                            if TempItem.Type = TempItem.Type::Inventory then IsValideIC := true;
                        until TempSalesLine.Next() = 0;

                    if IsValideIC = false then Error('Please Only use the normal Posting');
                    SessionId := 51;

                    InventorySalesOrder.Reset();
                    InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
                    // InventorySalesOrder.SetRange("External Document No.", PurchaseHeader."No.");
                    InventorySalesOrder.FindLast();

                    PurchaseHeader.Reset();
                    PurchaseHeader.SetRange("Sales Order Ref", Rec."No.");
                    PurchaseHeader.FindSet();
                    PurchaseHeader."Due Date" := Rec."Due Date";
                    // PurchaseHeader."Vendor Invoice No." := InventorySalesOrder."No.";
                    PurchaseHeader."Gen. Bus. Posting Group" := 'DOMESTIC';
                    PurchaseHeader.Modify();

                    // RetailSalesLine.SetRange("Document No.", Rec."No.");
                    // if RetailSalesLine.FindSet() then
                    //     repeat
                    //         RetailSalesLine."Quantity Shipped" := RetailSalesLine."Qty. to Ship";
                    //         RetailSalesLine."Qty. to Ship" := 0;
                    //         RetailSalesLine.Modify();
                    //     until RetailSalesLine.Next() = 0;

                    PurchaseLine.Reset();
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if PurchaseLine.FindSet() then
                        repeat
                            PurchaseLine."Gen. Bus. Posting Group" := 'DOMESTIC';
                            PurchaseLine.Modify();
                        until PurchaseLine.Next() = 0;


                    Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", PurchaseHeader);
                    Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext Inv", Rec);
                    // Post Purchase Order Invoice
                    // Post Intercompany Sales Order Invoice

                    StartSession(SessionId, CodeUnit::"Sales-Post (Yes/No) Ext Inv",
                        'HEQS International Pty Ltd', InventorySalesOrder);
                end;

            }
        }
    }
    var
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    trigger OnOpenPage();
    begin
        IsInventoryCompany := true;
        if Rec.CurrentCompany = InventoryCompanyName then begin
            IsInventoryCompany := false;
        end;

        Rec.SetView('sorting (Rec."No.") order(descending)');
        Rec.SetRange("No.");
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec);
    end;


}