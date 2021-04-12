pageextension 50114 "Source Documents Ext" extends "Source Documents"
{
    layout
    {
        addafter("Source No.")
        {
            field("Original SO"; Rec."Original SO")
            {
                Visible = Not IsInventory;
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the number of the Original SO document that the entry originates from.';
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