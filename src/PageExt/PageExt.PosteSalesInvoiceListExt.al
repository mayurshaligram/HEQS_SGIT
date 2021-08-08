pageextension 50123 PostedSalesInvoiceListExt extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Order No.")
        {
            field("Prepayment Order No."; Rec."Prepayment Order No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            field("Prepayment Invoice"; Rec."Prepayment Invoice")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            field("Posting Description"; Rec."Posting Description")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Sell-to E-Mail"; Rec."Sell-to E-Mail")
            {
                Caption = 'Email';
                ApplicationArea = Basic, Suite;
            }
            field("Posted PI No"; Rec."Posted PI No")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted PI No.';
                Visible = Not IsInventoryCompany;
            }
            field("Posted SI No (Inventory CO.)"; Rec."Posted SI No (Inventory CO.)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted SI No (Inventory CO.)';
                Visible = Not IsInventoryCompany;
            }
            field("Posted PI No(Original Co.)"; Rec."Posted PI No(Original Co.)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted PI No(Original Co.)';
                Visible = IsInventoryCompany;
            }
            field("Posted SI No (Original CO.)"; Rec."Posted SI No (Original CO.)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted SI No (Original CO.)';
                Visible = IsInventoryCompany;
            }

        }
        addafter("Currency Code")
        {
            field("Your Reference"; Rec."Your Reference")
            {
                Caption = 'Your Reference';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Reference';
                Visible = true;
            }
        }
    }
    var
        IsInventoryCompany: Boolean;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

    trigger OnOpenPage()
    begin
        IsInventoryCompany := false;
        if Rec.CurrentCompany = InventoryCompanyName then begin
            IsInventoryCompany := true;
        end;
    end;

}