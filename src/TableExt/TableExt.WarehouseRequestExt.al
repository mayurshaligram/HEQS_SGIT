tableextension 50123 "Warehouse Request Ext" extends "Warehouse Request"
{
    fields
    {
        field(50103; "Original SO"; Code[20])
        {
            Editable = false;
        }
    }

    trigger OnBeforeInsert();
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec.CurrentCompany = SalesTruthMgt.InventoryCompany() then
            Rec."Original SO" := SalesHeader.RetailSalesHeader;
    end;

    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
}