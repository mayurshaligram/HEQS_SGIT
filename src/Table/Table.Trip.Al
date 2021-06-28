table 50107 Trip
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    SalesSetup.Get();
                    NoSeriesMgt.TestManual(SalesSetup."Schedule Nos.");
                    "No. Series" := '';
                end;
            end;
        }

        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(3; Status; Enum "Trip Status")
        {
            Caption = 'Trip Status';
        }
        field(4; Note; Text[200])
        {
            Caption = 'Note';
        }
        field(5; Driver; Text[30])
        {
            Caption = 'Driver';
        }
        field(6; Vehicle; Text[30])
        {
            Caption = 'Vehicle';
        }
        field(7; "Total Schedule"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Schedule where("Trip No." = field("No.")));
        }

        field(8; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
        }
        field(9; "Total Completed"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Schedule where("Trip No." = field("No."), Status = const(Completed)));
        }
        field(10; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text014: Label 'Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.';

    procedure DisplayMap()
    var
        url: Label 'https://www.google.com/maps/dir/';
    begin
        HyperLink(url);
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Trip");
            NoSeriesMgt.InitSeries(SalesSetup."Trip", xRec."No. Series", 0D, "No.", "No. Series");
        end;
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