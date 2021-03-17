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
                Caption = 'ssssssss';
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
                begin
                    // Rec.Status := Rec.Status::Open;
                    // Rec.Modify();
                    // Rec.RecreateSalesLinesExt('Sell-to Customer');
                    // SalesLine.SetRange("Document No.", Rec."No.");
                    // if SalesLine.FindSet() then
                    //     repeat
                    //         SalesLine."Location Code" := 'NSW';
                    //         SalesLine.Modify();
                    //     until SalesLine.Next() = 0;
                    // TempInteger := 37;
                    // // message('OnBeforeActionCreating');
                    // // ReleaseSalesDoc.PerformManualRelease(Rec);
                    // Rec.Status := Rec.Status::Released;
                    // Rec.Modify();
                    Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext Inv", Rec);
                    // Post Purchase Order Invoice
                    // Post Intercompany Sales Order Invoice
                    SessionId := 51;
                    InventorySalesOrder.Reset();
                    InventorySalesOrder.ChangeCompany('HEQS International Pty Ltd');
                    InventorySalesOrder.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    InventorySalesOrder.FindSet();
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