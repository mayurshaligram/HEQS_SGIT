page 50114 "Schedule Card"
{
    Caption = 'Schedule Card';
    PageType = Card;
    SourceTable = "Schedule";
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Source No."; Rec."Source No.")
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SalesHeader: Record "Sales Header";
                        Transfer: Record "Transfer Header";


                        Zone: Record ZoneTable;
                        TempInt: Integer;

                        TempDeliveryItem: Text[2000];
                        TempDeliveryItemWithoutBOM: Text[2000];

                        SalesLine: Record "Sales Line";

                        TempAssemble: Boolean;
                        TempAssemblyItem: Text[2000];
                        TransferLine: Record "Transfer Line";
                    begin
                        if Rec."Source Type" = Rec."Source Type"::"Sales Order" then begin
                            SalesHeader.Reset();
                            if Page.RunModal(Page::"Sales Order List", SalesHeader) = Action::LookupOK then begin
                                Rec."Source No." := SalesHeader."No.";
                                Rec."Ship-to City" := SalesHeader."Ship-to City";
                                SalesHeader.CalcFields("Amount Including VAT");
                                TempInt := Round(SalesHeader."Amount Including VAT", 1, '=');
                                Zone.SetRange("Order Price", TempInt, 999999);
                                if Zone.FindSet() then
                                    Rec.Zone := Zone.Code;
                                Rec."Delivery Date" := SalesHeader."Promised Delivery Date";
                                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                SalesLine.SetRange("Document No.", SalesHeader."No.");
                                if SalesLine.FindSet() then
                                    repeat
                                        if SalesLine.NeedAssemble then
                                            TempAssemble := true;
                                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
                                    until SalesLine.Next() = 0;
                                Rec."Delivery Items" := TempDeliveryItem;
                                Rec.Assemble := TempAssemble;
                                Rec.Customer := SalesHeader."Ship-to Contact";
                                Rec."Phone No." := SalesHeader."Ship-to Phone No.";
                                Rec.Remote := false;
                                Rec.Status := Rec.Status::Norm;
                            end
                        end;
                        if Rec."Source Type" = Rec."Source Type"::"Sales Return Order" then begin
                            SalesHeader.Reset();
                            if Page.RunModal(Page::"Sales Return Order List", SalesHeader) = Action::LookupOK then begin
                                Rec."Source No." := SalesHeader."No.";
                                Rec."Ship-to City" := SalesHeader."Ship-to City";
                                Rec."Delivery Date" := SalesHeader."Promised Delivery Date";
                                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                SalesLine.SetRange("Document No.", SalesHeader."No.");
                                if SalesLine.FindSet() then
                                    repeat
                                        if SalesLine.NeedAssemble then
                                            TempAssemble := true;
                                        TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
                                    until SalesLine.Next() = 0;
                                Rec."Delivery Items" := TempDeliveryItem;
                                Rec.Assemble := TempAssemble;
                                Rec.Customer := SalesHeader."Ship-to Contact";
                                Rec."Phone No." := SalesHeader."Ship-to Phone No.";
                                Rec.Remote := false;
                                Rec.Status := Rec.Status::Norm;
                            end;
                        end;
                        if Rec."Source Type" = Rec."Source Type"::"Transfer Order" then begin
                            Transfer.Reset();
                            if Page.RunModal(Page::"Transfer Orders", Transfer) = Action::LookupOK then begin
                                Rec."Source No." := Transfer."No.";
                                Rec."Delivery Date" := Transfer."Shipment Date";
                                Rec.Assemble := false;
                                TransferLine.SetRange("Document No.", Transfer."No.");
                                if Transfer.FindSet() then
                                    repeat
                                        TempDeliveryItem := TempDeliveryItem + Format((TransferLine.Quantity)) + '*' + SalesLine.Description + ', ';
                                    until SalesLine.Next() = 0;
                                Rec.Status := Rec.Status::Norm;
                            end;
                        end;
                    end;
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
                    Caption = 'Delivery Date';
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
                field("Trip No."; Rec."Trip No.")
                {
                    Caption = 'Trip';
                    ApplicationArea = All;
                }
                field("Trip Sequece"; Rec."Trip Sequece")
                {
                    Caption = 'Trip Sequence';
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