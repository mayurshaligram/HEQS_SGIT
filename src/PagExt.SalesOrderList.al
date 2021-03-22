pageextension 50100 "Sales Order List" extends "Sales Order List"
{
    layout
    {
        addafter("No.")
        {
            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate Purch.Doc No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                Visible = isInventoryCompany;
            }
        }
    }
    actions
    {
        addafter(Post)
        {
            action(sssssss)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Auto IC Post';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
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
                begin
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
        isInventoryCompany: Boolean;

    trigger OnOpenPage();
    var
        CompanyRecord: Record "Company Information";
    begin
        // CompanyRecord.Get(Rec.CurrentCompany);
        // Message(CompanyRecord.Id);
        isInventoryCompany := true;
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then
            isInventoryCompany := false;
    end;


}