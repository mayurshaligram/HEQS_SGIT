tableextension 50105 "Warehouse Shipment Line_Ext" extends "Warehouse Shipment Line"
{
    // Need description
    // Field Number not within the system requirement
    fields
    {
        field(50100; "Pick-up Item"; Boolean)
        {
            Editable = false;
        }
        field(50101; "Original SO"; Code[20])
        {
            Editable = false;
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnBeforeInsert()
    var
        SalesHeader: Record "Sales Header";
    begin
        if (Rec.CurrentCompany() = SalesTruthMgt.InventoryCompany()) and (Rec."Source Document" = Rec."Source Document"::"Sales Order") then begin
            SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source No.");
            Rec."Original SO" := SalesHeader.RetailSalesHeader;
        end;
    end;
}