table 50104 ZoneTable
{


    Caption = 'Zone';
    DataCaptionFields = "Order Price", "Code", "Delivery Fee", "L1";

    LookupPageID = "Zone Lookup";

    fields
    {
        field(1; "Order Price"; Integer)
        {
            Caption = 'Order Price';
        }

        field(2; "Code"; Text[30])
        {
            Caption = 'Code';
        }

        field(3; "Delivery Fee"; Decimal)
        {
            Caption = 'Delivery Fee';
        }
        field(4; "L1"; Decimal)
        {
            Caption = 'L1';
        }
        field(5; "L2"; Decimal)
        {
            Caption = 'L2';
        }
        field(6; "L3"; Decimal)
        {
            Caption = 'L3';
        }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }

    }

}