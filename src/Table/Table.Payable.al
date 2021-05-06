table 50106 Payable
{

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Item; Text[2000])
        {

        }
        field(3; "AUD"; Decimal)
        {
        }
        field(4; "Schedule Date"; Date)
        {
        }
        field(5; "Payment Method Code"; Code[10])
        {

        }
        field(6; "USD"; Decimal)
        {

        }
        field(7; "Date of Payment"; Date)
        {

        }
        field(8; Note; Text[200])
        {

        }

        field(9; "Director Approval"; Text[50])
        {

        }
        field(10; "Account Details"; Text[200])
        {

        }
        field(11; "Posted Invoice No"; Code[20])
        {

        }
        field(12; Approval; Boolean)
        {
            trigger OnValidate()
            var
                User: Record User;
            begin
                if Approval = true then begin
                    User.Get(Database.UserSecurityId());
                    Rec."Director Approval" := User."Full Name";
                end
                else begin
                    Rec."Director Approval" := '';
                end;
            end;
        }
        field(13; "Amount Received Not Invoiced"; Decimal)
        {

        }
        field(14; Company; Text[30])
        {

        }
        field(15; "Currency Code"; Code[10])
        {

        }
        field(16; "Source of Cash"; Enum "Source of Cash")
        {

        }
        field(17; "Vendor Invoice No."; Code[35])
        {

        }
        field(18; Vendor; Text[100])
        {

        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}