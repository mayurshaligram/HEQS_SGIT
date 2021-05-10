pageextension 50124 "Purchase Invoice Ext" extends "Purchase Invoice"
{
    actions
    {
        modify(CopyDocument)
        {
            trigger OnAfterAction()
            var
                PurchaseLine: Record "Purchase Line";
            begin
                Clear(PurchaseLine);
                PurchaseLine.Get(Rec."Document Type", Rec."No.");
                PayableMgt.PutPayableItem(PurchaseLine);
            end;
        }
    }

    var
        PayableMgt: Codeunit PayableMgt;
}