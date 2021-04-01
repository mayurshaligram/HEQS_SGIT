page 50146 Schedule
{
    ApplicationArea = Basic, Suite, Assembly;
    Caption = 'Schedule';
    DataCaptionFields = "Sell-to Customer No.";
    Insertallowed = false;
    DeleteAllowed = false;
    PageType = List;
    QueryCategory = 'Sales Order List';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = CONST(Order));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec.RetailSalesHeader)
                {
                    Caption = 'Order Number';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Suburb; Rec."Ship-to City")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suburb';
                    ToolTip = 'Specifies the city code of the address that the items are shipped to.';
                }
                field(Zone; Rec.ZoneCode)
                {
                    Caption = 'Zone';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the price level Zone Code';
                }
                field("Promised delivery date"; Rec.TempDate)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that you have promised to deliver the order, as a result of the Order Promising function.';
                    Editable = true;
                    Visible = Not IsSimplePage;

                    trigger OnValidate();
                    var
                        RetailSalesHeader: Record "Sales Header";
                    begin
                        RetailSalesHeader.ChangeCompany(Rec."Sell-to Customer Name");
                        if Rec."External Document No." <> '' then begin
                            RetailSalesHeader.SetRange("Document Type", Rec."Document Type");
                            RetailSalesHeader.SetRange("Automate Purch.Doc No.", Rec."External Document No.");
                            if RetailSalesHeader.FindSet() then begin
                                RetailSalesHeader."Promised Delivery Date" := Rec.TempDate;
                                RetailSalesHeader.Modify();
                            end;
                        end;
                        Rec."Promised Delivery Date" := Rec.TempDate;
                        Rec.Modify();
                    end;
                }
                field("Delivery Hour"; Rec."Delivery Hour")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that you have promised to deliver the order, as a result of the Order Promising function.';
                    Editable = true;
                    Visible = Not IsSimplePage;
                    trigger OnValidate();
                    var
                        RetailSalesHeader: Record "Sales Header";
                    begin
                        RetailSalesHeader.ChangeCompany(Rec."Sell-to Customer Name");
                        RetailSalesHeader.Get(Rec."Document Type", Rec.RetailSalesHeader);
                        RetailSalesHeader."Delivery Hour" := Rec."Delivery Hour";
                        RetailSalesHeader.Modify();
                    end;
                }
                field("Delivery Item"; Rec."Delivery Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specified a Delivery Item and Quantity.';
                    MultiLine = true;
                    Editable = false;
                    Visible = Not IsSimplePage;
                }

                field("Delivery without BOM Item"; Rec."Delivery without BOM Item")
                {
                    Caption = 'Delivery Item';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specified a Delivery Item and Quantity.';
                    MultiLine = true;
                    Editable = false;
                    Visible = IsSimplePage;
                }

                field("Assembly Item"; Rec."Assembly Item")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Assemble';
                    ToolTip = 'Specified a Delivery Item and Quantity.';
                    MultiLine = true;
                    Editable = false;
                    Style = StrongAccent;
                    Visible = Not IsSimplePage;
                }
                field("Assembly Item without BOM Item"; Rec."Assembly Item without BOM Item")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Assemble';
                    ToolTip = 'Specified a Delivery Item and Quantity.';
                    MultiLine = true;
                    Editable = false;
                    Style = StrongAccent;
                    Visible = IsSimplePage;
                }


                field(Stair; Rec.Stair)
                {
                    Caption = 'Extra';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Delivery Stair';
                    Editable = true;
                    Visible = NOT IsSimplePage;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
                    Visible = Not IsSimplePage;
                }
                field("Phone No."; Rec."Ship-to Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact phone No for shipping';
                    Caption = 'Phone number';
                    Visible = Not IsSimplePage;
                }

                field("Vehicle NO"; Rec."Vehicle NO")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Delivery Vehicle No.';
                    Visible = NOT IsSimplePage;
                    Caption = 'Delivery Vehicle';
                }
                field(IsScheduled; Rec.IsScheduled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specife the order has been scheduled';
                    Editable = true;

                    trigger OnValidate();
                    var
                        RetailSalesHeader: Record "Sales Header";
                    begin
                        if Rec.RetailSalesHeader <> '' then begin
                            RetailSalesHeader.ChangeCompany(Rec."Sell-to Customer Name");
                            RetailSalesHeader.Get(Rec."Document Type", Rec.RetailSalesHeader);
                            RetailSalesHeader.IsScheduled := Rec.IsScheduled;
                            RetailSalesHeader.Modify();
                        end;
                    end;
                }



                field(Delivery; Rec.Delivery)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Delivery Option.';
                }
                //////////////////////////////////////


                field(InventorySalesOrder; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Associated Invenotry Sales Order.';
                    Visible = Not IsSimplePage;
                }
                field(IsDeliveried; Rec.IsDeliveried)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sales order has been deliveried or not';
                    Visible = Not IsSimplePage;
                    Editable = true;

                    trigger OnValidate();
                    var
                        RetailSalesHeader: Record "Sales Header";
                    begin
                        if Rec.RetailSalesHeader <> '' then begin
                            RetailSalesHeader.ChangeCompany(Rec."Sell-to Customer Name");
                            RetailSalesHeader.Get(Rec."Document Type", Rec.RetailSalesHeader);
                            RetailSalesHeader.IsDeliveried := Rec.IsDeliveried;
                            RetailSalesHeader.Modify();
                        end;
                    end;
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that the customer has asked for the order to be delivered.';
                }



                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total cubage fo the sales order';
                    Visible = Not IsSimplePage;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer.';
                    Visible = Not IsSimplePage;
                }

                field("Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer.';
                    Visible = Not IsSimplePage;
                }

                field(Driver; Rec.Driver)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Delivery Vehicle No.';
                    Visible = NOT IsSimplePage;

                    trigger OnLookup(var Text: Text): Boolean;
                    var
                        Driver: Record Driver;
                    begin
                        Driver.Reset();
                        if Page.RunModal(Page::"Driver Lookup", Driver) = Action::LookupOK then
                            Rec.Driver := Driver."First Name" + ' ' + Driver."Last Name";
                    end;
                }

                field("Sell-to Post Code"; "Sell-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s main address.';
                    Visible = Not IsSimplePage;
                }

                field(NeedCollectPayment; Rec.NeedCollectPayment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether in the delivery payment needed to be collected';
                    Visible = Not IsSimplePage;
                }
                field("Other Note"; Rec.Note)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the note for the sales header';
                    Visible = Not IsSimplePage;
                }

                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                    Visible = Not IsSimplePage;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer at the address that the items are shipped to.';
                    Visible = Not IsSimplePage;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the address that the items are shipped to.';
                    Visible = Not IsSimplePage;
                }

                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
                    Visible = Not IsSimplePage;
                }

                /////////////////////////////////////////////
                field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s main address.';
                    Visible = false;
                }

                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location from where inventory items to the customer on the sales document are to be shipped by default.';
                    Visible = Not IsSimplePage;
                }
                field("Quote No."; "Quote No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the sales quote that the sales order was created from. You can track the number to sales quote documents that you have printed, saved, or emailed.';
                    Visible = false;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
                    Visible = false;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency of amounts on the sales document.';
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = Not IsSimplePage;
                }

                field("Campaign No."; "Campaign No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the campaign number the document is linked to.';
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the document is open, waiting to be approved, has been invoiced for prepayment, or has been released to the next stage of processing.';
                    Visible = Not IsSimplePage;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the sales invoice must be paid.';
                    Visible = false;
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment discount percentage that is granted if the customer pays on or before the date entered in the Pmt. Discount Date field. The discount percentage is specified in the Payment Terms Code field.';
                    Visible = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                    Visible = false;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Visible = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                    Visible = false;
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the shipping agent''s package number.';
                    Visible = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                    Visible = Not IsSimplePage;
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the customer accepts partial shipment of orders.';
                    Visible = false;
                }
                field("Completely Shipped"; "Completely Shipped")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether all the items on the order have been shipped or, in the case of inbound items, completely received.';
                    Visible = Not IsSimplePage;
                }
                field("Job Queue Status"; "Job Queue Status")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = "Job Queue Status" = "Job Queue Status"::ERROR;
                    ToolTip = 'Specifies the status of a job queue entry or task that handles the posting of sales orders.';
                    Visible = JobQueueActive;

                    trigger OnDrillDown()
                    var
                        JobQueueEntry: Record "Job Queue Entry";
                    begin
                        if "Job Queue Status" = "Job Queue Status"::" " then
                            exit;
                        JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
                    end;
                }
                field("Amt. Ship. Not Inv. (LCY) Base"; "Amt. Ship. Not Inv. (LCY) Base")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum, in LCY, for items that have been shipped but not yet been invoiced. The amount is calculated as Amount Including VAT x Qty. Shipped Not Invoiced / Quantity.';
                    Visible = false;
                }
                field("Amt. Ship. Not Inv. (LCY)"; "Amt. Ship. Not Inv. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum, in LCY, for items that have been shipped but not yet been invoiced. The amount is calculated as Amount Including VAT x Qty. Shipped Not Invoiced / Quantity.';
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of amounts in the Line Amount field on the sales order lines.';
                    Visible = false;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of the amounts, including VAT, on all the lines on the document.';
                    Visible = false;
                }
                field("Posting Description"; "Posting Description")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies additional posting information for the document. After you post the document, the description can add detail to vendor and customer ledger entries.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {




        area(processing)
        {
            action(ClassicView)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show More Columns';
                Image = SetupColumns;
                ToolTip = 'View all available fields. Fields not frequently used are currently hidden.';
                Visible = IsSimplePage;

                trigger OnAction()
                begin
                    IsSimplePage := false;
                    CurrPage.Update();
                end;
            }
            action(SimpleView)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Fewer Columns';
                Image = SetupList;
                ToolTip = 'Hide fields that are not frequently used.';
                Visible = NOT IsSimplePage;

                trigger OnAction()
                begin
                    IsSimplePage := true;
                    CurrPage.Update();
                end;
            }
        }

    }

    views
    {

        view(NSW)
        {
            Caption = 'NSW';
            SharedLayout = false;
            Filters = where("Location Code" = const('NSW'),
                 "Requested Delivery Date" = filter(''),
                 "Sell-to Customer Name" = const(''),
                 Delivery = const(Delivery),
                 IsScheduled = const(false));
            layout
            {
                moveafter("No."; "Location Code")

                modify("Requested Delivery Date")
                {
                    Visible = true;
                }
            }
        }
        view(VIC)
        {
            Caption = 'VIC';
            SharedLayout = false;
            Filters = where("Location Code" = const('VIC'),
                 "Requested Delivery Date" = filter(''),
                 "Sell-to Customer Name" = const(''),
                 Delivery = const(Delivery),
                                  IsScheduled = const(false)
                 );
            layout
            {
                moveafter("No."; "Location Code")

                modify("Requested Delivery Date")
                {
                    Visible = true;
                }
            }
        }
        view(QLD)
        {
            Caption = 'QLD';
            SharedLayout = false;
            Filters = where("Location Code" = const('QLD'),
                 "Requested Delivery Date" = filter(''),
                 "Sell-to Customer Name" = const(''),
                 Delivery = const(Delivery), IsScheduled = const(false));
            layout
            {
                moveafter("No."; "Location Code")

                modify("Requested Delivery Date")
                {
                    Visible = true;
                }
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        Rec.ChangeCompany(SalesTruthMgt.InventoryCompany());
        SetControlVisibility;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        NextRecNotFound: Boolean;
    begin
        if not Find(Which) then
            exit(false);

        if ShowHeader then
            exit(true);

        repeat
            NextRecNotFound := Next <= 0;
            if ShowHeader then
                exit(true);
        until NextRecNotFound;

        exit(false);
    end;

    trigger OnInit()
    begin
        PowerBIVisible := false;
        // CurrPage."Power BI Report FactBox".PAGE.InitFactBox(CurrPage.ObjectId(false), CurrPage.Caption, PowerBIVisible);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NewStepCount: Integer;
    begin
        repeat
            NewStepCount := Next(Steps);
        until (NewStepCount = 0) or ShowHeader;

        exit(NewStepCount);
    end;


    trigger OnOpenPage()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        OfficeMgt: Codeunit "Office Management";

        SalesLine: Record "Sales Line";
    begin

        if UserMgt.GetSalesFilter <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserMgt.GetSalesFilter);
            FilterGroup(0);
        end;

        SetRange("Date Filter", 0D, WorkDate());

        JobQueueActive := SalesSetup.JobQueueActive;
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        IsOfficeAddin := OfficeMgt.IsAvailable;

        Rec.CopySellToCustomerFilter;

        IsSimplePage := false;

        if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then
            Hyperlink('https://businesscentral.dynamics.com/UAT?page=50146&company=HEQS%20International%20Pty%20Ltd&dc=0&bookmark=35%3bJAAAAACLAQAAAAJ7%2f0kATgBUADEAMAAxADAAMAAx');
    end;

    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        IsSimplePage: Boolean;
        DeliveryDescription: Text;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        DocPrint: Codeunit "Document-Print";
        ReportPrint: Codeunit "Test Report-Print";
        UserMgt: Codeunit "User Setup Management";
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        [InDataSet]
        JobQueueActive: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CRMIntegrationEnabled: Boolean;
        IsOfficeAddin: Boolean;
        CanCancelApprovalForRecord: Boolean;
        SkipLinesWithoutVAT: Boolean;
        PowerBIVisible: Boolean;
        ReadyToPostQst: Label 'The number of orders that will be posted is %1. \Do you want to continue?', Comment = '%1 - selected count';
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;

    procedure ShowPreview()
    var
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
    begin
        SalesPostYesNo.Preview(Rec);
    end;


    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);

        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    local procedure PostDocument(PostingCodeunitID: Integer)
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
            LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(Rec);

        SendToPosting(PostingCodeunitID);

        CurrPage.Update(false);
    end;

    procedure SkipShowingLinesWithoutVAT()
    begin
        SkipLinesWithoutVAT := true;
    end;

    local procedure ShowHeader(): Boolean
    var
        CashFlowManagement: Codeunit "Cash Flow Management";
    begin
        if not SkipLinesWithoutVAT then
            exit(true);

        exit(CashFlowManagement.GetTaxAmountFromSalesOrder(Rec) <> 0);
    end;
}

