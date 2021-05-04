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
        field(5; "Source of Cash"; Enum "Source of Cash")
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
                User.Get(Database.UserSecurityId());
                Rec."Director Approval" := User."Full Name";
            end;
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