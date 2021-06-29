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
                                        if IsMainItemLine(SalesLine) then
                                            if StrLen(TempDeliveryItem) < 1900 then
                                                TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
                                    until SalesLine.Next() = 0;

                                Rec."Delivery Items" := TempDeliveryItem;
                                Rec.Assemble := TempAssemble;
                                Rec.Customer := SalesHeader."Ship-to Contact";
                                Rec."Phone No." := SalesHeader."Ship-to Phone No.";
                                Rec.Remote := false;
                                Rec.Status := Rec.Status::Norm;
                                Rec."From Location Code" := SalesHeader."Location Code";
                                Rec."Subsidiary Source No." := SalesHeader."RetailSalesHeader";
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
                                        if IsMainItemLine(SalesLine) then
                                            if StrLen(TempDeliveryItem) < 1900 then
                                                TempDeliveryItem := TempDeliveryItem + Format(SalesLine.Quantity) + '*' + SalesLine.Description + ', ';
                                    until SalesLine.Next() = 0;
                                Rec."Delivery Items" := TempDeliveryItem;
                                Rec.Assemble := TempAssemble;
                                Rec.Customer := SalesHeader."Ship-to Contact";
                                Rec."Phone No." := SalesHeader."Ship-to Phone No.";
                                Rec.Remote := false;
                                Rec.Status := Rec.Status::Norm;
                                Rec."From Location Code" := SalesHeader."Location Code";
                                Rec."Subsidiary Source No." := SalesHeader."RetailSalesHeader";
                            end;
                        end;
                        if Rec."Source Type" = Rec."Source Type"::"Transfer Order" then begin
                            Transfer.Reset();
                            if Page.RunModal(Page::"Transfer Orders", Transfer) = Action::LookupOK then begin
                                Rec."Source No." := Transfer."No.";
                                Rec."Delivery Date" := Transfer."Shipment Date";
                                Rec.Assemble := false;
                                TransferLine.SetRange("Document No.", Transfer."No.");
                                if TransferLine.FindSet() then
                                    repeat
                                        if IsMainItemLineTrans(TransferLine) then
                                            if StrLen(TempDeliveryItem) < 1900 then
                                                TempDeliveryItem := TempDeliveryItem + Format((TransferLine.Quantity)) + '*' + TransferLine.Description + ', ';
                                    until TransferLine.Next() = 0;
                                Rec.Status := Rec.Status::Norm;
                                Rec."From Location Code" := Transfer."Transfer-from Code";
                                Rec."Delivery Items" := TempDeliveryItem;
                                Rec."To Location Code" := Transfer."Transfer-to Code";
                                Rec."Subsidiary Source No." := Transfer."No.";
                            end;
                        end;
                    end;
                }
                field("Subsidiary Source No."; Rec."Subsidiary Source No.")
                {
                    Caption = 'Original SO';
                    ApplicationArea = All;
                    Visible = true;
                }
                field(Suburb; Rec."Ship-to City")
                {
                    Caption = 'Suburb';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Postcode: Record "Post Code";
                    begin
                        Postcode.Reset();
                        if Page.RunModal(Page::"Post Codes", Postcode) = Action::LookupOK then
                            Rec."Ship-to City" := Postcode.City;
                        Rec.Modify();
                    end;

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
                    MultiLine = true;
                    ApplicationArea = All;
                }
                field("Delivery Items"; Rec."Delivery Items")
                {
                    Caption = 'Delivery Items';
                    ApplicationArea = All;
                    MultiLine = true;
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

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Driver: Record Driver;
                    begin
                        Driver.Reset();
                        if Page.RunModal(Page::"Driver Lookup", Driver) = Action::LookupOK then
                            Rec.Driver := Driver."First Name" + ' ' + Driver."Last Name";
                        Rec.Modify();
                    end;
                }
                field(Vehicle; Rec.Vehicle)
                {
                    Caption = 'Vehicle';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Vehicle: Record Vehicle;
                    begin
                        Vehicle.Reset();
                        if Page.RunModal(Page::"Vehicle Lookup", Vehicle) = Action::LookupOK then
                            Rec.Vehicle := Vehicle."No.";
                        Rec.Modify();
                    end;
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

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Trip: Record Trip;
                        xSchedule: Record Schedule;
                    begin
                        xSchedule.Reset();
                        xSchedule.SetCurrentKey("Trip No.", "Trip Sequece");
                        xSchedule.SetRange("Trip No.", Rec."Trip No.");
                        xSchedule.SetFilter("Trip Sequece", '>%1', Rec."Trip Sequece");
                        Trip.Reset();
                        if Page.RunModal(Page::"Trip List", Trip) = Action::LookupOK then begin
                            Rec."Trip No." := Trip."No.";
                            Trip.Get(Rec."Trip No.");
                            Trip.CalcFields("Total Schedule");
                            Rec."Trip Sequece" := Trip."Total Schedule";
                            Rec."Global Sequence" := format(Rec."Trip No.") + format(Rec."Trip Sequece");
                        end;
                        if xSchedule.FindSet() then
                            repeat
                                xSchedule."Trip Sequece" -= 1;
                                xSchedule."Global Sequence" := format(xSchedule."Trip No.") + Format(xSchedule."Trip Sequece");
                                xSchedule.Modify();
                            until xSchedule.Next() = 0;

                        Rec.Modify();
                    end;
                }
                field("Trip Sequece"; Rec."Trip Sequece")
                {
                    Caption = 'Trip Sequence';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Remote; Rec.Remote)
                {
                    Caption = 'Remote';
                    ApplicationArea = All;
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    Caption = 'From Location Code';
                    ApplicationArea = All;
                }
                field("To Location Code"; Rec."To Location Code")
                {
                    Caption = 'To Location Code';
                    ApplicationArea = All;
                }
                field("Delivery Option"; Rec."Delivery Option")
                {
                    Caption = 'Delivery Option';
                    ApplicationArea = All;
                }
                field("Shipping Agent"; Rec."Shipping Agent")
                {
                    Caption = 'Shipping Agent';
                    ApplicationArea = All;
                }
                field("QC Requirement"; Rec."QC Requirement")
                {
                    Caption = 'QC Requirement';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(Testing)
            {
                ApplicationArea = All;
                Caption = 'Testing';

                trigger OnAction();
                begin
                    Testfunction();
                end;
            }
        }
    }

    local procedure IsMainItemLine(SalesLine: Record "Sales Line"): Boolean;
    var
        TempItem: Record Item;
    begin
        TempItem.Reset();
        if TempItem.Get(SalesLine."No.") = false then
            exit(false);
        TempItem.CalcFields("Assembly BOM");
        if TempItem."Assembly BOM" then
            exit(true);
    end;

    local procedure IsMainItemLineTrans(Transfer: Record "Transfer Line"): Boolean;
    var
        TempItem: Record Item;
    begin
        TempItem.Reset();
        if TempItem.Get(Transfer."Item No.") = false then
            exit(false);
        TempItem.CalcFields("Assembly BOM");
        if TempItem."Assembly BOM" then
            exit(true);
    end;

    procedure Testfunction();
    var
        ScheduleMgt: Codeunit "Schedule Mgt";
        SalesHeader: Record "Sales Header";
        TempText: Text;
    begin
        // SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source No.");
        // ScheduleMgt.LoadWarrantyLine(SalesHeader, Rec, TempText);
        // Rec.Modify();
    end;
}