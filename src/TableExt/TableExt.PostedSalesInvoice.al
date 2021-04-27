tableextension 50120 PostedSalesInvoiceExt extends "Sales Invoice Header"
{
    fields
    {
        field(50144; TempDate; Date)
        {
            Caption = 'Promised Delivery Date';
            Description = 'Works Temp Delivery Date';
            Editable = false;
        }
        field(50143; "Vehicle NO"; Text[20])
        {
            Caption = 'Promised Delivery Date';
            Description = 'Works Temp Delivery Date';
        }
        field(50142; "Driver"; Text[20])
        {
            Caption = 'Directed Driver';
            Description = 'Driver';
        }

        field(50100; Money; Boolean)
        {
            Caption = 'Receive Money';
            Description = 'This field is to indicate the whether delivery person needs to receive money from client on site';
            Editable = false;
        }
        field(50101; "Automate Purch.Doc No."; Text[20])
        {
            Caption = 'Automate Purch.Doc No.';
            Description = 'This field is to show the No. of automated purchase order';
            Editable = false;
        }
        field(50148; "Delivery"; Enum "Delivery Option")
        {
            Caption = 'Delivery Option';
            Description = 'Specife the Delivery Option';
        }
        field(50147; "Delivery Item"; Text[2000])
        {
            Caption = 'Delivery Item';
            Description = 'Display all the item in this sales Header';
            Editable = false;
        }
        field(50146; RetailSalesHeader; Code[20])
        {
            Caption = 'Retail Sales Header';
            Description = 'Indicate the No. of IC Retail Sales Header';
            Editable = false;
        }
        field(50145; IsScheduled; Boolean)
        {
            Caption = 'IsScheduled';
            Description = 'Indicate the sales order has been is scheduled';
            Editable = true;
        }
        field(50141; "Delivery Hour"; Text[20])
        {
            Caption = 'Delivery Hour';
            Description = 'Indicate the Delivery Hour for the Sales Order';
            Editable = true;
        }
        field(50140; Cubage; Decimal)
        {
            Caption = 'Total Cubage';
            Description = 'Indicate the total Cubage for the Sales Header';
            Editable = false;
        }
        field(50139; NeedAssemble; Boolean)
        {
            Caption = 'Need Assemble';
            Description = 'Indicate whether contain the sales line need to be assemled';
            Editable = false;
        }
        field(50138; Note; Text[200])
        {
            Caption = 'Other Note';
            Description = 'Indicate the text version for the work description';
            Editable = false;
        }
        field(50137; NeedCollectPayment; Boolean)
        {
            Caption = 'NeedCollectPayment';
            Description = 'Indicate whether need to collect payment';
            Editable = true;
        }
        field(50136; "Estimate Assembly Time(hour)"; Decimal)
        {
            Caption = 'Estimate Assembly Time';
            Description = 'Indicate total assembly time in this sales header';
            Editable = false;
        }
        field(50135; Stair; Integer)
        {
            Caption = 'Stairs';
            Description = 'Indicate the stairs of the sales order';
            Editable = true;
        }
        field(50134; IsDeliveried; Boolean)
        {
            Caption = 'IsDeliveried';
            Description = 'Indicate the Sales Order is deliveried or not';
            Editable = true;
        }
        field(50133; "Ship-to Phone No."; Text[20])
        {
            Caption = 'Ship-to Phone No.';
            Description = 'Indicate the Ship-To Phone No.';
            Editable = true;
        }
        field(50132; ZoneCode; Text[30])
        {
            Caption = 'ZoneCode';
            Description = 'Price Level Zone Code';
            Editable = false;
        }
        field(50131; "Assembly Item"; Text[2000])

        {
            Caption = 'Assembly Item';
            Description = 'Assembly Item';
            Editable = false;
        }
        field(50130; "Delivery without BOM Item"; Text[2000])
        {
            Caption = 'Delivery without BOM Item';
            Description = 'Display all the item without BOM in this sales Header';
            Editable = false;
        }
        field(50129; "Assembly Item without BOM Item"; Text[2000])
        {
            Caption = 'Assembly Item without BOM';
            Description = 'Assembly Item without BOM';
            Editable = false;
        }
        field(50128; TripSequence; Integer)
        {
            Caption = 'TripSequence';
            Description = 'TripSequence';
            Editable = true;
        }
    }

    var
        myInt: Integer;
}