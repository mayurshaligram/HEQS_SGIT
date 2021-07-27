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

}