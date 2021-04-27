pageextension 50121 PostedSalesInvoiceExt extends "Posted Sales Invoice"
{
    layout
    {
        modify("Ship-to Name")
        {
            Editable = IsSuper;
        }
        modify("Bill-to Name")
        {
            Editable = true;
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