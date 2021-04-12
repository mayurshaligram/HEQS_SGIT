table 50105 Vehicle
{
    Caption = 'Vehicle';
    DataCaptionFields = "No.";
    LookupPageId = "Vehicle Lookup";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
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