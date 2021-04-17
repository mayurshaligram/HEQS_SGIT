pageextension 50109 "Purchase Lines Subform_Ext" extends "Purchase Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
    }
    actions
    {
        addbefore(SelectMultiItems)
        {
            action("Expand BOM")
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Expand BOM';
                Image = NewItem;
                ToolTip = 'View BOM Sales line.';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.Reset();
                    PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
                    SalesTruthMgt.BOMAssignPurchase(PurchaseHeader);
                    Rec.Reset();
                    CurrPage.Update();
                end;
            }
            action("Hide BOM")
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Hide BOM';
                Image = Delete;
                ToolTip = 'Hide BOM Sales line.';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.Reset();
                    PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
                    SalesTruthMgt.BOMAssignPurchase(PurchaseHeader);
                    Rec.SetView('where ("BOM Item" = filter (= false))');
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnOpenPage();
    begin
        if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            Rec.SetView('where ("BOM Item" = filter (= false))');
            CurrPage.Update();
        end;
    end;
}