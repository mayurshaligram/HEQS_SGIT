codeunit 50113 PayableMgt
{
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    procedure PurchaseHeaderInsertPayable(PurchaseHeader: Record "Purchase Header")
    var
        Payable: Record Payable;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseHeader."No.") then exit;
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        Payable."No." := PurchaseHeader."No.";
        // CRUD Method for the Purchase Line determine the Item
        Payable.AUD := PurchaseHeader.Amount;
        // Payable."Date of Payment" := Rec."Due Date";
        Payable."Schedule Date" := PurchaseHeader."Due Date";
        Payable.Insert()
        // ? Payment Method Code
        // Payable."Source of Cash" := Rec."Payment Method Code";
    end;

    procedure PutPayableItem(PurchaseLine: Record "Purchase Line")
    var
        Payable: Record Payable;
        TempPurchaseLine: Record "Purchase Line";
        TempText: Text[2000];
    begin
        TempPurchaseLine.Reset();
        TempPurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
        TempPurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");

        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseLine."Document No.") then begin
            Payable.Item := '';
            if TempPurchaseLine.FindSet() then
                repeat
                    Payable.Item := Payable.Item + Format(TempPurchaseLine.Quantity) + '*' + TempPurchaseLine.Description + '\';
                until TempPurchaseLine.Next() = 0;
        end;
        Payable.Modify();
    end;

}