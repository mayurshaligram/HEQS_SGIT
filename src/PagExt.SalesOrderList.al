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
                    Codeunit.Run(Codeunit::"Sales-Post (Yes/No) Ext", Rec);
                end;

            }
        }
    }
    var
        isInventoryCompany: Boolean;

    trigger OnOpenPage();
    begin
        isInventoryCompany := true;
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then
            isInventoryCompany := false;
    end;


}