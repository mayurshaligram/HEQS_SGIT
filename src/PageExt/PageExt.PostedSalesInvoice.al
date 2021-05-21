pageextension 50121 PostedSalesInvoiceExt extends "Posted Sales Invoice"
{
    actions
    {
        addbefore("&Track Package")
        {
            action("Modify Reference")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Modify Reference';
                Image = ItemTracking;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Modify Reference';
                trigger OnAction();
                var
                    ChangePostedInvoice: Page ChangePostedSalesInvoice;
                begin
                    ChangePostedInvoice.SetRecord(Rec);
                    ChangePostedInvoice.Run();
                end;
            }
        }

    }



    var
        IsSuper: Boolean;

    trigger OnAfterGetRecord();
    var
        user: Record User;
    begin
        user.Get(Database.UserSecurityId());
        if (User."Full Name" = 'Pei Xu') or (User."Full Name" = 'Karen Huang') then begin
            IsSuper := true;
        end;
    end;
}