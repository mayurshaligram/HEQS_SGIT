pageextension 50100 "Sales Order List" extends "Sales Order List"
{
    layout
    {
        addafter("No.")
        {
            field("Purchase Order"; Rec."Automate Purch.Doc No.")
            {
                Caption = 'Automate Purch.Doc No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                Visible = isInventoryCompany;
            }
        }
    }
    var
        isInventoryCompany: Boolean;

    trigger OnOpenPage();
    begin
        isInventoryCompany := true;
        if Rec.CurrentCompany = 'HEQS International Pty Ltd' then
            isInventoryCompany := false;
    end;
}