table 50100 "Schedule"
{
    Caption = 'Schedule';
    DataCaptionFields = "Source Type", "Subsidiary Source No.";
    LookupPageId = 50113;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Source Type"; Enum "Schedule Source Type")
        {
            Caption = 'Source Type';
        }
        field(2; "No."; Code[20])
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
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(4; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(6; Zone; Code[20])
        {
            Caption = 'Zone';
        }
        field(7; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
        }
        field(8; "Delivery Time"; Text[2000])
        {
            Caption = 'Delivery Time/Note';
        }
        field(9; "Delivery Items"; Text[2000])
        {
            Caption = 'Delivery Items';
        }
        field(10; "Assemble"; Boolean)
        {
            Caption = 'Assemble';
        }
        field(11; Extra; Text[200])
        {
            Caption = 'Extra';
        }
        field(12; Customer; Text[200])
        {
            Caption = 'Customer';
        }
        field(13; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
        }
        field(14; Driver; Text[30])
        {
            Caption = 'Driver';
        }
        field(15; Vehicle; Text[30])
        {
            Caption = 'Vehicle';
        }
        field(16; "Trip No."; Code[20])
        {
            Caption = 'Trip No';
        }
        field(17; "Trip Sequece"; Integer)
        {
            Caption = 'Trip Sequence';
        }
        field(18; Status; Enum "Schedule Status")
        {
            Caption = 'Status';
        }
        field(19; Remote; Boolean)
        {
            Caption = 'Remote';
        }
        field(20; "From Location Code"; Code[20])
        {
            Caption = 'From Location Code';
            Description = 'This Attribute only design for the Transfer Order';
        }
        field(21; "To Location Code"; Code[21])
        {
            Caption = 'To Location Code';
            Description = 'This Attribute only design for the Transfer Order';
        }
        field(22; "Subsidiary Source No."; Code[22])
        {
            Caption = 'Order No.';
            Description = 'Order No. for the schedule item in subsidiary.';
        }
        field(23; "Global Sequence"; Code[20])
        {
            Caption = 'Global Sequence';
            Description = 'Help to move the record';
        }
        field(24; "Subsidiary Name"; Text[30])
        {
            Caption = 'Subsidiary Name';
            Description = 'Subsidiary Name';
        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(S1; "Trip Sequece")
        {
        }
        key(S2; "Trip No.", "Trip Sequece")
        {
        }
        key(S3; "Global Sequence")
        {
        }
    }


    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    var
    begin
        if "No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Schedule Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."Schedule Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        "Global Sequence" := format("Trip No.") + format("Trip Sequece");
    end;

    trigger OnModify()
    var
        Schedule: Record Schedule;
        xSchedule: Record Schedule;
        TempInt: Integer;
    begin
        "Global Sequence" := format("Trip No.") + format("Trip Sequece");
        TempInt := 0;
        // Commit();
        // Reorder Previous Trip 
        if (xRec."Trip No." <> '') and ("Trip No." = '') then begin
            xSchedule.SetRange("Trip No.", xRec."Trip No.");
            if xSchedule.FindSet() then
                repeat
                    if xSchedule."No." <> Rec."No." then begin
                        xSchedule."Trip Sequece" := TempInt;
                        TempInt += 1;
                        xSchedule."Global Sequence" := Format(xSchedule."Trip No.") + Format(xSchedule."Trip Sequece");
                        xSchedule.Modify();
                    end;
                until xSchedule.Next() = 0;
        end;

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}