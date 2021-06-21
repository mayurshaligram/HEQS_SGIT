page 50116 "Trip Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Trip;

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
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    var
                        Schedule: Record Schedule;
                    begin
                        if Confirm('The trip status has changed, do you aslo change all the schedule item status?') then begin
                            Schedule.SetRange("Trip No.", Rec."No.");

                            if Schedule.FindSet() then
                                repeat
                                    case Rec.Status of
                                        Rec.Status::Completed:
                                            Schedule.Status := Schedule.Status::Completed;
                                        Rec.Status::Open:
                                            Schedule.Status := Schedule.Status::Norm;
                                        Rec.Status::Released:
                                            Schedule.Status := Schedule.Status::Released;
                                    end;
                                    Schedule.Modify();
                                until Schedule.Next() = 0;
                        end;

                    end;
                }
                field(Driver; Rec.Driver)
                {
                    Caption = 'Driver';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Driver: Record Driver;
                        Schedule: Record Schedule;
                    begin
                        Driver.Reset();
                        if Page.RunModal(Page::"Driver Lookup", Driver) = Action::LookupOK then
                            Rec.Driver := Driver."First Name" + ' ' + Driver."Last Name";
                        Rec.Modify();
                        Schedule.SetRange("Trip No.", Rec."No.");
                        if Schedule.FindSet() then
                            repeat
                                Schedule.Driver := Rec.Driver;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                    end;
                }
                field(Vehicle; Rec.Vehicle)
                {
                    Caption = 'Vehicle';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Vehicle: Record Vehicle;
                        Schedule: Record Schedule;
                    begin
                        Vehicle.Reset();
                        if Page.RunModal(Page::"Vehicle Lookup", Vehicle) = Action::LookupOK then
                            Rec.Vehicle := Vehicle."No.";
                        Rec.Modify();
                        Schedule.SetRange("Trip No.", Rec."No.");
                        if Schedule.FindSet() then
                            repeat
                                Schedule.Vehicle := Rec.Vehicle;
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                    end;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate();
                    var
                        Schedule: Record Schedule;
                    begin
                        Schedule.Reset();
                        Schedule.SetRange("Trip No.", Rec."No.");
                        if Schedule.FindSet() then
                            repeat
                                Schedule."Delivery Date" := Rec."Delivery Date";
                                Schedule.Modify();
                            until Schedule.Next() = 0;
                    end;
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
                field("Total Schedule"; Rec."Total Schedule")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(ScheduleSubform; "Schedule Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Trip No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action("Create &Warehouse Shipment")
            {
                AccessByPermission = TableData "Warehouse Shipment Header" = R;
                ApplicationArea = Warehouse;
                Caption = 'Create &Warehouse Shipment';
                Image = NewShipment;
                ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

                trigger OnAction()
                var
                    GetSourceDocuments: Report "Get Source Documents";
                    WhseRqst: Record "Warehouse Request";
                    TempWhseRqst: Record "Warehouse Request";
                    SourceDocSelection: Page "Source Documents";


                    GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    WhseShipmentHeader: Record "Warehouse Shipment Header";
                    Schedule: Record Schedule;
                    TempSchdule: Record Schedule;

                    WhseShipmentLine: Record "Warehouse Shipment Line";
                    SalesHeader: Record "Sales Header";


                begin
                    Schedule.SetRange("Trip No.", Rec."No.");
                    if Schedule.FindSet() = false then
                        Error('There has no schedule item under this Trip.');
                    WhseShipmentHeader.Init();
                    WhseShipmentHeader.Validate("Location Code", Schedule."From Location Code");
                    WhseShipmentHeader.Insert(true);
                    Commit();
                    Clear(GetSourceDocuments);
                    WhseRqst.FilterGroup(2);
                    WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
                    WhseRqst.SetRange("Location Code", WhseShipmentHeader."Location Code");
                    WhseRqst.FilterGroup(0);
                    WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
                    WhseRqst.SetRange("Completely Handled", false);

                    // SourceDocSelection.LookupMode(true);
                    // SourceDocSelection.SetTableView(WhseRqst);
                    // if SourceDocSelection.RunModal <> ACTION::LookupOK then
                    //     exit;

                    TempSchdule.SetRange("Trip No.", Rec."No.");
                    if TempSchdule.FindSet() then begin
                        repeat
                            WhseRqst.SetRange("Source No.", TempSchdule."Source No.");
                            if WhseRqst.FindSet() then begin
                                if NoWarehouseShipmentLine(TempSchdule) then begin
                                    WhseRqst.Mark();
                                    WhseRqst.MarkedOnly();
                                    GetSourceDocuments.SetOneCreatedShptHeader(WhseShipmentHeader);
                                    GetSourceDocuments.SetSkipBlocked(true);
                                    GetSourceDocuments.UseRequestPage(false);
                                    WhseRqst.SetRange("Location Code", WhseShipmentHeader."Location Code");
                                    GetSourceDocuments.SetTableView(WhseRqst);
                                    GetSourceDocuments.RunModal;
                                    CLEAR(GetSourceDocuments);
                                    WhseRqst.Reset();
                                end;
                            end
                        until TempSchdule.Next() = 0;
                    end;

                    // SourceDocSelection.GetResult(WhseRqst);



                    // if WhseRqst.FindSet() then begin
                    //     repeat
                    //         Schedule.Reset();
                    //         Schedule.SetRange("Trip No.", Rec."No.");
                    //         if Schedule.FindSet() then
                    //             repeat
                    //                 if WhseRqst."Source No." = Schedule."Source No." then begin
                    //                     SourceDocSelection.GetResult(WhseRqst);
                    //                     GetSourceDocuments.SetOneCreatedShptHeader(WhseShipmentHeader);
                    //                     GetSourceDocuments.SetSkipBlocked(true);
                    //                     GetSourceDocuments.UseRequestPage(false);
                    //                     WhseRqst.SetRange("Location Code", WhseShipmentHeader."Location Code");
                    //                     GetSourceDocuments.SetTableView(WhseRqst);
                    //                     GetSourceDocuments.RunModal;
                    //                 end;
                    //             until Schedule.Next() = 0;
                    //     until WhseRqst.Next() = 0;
                    // end;
                    if (WhseShipmentHeader.CurrentCompany = SalesTruthMgt.InventoryCompany()) then begin

                        WhseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
                        if WhseShipmentLine.FindSet() then begin
                            repeat
                                if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                                    SalesHeader.Get(SalesHeader."Document Type"::Order, WhseShipmentLine."Source No.");
                                    WhseShipmentLine."Original SO" := SalesHeader.RetailSalesHeader;
                                    WhseShipmentLine.Modify();
                                end;
                            until WhseShipmentLine.Next() = 0;
                        end;

                    end;
                    WhseShipmentLine.Reset();
                    WhseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
                    if WhseShipmentLine.FindSet() then begin
                        ReleaseScheduleItem(Rec);
                        Page.Run(Page::"Warehouse Shipment", WhseShipmentHeader);
                        CurrPage.Update();
                    end
                    else begin
                        Message('No WarehouseShipment has created.');
                        WhseShipmentHeader.Delete(true);
                    end;

                end;

            }
            action("Complete Trip")
            {
                AccessByPermission = TableData "Warehouse Shipment Header" = R;
                ApplicationArea = Warehouse;
                Caption = 'Complete Trip';
                Image = NewShipment;
                ToolTip = 'Complete all schedule item under the trip';

                trigger OnAction();
                var
                    Schedule: Record Schedule;
                begin
                    Schedule.Reset();
                    Schedule.SetRange("Trip No.", Rec."No.");
                    if Schedule.FindSet() then
                        repeat
                            Schedule.Status := Schedule.Status::Completed;
                            Schedule.Modify();
                        until Schedule.Next() = 0;
                    Rec.Status := Rec.Status::Completed;
                    CurrPage.Update();
                end;

            }
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    local procedure NoWarehouseShipmentLine(TempSchedule: Record Schedule): Boolean
    var
        WarehouseShipment: Record "Warehouse Shipment Line";
    begin
        WarehouseShipment.Reset();
        if WarehouseShipment.FindSet() then
            repeat
                if WarehouseShipment."Source No." = TempSchedule."Source No." then
                    exit(false);
            until WarehouseShipment.Next() = 0;
        exit(true);
    end;

    local procedure ReleaseScheduleItem(Trip: Record Trip);
    var
        Schedule: Record Schedule;
    begin
        Schedule.SetRange("Trip No.", Trip."No.");
        if Schedule.FindSet() then
            repeat
                Schedule.Status := Schedule.Status::Released;
                Schedule.Modify();
            until Schedule.Next() = 0;
        Trip.Status := Trip.Status::Released;
        Trip.Modify();
    end;

}