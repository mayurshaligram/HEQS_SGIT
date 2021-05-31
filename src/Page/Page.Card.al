page 50114 "Schedule Card"
{
    Caption = 'Schedule Card';
    PageType = Card;
    SourceTable = "Schedule";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;
                }
                field(Suburb; Rec."Ship-to City")
                {
                    Caption = 'Suburb';
                    ApplicationArea = All;
                }
                field(Zone; Rec.Zone)
                {
                    Caption = 'Zone';
                    ApplicationArea = All;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    Caption = 'Zone';
                    ApplicationArea = All;
                }
                field("Delivery Time"; Rec."Delivery Time")
                {
                    Caption = 'Delivery Time/Note';
                    ApplicationArea = All;
                }
                field("Delivery Items"; Rec."Delivery Items")
                {
                    Caption = 'Delivery Items';
                    ApplicationArea = All;
                }
                field(Assemble; Rec.Assemble)
                {
                    Caption = 'Assemble';
                    ApplicationArea = All;
                }
                field(Extra; Rec.Extra)
                {
                    Caption = 'Extra';
                    ApplicationArea = All;
                }
                field(Customer; Rec.Customer)
                {
                    Caption = 'Customer';
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                    ApplicationArea = All;
                }
                field("Driver"; Rec.Driver)
                {
                    Caption = 'Driver';
                    ApplicationArea = All;
                }
                field(Vehicle; Rec.Vehicle)
                {
                    Caption = 'Vehicle';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                }
                field(Remote; Rec.Remote)
                {
                    Caption = 'Remote';
                    ApplicationArea = All;
                }
            }
        }
    }
}