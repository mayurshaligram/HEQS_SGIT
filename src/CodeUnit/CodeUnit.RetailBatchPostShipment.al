codeunit 50111 RetailBatchPostShipment
{
    trigger OnRun();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            if SalesHeader.FindSet() then
                repeat
                    if SalesHeader."External Document No." <> '' then begin
                        SalesPostExt.Run(SalesHeader);
                        SalesHeader."External Document No." := '';
                        SalesHeader.Modify();
                        // SalesHeader.Reset();
                        // SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    end;
                until SalesHeader.Next() = 0;
        end;
    end;

    var
        SalesPostExt: Codeunit "Sales-Post (Yes/No) Ext";

        SalesTruthMgt: Codeunit "Sales Truth Mgt";
}