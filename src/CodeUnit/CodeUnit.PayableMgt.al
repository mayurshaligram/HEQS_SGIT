codeunit 50113 PayableMgt
{
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    procedure PurchaseHeaderInsertPayable(var PurchaseHeader: Record "Purchase Header")
    var
        Payable: Record Payable;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseHeader."No.") then exit;
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        Payable."No." := PurchaseHeader."No.";
        PurchaseHeader.CalcFields("Amount Including VAT");
        PurchaseHeader.CalcFields("Amt. Rcd. Not Invoiced (LCY)");
        // CRUD Method for the Purchase Line determine the Item
        Payable."AUD" := PurchaseHeader."Amount Including VAT";

        // Payable."Amount Received Not Invoiced" := PurchaseHeader.recei
        // Payable."Date of Payment" := Rec."Due Date";
        Payable."Currency Code" := PurchaseHeader."Currency Code";
        Payable.Company := PurchaseHeader.CurrentCompany;
        Payable.Vendor := PurchaseHeader."Buy-from Vendor Name";
        Payable."Vendor Invoice No." := PurchaseHeader."Vendor Invoice No.";
        Payable."Amount Received Not Invoiced" := PurchaseHeader."Amt. Rcd. Not Invoiced (LCY)";
        Payable."Schedule Date" := PurchaseHeader."Due Date";
        Payable."Payment Method Code" := PurchaseHeader."Payment Method Code";
        // AUD Cal
        Payable.Insert()
        // ? Payment Method Code
        // Payable."Source of Cash" := Rec."Payment Method Code";
    end;

    procedure PurchInvHeaderInsertPayable(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        Payable: Record Payable;
        PurchaseHeader: Record "Purchase Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        if PurchInvHeader."Pay-to Name" = SalesTruthMgt.InventoryCompany() then exit;
        if PurchInvHeader."Buy-from Vendor Name" = 'HEQS International' then exit;
        PurchaseHeader.Reset();
        PurchaseHeader.ChangeCompany(PurchInvHeader.CurrentCompany());
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchInvHeader."Order No.") then begin
            if PurchaseHeader."Sales Order Ref" <> '' then exit;
        end;
        // No Concern About the Inter Purch. Inv
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        Payable.SetRange("Posted Invoice No", PurchInvHeader."No.");
        if Payable.FindSet() then exit;
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        Payable."No." := PurchInvHeader."No.";
        Payable."Posted Invoice No" := PurchInvHeader."No.";
        // CRUD Method for the Purchase Line determine the Item
        PurchInvHeader.CalcFields("Amount Including VAT");
        PurchInvHeader.CalcFields("Remaining Amount");
        Payable."AUD" := PurchInvHeader."Amount Including VAT";
        // Payable."Amount Received Not Invoiced" := PurchaseHeader.recei
        // Payable."Date of Payment" := Rec."Due Date";
        Payable."Currency Code" := PurchInvHeader."Currency Code";
        Payable.Company := PurchInvHeader.CurrentCompany;
        Payable.Vendor := PurchInvHeader."Buy-from Vendor Name";
        Payable."Vendor Invoice No." := PurchInvHeader."Vendor Invoice No.";
        Payable."USD" := PurchInvHeader."Remaining Amount";
        // Payable."Amount Received Not Invoiced" := PurchInvHeader."Amt. Rcd. Not Invoiced (LCY)";
        Payable."Schedule Date" := PurchInvHeader."Due Date";
        Payable."Payment Method Code" := PurchInvHeader."Payment Method Code";
        Payable.Insert();
        PurchInvLine.Reset();
        PurchInvLine.ChangeCompany(PurchInvHeader.CurrentCompany);
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            PutPayableItemForPurchInvLine(PurchInvLine);
        // ? Payment Method Code
        // Payable."Source of Cash" := Rec."Payment Method Code";
    end;

    procedure ModifyPayable(var PurchaseHeader: Record "Purchase Header")
    var
        Payable: Record Payable;
    begin
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseHeader."No.") = false then exit;
        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        Payable."No." := PurchaseHeader."No.";
        PurchaseHeader.CalcFields("Amount Including VAT");
        PurchaseHeader.CalcFields("Amt. Rcd. Not Invoiced (LCY)");
        // CRUD Method for the Purchase Line determine the Item
        Payable."AUD" := PurchaseHeader."Amount Including VAT";

        // Payable."Amount Received Not Invoiced" := PurchaseHeader.recei
        // Payable."Date of Payment" := Rec."Due Date";
        Payable."Currency Code" := PurchaseHeader."Currency Code";
        Payable.Company := PurchaseHeader.CurrentCompany;
        Payable.Vendor := PurchaseHeader."Buy-from Vendor Name";
        Payable."Vendor Invoice No." := PurchaseHeader."Vendor Invoice No.";
        Payable."Amount Received Not Invoiced" := PurchaseHeader."Amt. Rcd. Not Invoiced (LCY)";
        Payable."Schedule Date" := PurchaseHeader."Due Date";
        Payable."Payment Method Code" := PurchaseHeader."Payment Method Code";
        // AUD Cal
        Payable.Modify();
    end;


    procedure PutPayableItem(var PurchaseLine: Record "Purchase Line")
    var
        Payable: Record Payable;
        TempPurchaseLine: Record "Purchase Line";
        TempPurchaseHeader: Record "Purchase Header";
        TempText: Text[2000];
    begin
        TempPurchaseLine.Reset();
        TempPurchaseLine.ChangeCompany(PurchaseLine.CurrentCompany());
        TempPurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
        TempPurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");

        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchaseLine."Document No.") then begin
            Payable.Item := '';
            if TempPurchaseLine.FindSet() then begin
                TempPurchaseHeader.Reset();
                TempPurchaseHeader.ChangeCompany(PurchaseLine.CurrentCompany);
                if TempPurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
                    TempPurchaseHeader.CalcFields("Amount Including VAT");
                    TempPurchaseHeader.CalcFields("Amt. Rcd. Not Invoiced (LCY)");
                    Payable."AUD" := TempPurchaseHeader."Amount Including VAT";
                    Payable."Amount Received Not Invoiced" := TempPurchaseHeader."Amt. Rcd. Not Invoiced (LCY)";

                    Payable."Currency Code" := TempPurchaseHeader."Currency Code";
                    Payable.Company := TempPurchaseHeader.CurrentCompany;
                    Payable."Vendor Invoice No." := TempPurchaseHeader."Vendor Invoice No.";
                    Payable.Vendor := TempPurchaseHeader."Buy-from Vendor Name";
                    Payable."Schedule Date" := TempPurchaseHeader."Due Date";
                    Payable."Payment Method Code" := TempPurchaseHeader."Payment Method Code";
                end;
                repeat
                    Payable.Item := Payable.Item + Format(TempPurchaseLine.Quantity) + '*' + TempPurchaseLine.Description + '\';
                until TempPurchaseLine.Next() = 0;
            end;
            Payable.Modify();
        end;

    end;

    procedure PutPayableItemForPurchInvLine(var PurchInvLine: Record "Purch. Inv. Line")
    var
        Payable: Record Payable;
        TempPurchInvLine: Record "Purch. Inv. Line";
        TempPurchInvHeader: Record "Purch. Inv. Header";
        TempText: Text[2000];
    begin
        TempPurchInvLine.Reset();
        TempPurchInvLine.ChangeCompany(PurchInvLine.CurrentCompany());
        TempPurchInvLine.SetRange("Document No.", PurchInvLine."Document No.");

        Payable.Reset();
        Payable.ChangeCompany(SalesTruthMgt.InventoryCompany());
        if Payable.Get(PurchInvLine."Document No.") then begin
            Payable.Item := '';
            if TempPurchInvLine.FindSet() then begin
                TempPurchInvHeader.Reset();
                TempPurchInvHeader.ChangeCompany(PurchInvLine.CurrentCompany);
                if TempPurchInvHeader.Get(PurchInvLine."Document No.") then begin
                    TempPurchInvHeader.CalcFields("Amount Including VAT");
                    TempPurchInvHeader.CalcFields("Remaining Amount");
                    Payable."AUD" := TempPurchInvHeader."Amount Including VAT";
                    Payable.USD := TempPurchInvHeader."Remaining Amount";

                    Payable."Currency Code" := TempPurchInvHeader."Currency Code";
                    Payable.Company := TempPurchInvHeader.CurrentCompany;
                    Payable."Vendor Invoice No." := TempPurchInvHeader."Vendor Invoice No.";
                    Payable.Vendor := TempPurchInvHeader."Buy-from Vendor Name";
                    Payable."Schedule Date" := TempPurchInvHeader."Due Date";
                    Payable."Payment Method Code" := TempPurchInvHeader."Payment Method Code";
                end;
                repeat
                    Payable.Item := Payable.Item + Format(TempPurchInvLine.Quantity) + '*' + TempPurchInvLine.Description + '\';
                until TempPurchInvLine.Next() = 0;
            end;
            Payable.Modify();

        end;

    end;

}