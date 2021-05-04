pageextension 50123 PostedSalesInvoiceListExt extends "Posted Sales Invoices"
{
    layout
    {
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