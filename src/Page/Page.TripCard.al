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
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
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
                        if WhseShipmentLine.FindSet() then
                            repeat
                                if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                                    SalesHeader.Get(SalesHeader."Document Type"::Order, WhseShipmentLine."Source No.");
                                    WhseShipmentLine."Original SO" := SalesHeader.RetailSalesHeader;
                                    WhseShipmentLine.Modify();
                                end;
                            until WhseShipmentLine.Next() = 0;
                    end;
                    Page.Run(Page::"Warehouse Shipment", WhseShipmentHeader);
                end;

            }
        }
    }
    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

}