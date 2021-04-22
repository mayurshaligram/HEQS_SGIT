codeunit 50112 "HotFix"
{
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnRun();
    var
        CompanyRecord: Record Company;
    begin
        if ('HEQS International Pty Ltd' <> CompanyRecord.Name) then begin
            Task1(CompanyRecord);
        end
        else
            Task2();
    end;


    local procedure Task1(var CompanyRecord: Record Company);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempStatus: Enum "Sales Document Status";
        PurchaseHeader: Record "Purchase Header";
    begin
        SalesHeader.Reset();
        SalesHeader.ChangeCompany(CompanyRecord.Name);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                TempStatus := SalesHeader.Status;
                SalesHeader.Status := SalesHeader.Status::Open;
                PurchaseHeader.Get(SalesHeader."Document Type", SalesHeader."Automate Purch.Doc No.");
                PurchaseHeader.Status := PurchaseHeader.Status::Open;
                SalesHeader.Modify();
                PurchaseHeader.Modify();
                BOMCorrection(SalesHeader);
                SalesTruthMgt.QuickFix(SalesHeader);
                SalesHeader.Status := TempStatus;
                PurchaseHeader.Status := TempStatus;
                SalesHeader.Modify();
            until SalesHeader.Next() = 0;
    end;



    local procedure BOMCorrection(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.ChangeCompany(SalesHeader.CurrentCompany());
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Correction(SalesLine);
            until SalesLine.Next() = 0;
    end;


    // BOM Correction
    // If sales is  main item 
    //     Check the associated whether correct
    // If sales is  non item
    //     if is non-inventory item
    //          delete consecutive bom
    //          delete po ic
    //     if is bom item
    //          check front item main (if not front delete) 
    local procedure Correction(var SalesLine: Record "Sales Line");
    var
        Item: Record Item;
    begin
        Item.Reset();
        Item.ChangeCompany(SalesLine.CurrentCompany);
        if (SalesLine."BOM Item" = false) and (SalesLine.Type = SalesLine.Type::Item) then begin
            Item.Get(SalesLine."No.");
            if Item.Type = Item.Type::Inventory then
                CheckBOM(SalesLine, Item)
            // else is service
            else
                DeleteConsecutiveBOM(SalesLine);
        end
        else
            DeleteICSalesLine(SalesLine);
    end;

    local procedure CheckBOM(var SalesLine: Record "Sales Line"; var Item: Record Item);
    var
        BOMComponent: Record "BOM Component";
        TempLineNo: Integer;
        BOMSalesLine: Record "Sales Line";
        CorrectSalesLine: Record "Sales Line";
    begin
        TempLineNo := SalesLine."Line No.";
        BOMComponent.Reset();
        BOMComponent.ChangeCompany(SalesLine.CurrentCompany());
        BOMComponent.SetRange("Parent Item No.", Item."No.");
        if BOMComponent.FindSet() then
            repeat
                TempLineNo += 10000;
                if BOMSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo) then
                    if BOMSalesLine."No." <> BOMComponent."No." then begin
                        CorrectSalesLine := SalesLine;
                        SalesLine.Delete(true);
                        CorrectSalesLine.Insert(true);
                    end;
            until BOMComponent.Next() = 0;
    end;

    local procedure DeleteConsecutiveBOM(var SalesLine: Record "Sales Line");
    var
        TempLineNo: Integer;
        ConsecutiveLine: Record "Sales Line";
    begin
        DeleteICSalesLine(SalesLine);
        TempLineNo := SalesLine."Line No." + 10000;
        if ConsecutiveLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo) then
            repeat
                if ConsecutiveLine."BOM Item" = false then
                    DeleteFlowLine(ConsecutiveLine)
                else
                    TempLineNo += 10000;
                if ConsecutiveLine.Get(SalesLine."Document Type", SalesLine."Document No.", TempLineNo) = false then exit;
            until ConsecutiveLine."BOM Item" = false;
    end;

    local procedure DeleteFlowLine(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        purchaseLine: Record "Purchase Line";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        PurchaseLine.Get(SalesLine."Document Type", SalesHeader."Automate Purch.Doc No.", SalesLine."Line No.");
        PurchaseLine.Delete();

        DeleteICSalesLine(SalesLine);
    end;

    local procedure DeleteICSalesLine(var SalesLine: Record "Sales Line");
    var
        ICSalesLine: Record "Sales Line";
        ICSalesHeader: Record "Sales Header";
    begin
        ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
        ICSalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        ICSalesHeader.SetRange("Document Type", SalesLine."Document Type");
        ICSalesHeader.SetRange(RetailSalesHeader, SalesLine."No.");
        if ICSalesHeader.FindSet() then begin
            if ICSalesLine.Get(ICSalesHeader."Document Type", ICSalesHeader."No.", SalesLine."Line No.") then
                ICSalesLine.Delete();
        end;
    end;

    // Quick Fix International
    local procedure Task2();
    var
        SalesHeader: Record "Sales Header";
        TempStatus: Enum "Sales Document Status";
    begin
        TempStatus := SalesHeader.Status;
        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader.Modify();
        SalesTruthMgt.QuickFix(SalesHeader);
        SalesHeader.Status := TempStatus;
        SalesHeader.Modify();
    end;
}