table 50103 Driver
{
    Caption = 'Driver';
    DataCaptionFields = "No.", "First Name", "Middle Name", "Last Name";
    LookupPageId = "Driver Lookup";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(3; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
        }
        field(4; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }

    }

}