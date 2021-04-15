pageextension 50115 "Source Documents Ext" extends "Source Documents"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("Original SO59989"; Rec."Original SO")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        IsInventory: Boolean;
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnAfterGetCurrRecord();
    begin
        IsInventory := false;
        If Rec.CurrentCompany() = SalesTruthMgt.InventoryCompany() then
            IsInventory := true;
    end;
}