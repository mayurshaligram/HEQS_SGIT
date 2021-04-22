codeunit 50112 "HotFix"
{
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
    begin
        SalesHeader.Reset();
        SalesHeader.ChangeCompany(CompanyRecord.Name);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                BOMCorrection(SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    local procedure BOMCorrection(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.ChangeCompany(SalesHeader.CurrentCompany());
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("No.", SalesHeader."No.");
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
        end
        else
            BOMSupplement(SalesLine);
    end;

    local procedure CheckBOM(var SalesLine: Record "Sales Line"; var Item: Record Item);
    var
        BOMComponent: Record "BOM Component";
        TempLineNo: Integer;
        BOMSalesLine: Record "Sales Line";
        CorrectSalesLine
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
                        MainSalesLine.Delete(true);
                        CorrectMainSalesLine.Insert(true);
                    end;
            until BOMComponent.Next() = 0;
    end;

    local procedure BOMSupplement(var SalesLine: Record "Sales Line")
    begin

    end;

    // Quick Fix International
    local procedure Task2();
    begin

    end;
}