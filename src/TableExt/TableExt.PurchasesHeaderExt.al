tableextension 50101 "Purchase Header_Ext" extends "Purchase Header"
{
    Caption = 'Purchase Header_Ext';
    fields
    {
        field(50100; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }
        field(50101; "Sales Order Ref"; Text[20])
        {
            Caption = 'Automate Sales.Doc No.';
            Editable = false;
        }
    }

    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        PayableMgt: Codeunit PayableMgt;

    trigger OnInsert()
    begin
        PayableMgt.PurchaseHeaderInsertPayable(Rec);
    end;


    trigger OnModify()
    var
        Payable: Record Payable;
    begin
        if Rec.Amount <> xRec.Amount then
            ModifyPayableAmount()
    end;

    local procedure ModifyPayableAmount()
    var
        Payable: Record Payable;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(Rec."No.") then begin
            Rec.CalcFields("Amount Including VAT");
            Payable."AUD" := Rec."Amount Including VAT";
        end
    end;


    // local procedure PutItem()
    // var
    //     PurchaseLine: Record "Purchase Line";
    // begin
    //     PurchaseLine.Reset();
    //     PurchaseLine.SetRange("Document Type", Rec."Document Type");
    //     PurchaseLine.SetRange("Document No.", Rec."No.");
    //     if PurchaseLine.MO
    // end;
}