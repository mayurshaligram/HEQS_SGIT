enum 50145 "Delivery Option"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Pickup)
    {
    }
    value(2; Delivery)
    {

    }

}
tableextension 50100 "Sales Header_Ext" extends "Sales Header"
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
        field(50147; "Delivery Item"; Text[1000])
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
            Editable = false;
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
        field(50131; "Assembly Item"; Text[200])

        {
            Caption = 'Assembly Item';
            Description = 'Assembly Item';
            Editable = false;
        }
        field(50130; "Delivery without BOM Item"; Text[1000])
        {
            Caption = 'Delivery without BOM Item';
            Description = 'Display all the item without BOM in this sales Header';
            Editable = false;
        }
        field(50129; "Assembly Item without BOM Item"; Text[200])
        {
            Caption = 'Assembly Item without BOM';
            Description = 'Assembly Item without BOM';
            Editable = false;
        }
    }

    trigger OnAfterInsert();
    begin
        if Rec.CurrentCompany <> InventoryCompanyName then
            if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = Rec."Document Type"::"Return Order") then
                OnInsertPurchaseHeader(Rec)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertPurchaseHeader(var SalesHeader: Record "Sales Header");
    begin
    end;



    trigger OnAfterModify();
    var
        TempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
        ISLrec: Record "Sales Line";
        SLrec: Record "Sales Line";
        Whship: Record "Warehouse Request";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        TextList: List of [Text];

        ICSalesOrder: Record "Sales Header";
    begin
        if Rec.CurrentCompany <> InventoryCompanyName then
            if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = Rec."Document Type"::"Return Order") then begin
                if POrecord.Get(Rec."Document Type", Rec."Automate Purch.Doc No.") then begin
                    UpdatePurchaseHeader(POrecord);
                end;

                // Action 2 SO
                SORecord.ChangeCompany(InventoryCompanyName);
                SORecord.SetCurrentKey("External Document No.");
                SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                if (SORecord.findset) then
                    repeat
                        ICrec.ChangeCompany(InventoryCompanyName);
                        ICrec."Due Date" := Rec."Due Date";
                        ICRec.Get(SORecord."Document type", SORecord."No.");
                        ICrec."Ship-to Name" := rec."Ship-to Name";
                        ICrec."Ship-to Address" := rec."Ship-to Address";
                        ICrec.Ship := rec.ship;
                        ICrec."Work Description" := rec."Work Description";
                        rec.CALCFIELDS("Work Description");
                        ICrec."Work Description" := rec."Work Description";
                        ICrec."Document Date" := DT2DATE(system.CurrentDateTime);
                        ICrec.Status := rec.Status;
                        ICREC.Modify();
                        SLrec.SetCurrentKey("Document No.");
                        SLrec.SetRange("Document No.", rec."No.");
                        ISLrec.ChangeCompany(InventoryCompanyName);
                        if (SLrec.findset) then
                            repeat
                                if SLrec.Type = SLrec.Type::Item then begin
                                    if ISLrec.Get(SLrec."Document Type", ICREC."No.", SLrec."Line No.") then begin
                                        // UPdata
                                        ISLrec.Type := SLrec.Type::Item;
                                        ISLrec."No." := SLrec."No.";
                                        ISLrec."Document Type" := SLrec."Document Type";
                                        ISLrec."Document No." := ICREC."No.";
                                        ISLrec.Type := SLrec.Type::Item;
                                        ISLrec."Line No." := SLrec."Line No.";
                                        ISLrec."No." := SLrec."No.";
                                        ISLrec."Description" := SLrec."Description";
                                        ISLrec.Quantity := SLrec.Quantity;
                                        ISLrec."Location Code" := SLrec."Location Code";
                                        ISLrec."Unit Price" := SLrec."Unit Price";
                                        ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                        ISLrec."Bin Code" := SLrec."Bin Code";
                                        ISLrec."Unit of Measure Code" := SLrec."Unit of Measure Code";
                                        // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                        // ISLrec.UpdateAmounts();
                                        ISLrec.Modify()
                                    end
                                    else begin
                                        ISLrec.Type := SLrec.Type::Item;
                                        ISLrec."No." := SLrec."No.";
                                        ISLrec."Document Type" := SLrec."Document Type";
                                        ISLrec."Document No." := ICREC."No.";
                                        ISLrec.Type := SLrec.Type::Item;
                                        ISLrec."Line No." := SLrec."Line No.";
                                        ISLrec."No." := SLrec."No.";
                                        ISLrec."Description" := SLrec."Description";
                                        ISLrec.Quantity := SLrec.Quantity;
                                        ISLrec."Location Code" := SLrec."Location Code";
                                        ISLrec."Unit of Measure" := SLrec."Unit of Measure";
                                        ISLrec."Bin Code" := SLrec."Bin Code";
                                        ISLrec."Unit of Measure Code" := SLrec."Unit of Measure";
                                        ISLrec."Unit Price" := SLrec."Unit Price";
                                        // message('in onafteraction %1 %2 %3', ISLrec.CurrentCompany, ISLrec."No.", ISLrec.Type);
                                        ISLrec.UpdateAmounts();
                                        ISLrec.Insert();
                                    end;
                                end;
                            until (SLrec.Next() = 0);
                    until (SORecord.next() = 0);
            end;
    end;

    trigger OnAfterDelete();
    var
        TempText: Text[20];
        hasPO: Boolean;
        POrecord: Record "Purchase Header";
        SORecord: Record "Sales Header";
        icrec: Record "sales Header";
    begin
        if rec.CurrentCompany <> InventoryCompanyName then
            if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = Rec."Document Type"::"Return Order") then begin
                // Action 1 PO 
                if POrecord.Get(Porecord."Document Type"::Order, Rec."Automate Purch.Doc No.") then begin
                    POrecord.Delete();
                end;

                // Action 2 SO
                SORecord.ChangeCompany(InventoryCompanyName);
                SORecord.SetCurrentKey("External Document No.");
                SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                if (SORecord.findset) then
                    repeat
                        ICrec.ChangeCompany(InventoryCompanyName);
                        ICRec.get(SORecord."Document type", SORecord."No.");
                        ICREC.Delete();
                    until (SORecord.next() = 0);
            end;
    end;

    local procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        "Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify;
    end;

    local procedure GetWorkDescription() WorkDescription: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Work Description");
        "Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), WorkDescription) then
            Message(ReadingDataSkippedMsg, FieldCaption("Work Description"));
    end;

    procedure loadlines();
    var
        sline: Record "Sales Line";
        FromSO: Record "Sales Header";
        Temptext: Text[20];
        pline: Record "Purchase Line";
        pGetFlag: Boolean;
        Vendor: Record Vendor;
    begin
        sline.SetCurrentKey("Document Type", "Document No.", "Line No.");
        sline.SetRange("Document Type", rec."Document type");
        sline.SetRange("Document No.", rec."No.");
        sline.SetRange("Line No.", 1, 10000);
        if (sline.findset) then
            repeat
                FromSO.Get(Sline."Document No.");
                pGetFlag := pline.GET(sline."Document Type", FromSO."Automate Purch.Doc No.", sline."Line No.");
                pline."Document Type" := sline."Document Type";
                pline."Document No." := Temptext;
                pline."Line No." := sline."Line No.";
                pline.Type := sline.Type;
                pline."No." := sline."No.";
                pline."Description" := sline."Description";
                pline.Quantity := sline.Quantity;
                pline."Location Code" := sline."Location Code";
                pline."Unit of Measure" := sline."Unit of Measure";
                pline."Bin Code" := sline."Bin Code";
                pline."Unit Price (LCY)" := sline."Unit Price";
                Vendor."Search Name" := InventoryCompanyName;
                Vendor.FindSet();
                pline."Buy-from Vendor No." := Vendor."No.";
                pline."Pay-to Vendor No." := Vendor."No.";
                pline."Unit of Measure Code" := sline."Unit of Measure Code";
                if not pGetFlag then begin
                    if not ((pline."Document Type" = pline."Document Type"::Quote) and (pline."Document No." = '') and (pline."No." = '0')) then
                        pline.Insert();
                end else
                    pline.Modify();
            until (sline.next() = 0);
    end;

    procedure returnBeautifulText(): Text;
    var
        mytext: Text;
        myInstream: inStream;
    begin
        rec."Work Description".CreateinStream(myInstream);
        myinstream.Read(mytext, 100);
        Exit(mytext);
    end;




    procedure UpdatePurchaseHeader(PurchaseHeader: Record "Purchase Header");
    var
        Vendor: Record Vendor;
        InventoryCompanyName: Text;
    begin
        InventoryCompanyName := 'HEQS INTERNATIONAL PTY LTD';
        Vendor."Search Name" := InventoryCompanyName;
        Vendor.FindSet();
        PurchaseHeader."Buy-from Vendor No." := Vendor."No.";
        PurchaseHeader."Buy-from Vendor Name" := Vendor.Name;
        // Update Based on SO
        PurchaseHeader."Pay-to Vendor No." := Vendor."No.";
        PurchaseHeader."Pay-to Name" := Vendor.Name;
        PurchaseHeader."VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
        PurchaseHeader."Order Date" := System.Today();

        PurchaseHeader."Document Date" := Rec."Document Date";
        PurchaseHeader."Location Code" := Rec."Location Code";
        PurchaseHeader.Amount := Rec.Amount;
        Rec.CALCFIELDS("Work Description");
        PurchaseHeader."Work Description" := Rec."Work Description";
        PurchaseHeader."Ship-to Address" := Rec."Ship-to Address";
        PurchaseHeader."Ship-to Contact" := Rec."Ship-to Contact";
        PurchaseHeader."Currency Code" := Rec."Currency Code";
        PurchaseHeader."Ship-to Name" := Rec."Ship-to Name";
        PurchaseHeader."Ship-to Address" := Rec."Ship-to Address";
        PurchaseHeader."Send IC Document" := true;
        PurchaseHeader."Posting Date" := Rec."Posting Date";
        PurchaseHeader."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
        PurchaseHeader."Status" := Rec."Status";
        PurchaseHeader.Modify();
    end;

    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        Text003: Label 'You cannot rename a %1.';
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        Text005: Label 'You cannot reset %1 because the document still has one or more lines.';
        Text006: Label 'You cannot change %1 because the order is associated with one or more purchase orders.';
        Text007: Label '%1 cannot be greater than %2 in the %3 table.';
        Text009: Label 'Deleting this document will cause a gap in the number series for shipments. An empty shipment %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        Text012: Label 'Deleting this document will cause a gap in the number series for posted invoices. An empty posted invoice %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        Text014: Label 'Deleting this document will cause a gap in the number series for posted credit memos. An empty posted credit memo %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        RecreateSalesLinesExtMsg: Label 'If you change %1, the existing sales lines will be deleted and new sales lines based on the new information on the header will be created.\\Do you want to continue?', Comment = '%1: FieldCaption';
        ResetItemChargeAssignMsg: Label 'If you change %1, the existing sales lines will be deleted and new sales lines based on the new information on the header will be created.\The amount of the item charge assignment will be reset to 0.\\Do you want to continue?', Comment = '%1: FieldCaption';
        LinesNotUpdatedMsg: Label 'You have changed %1 on the sales header, but it has not been changed on the existing sales lines.', Comment = 'You have changed Order Date on the sales header, but it has not been changed on the existing sales lines.';
        Text019: Label 'You must update the existing sales lines manually.';
        AffectExchangeRateMsg: Label 'The change may affect the exchange rate that is used for price calculation on the sales lines.';
        Text021: Label 'Do you want to update the exchange rate?';
        Text022: Label 'You cannot delete this document. Your identification is set up to process from %1 %2 only.';
        Text024: Label 'You have modified the %1 field. The recalculation of VAT may cause penny differences, so you must check the amounts afterward. Do you want to update the %2 field on the lines to reflect the new value of %1?';
        Text027: Label 'Your identification is set up to process from %1 %2 only.';
        Text028: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text030: Label 'Deleting this document will cause a gap in the number series for return receipts. An empty return receipt %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        Text031: Label 'You have modified %1.\\Do you want to update the lines?', Comment = 'You have modified Shipment Date.\\Do you want to update the lines?';
        ReadingDataSkippedMsg: Label 'Loading field %1 will be skipped because there was an error when reading the data.\To fix the current data, contact your administrator.\Alternatively, you can overwrite the current data by entering data in the field.', Comment = '%1=field caption';
        SalesSetup: Record "Sales & Receivables Setup";
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Cust: Record Customer;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        CurrExchRate: Record "Currency Exchange Rate";
        PostCode: Record "Post Code";
        BankAcc: Record "Bank Account";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        SalesInvHeaderPrepmt: Record "Sales Invoice Header";
        SalesCrMemoHeaderPrepmt: Record "Sales Cr.Memo Header";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        RespCenter: Record "Responsibility Center";
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        WhseRequest: Record "Warehouse Request";
        ReservEntry: Record "Reservation Entry";
        TempReservEntry: Record "Reservation Entry" temporary;
        CompanyInfo: Record "Company Information";
        Salesperson: Record "Salesperson/Purchaser";
        UserSetupMgt: Codeunit "User Setup Management";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        CustEntryEdit: Codeunit "Cust. Entry-Edit";
        DimMgt: Codeunit DimensionManagement;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WhseSourceHeader: Codeunit "Whse. Validate Source Header";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        // PostCodeCheck: Codeunit "Post Code Check";
        // BASManagement: Codeunit "BAS Management";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
        CurrencyDate: Date;
        Confirmed: Boolean;
        Text035: Label 'You cannot Release Quote or Make Order unless you specify a customer on the quote.\\Do you want to create customer(s) now?';
        Text037: Label 'Contact %1 %2 is not related to customer %3.';
        Text038: Label 'Contact %1 %2 is related to a different company than customer %3.';
        ContactIsNotRelatedToAnyCostomerErr: Label 'Contact %1 %2 is not related to a customer.';
        Text040: Label 'A won opportunity is linked to this order.\It has to be changed to status Lost before the Order can be deleted.\Do you want to change the status for this opportunity now?';
        Text044: Label 'The status of the opportunity has not been changed. The program has aborted deleting the order.';
        SkipSellToContact: Boolean;
        SkipBillToContact: Boolean;
        Text045: Label 'You can not change the %1 field because %2 %3 has %4 = %5 and the %6 has already been assigned %7 %8.';
        Text048: Label 'Sales quote %1 has already been assigned to opportunity %2. Would you like to reassign this quote?';
        Text049: Label 'The %1 field cannot be blank because this quote is linked to an opportunity.';
        InsertMode: Boolean;
        HideCreditCheckDialogue: Boolean;
        Text051: Label 'The sales %1 %2 already exists.';
        Text053: Label 'You must cancel the approval process if you wish to change the %1.';
        Text056: Label 'Deleting this document will cause a gap in the number series for prepayment invoices. An empty prepayment invoice %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        Text057: Label 'Deleting this document will cause a gap in the number series for prepayment credit memos. An empty prepayment credit memo %1 will be created to fill this gap in the number series.\\Do you want to continue?';
        Text061: Label '%1 is set up to process from %2 %3 only.';
        Text062: Label 'You cannot change %1 because the corresponding %2 %3 has been assigned to this %4.';
        Text063: Label 'Reservations exist for this order. These reservations will be canceled if a date conflict is caused by this change.\\Do you want to continue?';
        Text064: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        UpdateDocumentDate: Boolean;
        Text066: Label 'You cannot change %1 to %2 because an open inventory pick on the %3.';
        Text070: Label 'You cannot change %1  to %2 because an open warehouse shipment exists for the %3.';
        BilltoCustomerNoChanged: Boolean;
        SelectNoSeriesAllowed: Boolean;
        PrepaymentInvoicesNotPaidErr: Label 'You cannot post the document of type %1 with the number %2 before all related prepayment invoices are posted.', Comment = 'You cannot post the document of type Order with the number 1001 before all related prepayment invoices are posted.';
        Text072: Label 'There are unpaid prepayment invoices related to the document of type %1 with the number %2.';
        Text1500000: Label '%1 and %2 must be identical or %1 must be Blank.';
        DeferralLineQst: Label 'Do you want to update the deferral schedules for the lines?';
        SynchronizingMsg: Label 'Synchronizing ...\ from: Sales Header with %1\ to: Assembly Header with %2.';
        EstimateTxt: Label 'Estimate';
        ShippingAdviceErr: Label 'This document cannot be shipped completely. Change the value in the Shipping Advice field to Partial.';
        PostedDocsToPrintCreatedMsg: Label 'One or more related posted documents have been generated during deletion to fill gaps in the posting number series. You can view or print the documents from the respective document archive.';
        DocumentNotPostedClosePageQst: Label 'The document has been saved but is not yet posted.\\Are you sure you want to exit?';
        SelectCustomerTemplateQst: Label 'Do you want to select the customer template?';
        ModifyCustomerAddressNotificationLbl: Label 'Update the address';
        DontShowAgainActionLbl: Label 'Don''t show again';
        ModifyCustomerAddressNotificationMsg: Label 'The address you entered for %1 is different from the customer''s existing address.', Comment = '%1=customer name';
        ValidVATNoMsg: Label 'The VAT registration number is valid.';
        InvalidVatRegNoMsg: Label 'The VAT registration number is not valid. Try entering the number again.';
        SellToCustomerTxt: Label 'Sell-to Customer';
        BillToCustomerTxt: Label 'Bill-to Customer';
        ModifySellToCustomerAddressNotificationNameTxt: Label 'Update Sell-to Customer Address';
        ModifySellToCustomerAddressNotificationDescriptionTxt: Label 'Warn if the sell-to address on sales documents is different from the customer''s existing address.';
        ModifyBillToCustomerAddressNotificationNameTxt: Label 'Update Bill-to Customer Address';
        ModifyBillToCustomerAddressNotificationDescriptionTxt: Label 'Warn if the bill-to address on sales documents is different from the customer''s existing address.';
        DuplicatedCaptionsNotAllowedErr: Label 'Field captions must not be duplicated when using this method. Use UpdateSalesLinesByFieldNo instead.';
        PhoneNoCannotContainLettersErr: Label 'You cannot enter letters in this field.';
        SplitMessageTxt: Label '%1\%2', Comment = 'Some message text 1.\Some message text 2.';
        ConfirmEmptyEmailQst: Label 'Contact %1 has no email address specified. The value in the Email field on the sales order, %2, will be deleted. Do you want to continue?', Comment = '%1 - Contact No., %2 - Email';
        FullSalesTypesTxt: Label 'Sales Quote,Sales Order,Sales Invoice,Sales Credit Memo,Sales Blanket Order,Sales Return Order';
        RecreateSalesLinesExtCancelErr: Label 'You must delete the existing sales lines before you can change %1.', Comment = '%1 - Field Name, Sample: You must delete the existing sales lines before you can change Currency Code.';
        CalledFromWhseDoc: Boolean;


    procedure RecreateSalesLinesExt(ChangedFieldName: Text[100])
    var
        TempSalesLine: Record "Sales Line" temporary;
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary;
        TempInteger: Record "Integer" temporary;
        TempATOLink: Record "Assemble-to-Order Link" temporary;
        SalesCommentLine: Record "Sales Comment Line";
        TempSalesCommentLine: Record "Sales Comment Line" temporary;
        ATOLink: Record "Assemble-to-Order Link";
        ExtendedTextAdded: Boolean;
        ConfirmText: Text;
        IsHandled: Boolean;
    begin
        if not SalesLinesExist() then
            exit;

        IsHandled := false;
        //OnBeforeRecreateSalesLinesExtHandler(Rec, xRec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        IsHandled := false;
        //OnRecreateSalesLinesExtOnBeforeConfirm(Rec, xRec, ChangedFieldName, HideValidationDialog, Confirmed, IsHandled);
        if not IsHandled then
            if GetHideValidationDialog() or not GuiAllowed() then
                Confirmed := true
            else begin
                if HasItemChargeAssignment() then
                    ConfirmText := ResetItemChargeAssignMsg
                else
                    ConfirmText := RecreateSalesLinesExtMsg;
                // Confirmed := Confirm(ConfirmText, false, ChangedFieldName);
            end;

        if true then begin
            SalesLine.LockTable();
            ItemChargeAssgntSales.LockTable();
            ReservEntry.LockTable();
            Modify();
            //OnBeforeRecreateSalesLinesExt(Rec);
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", "Document Type");
            SalesLine.SetRange("Document No.", "No.");
            //OnRecreateSalesLinesExtOnAfterSetSalesLineFilters(SalesLine);
            if SalesLine.FindSet() then begin
                TempReservEntry.DeleteAll();
                RecreateReservEntryReqLine(TempSalesLine, TempATOLink, ATOLink);
                StoreSalesCommentLineToTemp(TempSalesCommentLine);
                SalesCommentLine.DeleteComments("Document Type".AsInteger(), "No.");
                TransferItemChargeAssgntSalesToTemp(ItemChargeAssgntSales, TempItemChargeAssgntSales);
                IsHandled := false;
                //OnRecreateSalesLinesExtOnBeforeSalesLineDeleteAll(Rec, SalesLine, CurrFieldNo, IsHandled);
                if not IsHandled then
                    SalesLine.DeleteAll(true);

                SalesLine.Init();
                SalesLine."Line No." := 0;
                // OnRecreateSalesLinesExtOnBeforeTempSalesLineFindSet(TempSalesLine);
                TempSalesLine.FindSet();
                ExtendedTextAdded := false;
                SalesLine.BlockDynamicTracking(true);
                repeat
                    RecreateSalesLinesExtHandleSupplementTypes(TempSalesLine, ExtendedTextAdded, TempItemChargeAssgntSales, TempInteger);
                    // SalesLineReserve.CopyReservEntryFromTemp(TempReservEntry, TempSalesLine, SalesLine."Line No.");
                    RecreateReqLine(TempSalesLine, SalesLine."Line No.", false);
                    // SynchronizeForReservations(SalesLine, TempSalesLine);

                    if TempATOLink.AsmExistsForSalesLine(TempSalesLine) then begin
                        ATOLink := TempATOLink;
                        ATOLink."Document Line No." := SalesLine."Line No.";
                        ATOLink.Insert();
                        ATOLink.UpdateAsmFromSalesLineATOExist(SalesLine);
                        TempATOLink.Delete();
                    end;
                until TempSalesLine.Next() = 0;

                RestoreSalesCommentLineFromTemp(TempSalesCommentLine);

                CreateItemChargeAssgntSales(TempItemChargeAssgntSales, TempSalesLine, TempInteger);

                TempSalesLine.SetRange(Type);
                TempSalesLine.DeleteAll();
                // OnAfterDeleteAllTempSalesLines(Rec);
                ClearItemAssgntSalesFilter(TempItemChargeAssgntSales);
                TempItemChargeAssgntSales.DeleteAll();
            end;
        end else
            Error(RecreateSalesLinesExtCancelErr, ChangedFieldName);

        SalesLine.BlockDynamicTracking(false);

        // OnAfterRecreateSalesLinesExt(Rec, ChangedFieldName);
    end;

    local procedure RecreateSalesLinesExtHandleSupplementTypes(var TempSalesLine: Record "Sales Line" temporary; var ExtendedTextAdded: Boolean; var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary; var TempInteger: Record "Integer" temporary)
    var
        TransferExtendedText: Codeunit "Transfer Extended Text";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // OnBeforeRecreateSalesLinesExtHandleSupplementTypes(TempSalesLine, IsHandled);
        if IsHandled then
            exit;

        if TempSalesLine."Attached to Line No." = 0 then begin
            CreateSalesLine(TempSalesLine);
            ExtendedTextAdded := false;
            // OnAfterRecreateSalesLine(SalesLine, TempSalesLine);

            if SalesLine.Type = SalesLine.Type::Item then
                RecreateSalesLinesExtFillItemChargeAssignment(SalesLine, TempSalesLine, TempItemChargeAssgntSales);

            if SalesLine.Type = SalesLine.Type::"Charge (Item)" then begin
                TempInteger.Init();
                TempInteger.Number := SalesLine."Line No.";
                TempInteger.Insert();
            end;
        end else
            if not ExtendedTextAdded then begin
                TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, true);
                TransferExtendedText.InsertSalesExtText(SalesLine);
                // OnAfterTransferExtendedTextForSalesLineRecreation(SalesLine, TempSalesLine);

                SalesLine.FindLast();
                ExtendedTextAdded := true;
            end;
    end;

    local procedure StoreSalesCommentLineToTemp(var TempSalesCommentLine: Record "Sales Comment Line" temporary)
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.SetRange("Document Type", "Document Type");
        SalesCommentLine.SetRange("No.", "No.");
        if SalesCommentLine.FindSet() then
            repeat
                TempSalesCommentLine := SalesCommentLine;
                TempSalesCommentLine.Insert();
            until SalesCommentLine.Next() = 0;
    end;

    local procedure RestoreSalesCommentLineFromTemp(var TempSalesCommentLine: Record "Sales Comment Line" temporary)
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        TempSalesCommentLine.SetRange("Document Type", "Document Type");
        TempSalesCommentLine.SetRange("No.", "No.");
        if TempSalesCommentLine.FindSet() then
            repeat
                SalesCommentLine := TempSalesCommentLine;
                SalesCommentLine.Insert();
            until TempSalesCommentLine.Next() = 0;
    end;

    local procedure RecreateSalesLinesExtFillItemChargeAssignment(SalesLine: Record "Sales Line"; TempSalesLine: Record "Sales Line" temporary; var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary)
    begin
        ClearItemAssgntSalesFilter(TempItemChargeAssgntSales);
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. Type", TempSalesLine."Document Type");
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. No.", TempSalesLine."Document No.");
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.", TempSalesLine."Line No.");
        if TempItemChargeAssgntSales.FindSet then
            repeat
                if not TempItemChargeAssgntSales.Mark then begin
                    TempItemChargeAssgntSales."Applies-to Doc. Line No." := SalesLine."Line No.";
                    TempItemChargeAssgntSales.Description := SalesLine.Description;
                    TempItemChargeAssgntSales.Modify();
                    TempItemChargeAssgntSales.Mark(true);
                end;
            until TempItemChargeAssgntSales.Next = 0;
    end;

    local procedure MessageIfSalesLinesExist(ChangedFieldName: Text[100])
    var
        MessageText: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // OnBeforeMessageIfSalesLinesExist(Rec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        if SalesLinesExist and not GetHideValidationDialog then begin
            MessageText := StrSubstNo(LinesNotUpdatedMsg, ChangedFieldName);
            MessageText := StrSubstNo(SplitMessageTxt, MessageText, Text019);
            Message(MessageText);
        end;
    end;

    local procedure PriceMessageIfSalesLinesExist(ChangedFieldName: Text[100])
    var
        MessageText: Text;
        IsHandled: Boolean;
    begin
        // OnBeforePriceMessageIfSalesLinesExist(Rec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        if SalesLinesExist and not GetHideValidationDialog then begin
            MessageText := StrSubstNo(LinesNotUpdatedMsg, ChangedFieldName);
            if "Currency Code" <> '' then
                MessageText := StrSubstNo(SplitMessageTxt, MessageText, AffectExchangeRateMsg);
            Message(MessageText);
        end;
    end;

    local procedure HasItemChargeAssignment(): Boolean
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Document Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", "No.");
        ItemChargeAssgntSales.SetFilter("Amount to Assign", '<>%1', 0);
        exit(not ItemChargeAssgntSales.IsEmpty);
    end;

    local procedure RecreateReservEntryReqLine(var TempSalesLine: Record "Sales Line" temporary; var TempATOLink: Record "Assemble-to-Order Link" temporary; var ATOLink: Record "Assemble-to-Order Link")
    begin
        repeat
            TestSalesLineFieldsBeforeRecreate;
            if (SalesLine."Location Code" <> "Location Code") and (not SalesLine.IsNonInventoriableItem) then
                SalesLine.Validate("Location Code", "Location Code");
            TempSalesLine := SalesLine;
            if SalesLine.Nonstock then begin
                SalesLine.Nonstock := false;
                SalesLine.Modify();
            end;

            if ATOLink.AsmExistsForSalesLine(TempSalesLine) then begin
                TempATOLink := ATOLink;
                TempATOLink.Insert();
                ATOLink.Delete();
            end;

            TempSalesLine.Insert();
            // OnAfterInsertTempSalesLine(SalesLine, TempSalesLine);
            // SalesLineReserve.CopyReservEntryToTemp(TempReservEntry, SalesLine);
            RecreateReqLine(SalesLine, 0, true);
        // OnRecreateReservEntryReqLineOnAfterLoop(Rec);
        until SalesLine.Next = 0;
    end;


    local procedure TestSalesLineFieldsBeforeRecreate()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // OnBeforeTestSalesLineFieldsBeforeRecreate(Rec, IsHandled, SalesLine);
        if IsHandled then
            exit;

        SalesLine.TestField("Job No.", '');
        SalesLine.TestField("Job Contract Entry No.", 0);
        SalesLine.TestField("Quantity Invoiced", 0);
        SalesLine.TestField("Return Qty. Received", 0);
        SalesLine.TestField("Shipment No.", '');
        SalesLine.TestField("Return Receipt No.", '');
        SalesLine.TestField("Blanket Order No.", '');
        SalesLine.TestField("Prepmt. Amt. Inv.", 0);
        TestQuantityShippedField(SalesLine);
    end;

    local procedure RecreateReqLine(OldSalesLine: Record "Sales Line"; NewSourceRefNo: Integer; ToTemp: Boolean)
    var
        ReqLine: Record "Requisition Line";
        TempReqLine: Record "Requisition Line" temporary;
    begin
        if ("Document Type" = "Document Type"::Order) then
            if ToTemp then begin
                ReqLine.SetCurrentKey("Order Promising ID", "Order Promising Line ID", "Order Promising Line No.");
                ReqLine.SetRange("Order Promising ID", OldSalesLine."Document No.");
                ReqLine.SetRange("Order Promising Line ID", OldSalesLine."Line No.");
                if ReqLine.FindSet() then begin
                    repeat
                        TempReqLine := ReqLine;
                        TempReqLine.Insert();
                    until ReqLine.Next() = 0;
                    ReqLine.DeleteAll();
                end;
            end else begin
                Clear(TempReqLine);
                TempReqLine.SetCurrentKey("Order Promising ID", "Order Promising Line ID", "Order Promising Line No.");
                TempReqLine.SetRange("Order Promising ID", OldSalesLine."Document No.");
                TempReqLine.SetRange("Order Promising Line ID", OldSalesLine."Line No.");
                if TempReqLine.FindSet() then begin
                    repeat
                        ReqLine := TempReqLine;
                        ReqLine."Order Promising Line ID" := NewSourceRefNo;
                        ReqLine.Insert();
                    until TempReqLine.Next() = 0;
                    TempReqLine.DeleteAll();
                end;
            end;
    end;

    local procedure TransferItemChargeAssgntSalesToTemp(var ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)"; var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary)
    begin
        ItemChargeAssgntSales.SetRange("Document Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", "No.");
        if ItemChargeAssgntSales.FindSet then begin
            repeat
                TempItemChargeAssgntSales.Init();
                TempItemChargeAssgntSales := ItemChargeAssgntSales;
                TempItemChargeAssgntSales.Insert();
            until ItemChargeAssgntSales.Next = 0;
            ItemChargeAssgntSales.DeleteAll();
        end;
    end;

    local procedure CreateItemChargeAssgntSales(var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary; var TempSalesLine: Record "Sales Line" temporary; var TempInteger: Record "Integer" temporary)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ClearItemAssgntSalesFilter(TempItemChargeAssgntSales);
        TempSalesLine.SetRange(Type, SalesLine.Type::"Charge (Item)");
        if TempSalesLine.FindSet then
            repeat
                TempItemChargeAssgntSales.SetRange("Document Line No.", TempSalesLine."Line No.");
                if TempItemChargeAssgntSales.FindSet then begin
                    repeat
                        TempInteger.FindFirst;
                        ItemChargeAssgntSales.Init();
                        ItemChargeAssgntSales := TempItemChargeAssgntSales;
                        ItemChargeAssgntSales."Document Line No." := TempInteger.Number;
                        ItemChargeAssgntSales.Validate("Unit Cost", 0);
                        ItemChargeAssgntSales.Insert();
                    until TempItemChargeAssgntSales.Next = 0;
                    TempInteger.Delete();
                end;
            until TempSalesLine.Next = 0;

        ClearItemAssgntSalesFilter(TempItemChargeAssgntSales);
        TempItemChargeAssgntSales.DeleteAll();
    end;

    local procedure ClearItemAssgntSalesFilter(var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)" temporary)
    begin
        TempItemChargeAssgntSales.SetRange("Document Line No.");
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. Type");
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. No.");
        TempItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.");
    end;

    local procedure CreateSalesLine(var TempSalesLine: Record "Sales Line" temporary)
    var
        IsHandled: Boolean;
    begin
        // OnBeforeCreateSalesLine(TempSalesLine, IsHandled);
        if IsHandled then
            exit;

        SalesLine.Init();
        SalesLine."Line No." := SalesLine."Line No." + 10000;
        SalesLine."Price Calculation Method" := "Price Calculation Method";
        SalesLine.Validate(Type, TempSalesLine.Type);
        // OnCreateSalesLineOnAfterAssignType(SalesLine, TempSalesLine);
        if TempSalesLine."No." = '' then begin
            SalesLine.Validate(Description, TempSalesLine.Description);
            SalesLine.Validate("Description 2", TempSalesLine."Description 2");
        end else begin
            SalesLine.Validate("No.", TempSalesLine."No.");
            if SalesLine.Type <> SalesLine.Type::" " then begin
                SalesLine.Validate("Unit of Measure Code", TempSalesLine."Unit of Measure Code");
                SalesLine.Validate("Variant Code", TempSalesLine."Variant Code");
                // OnCreateSalesLineOnBeforeValidateQuantity(SalesLine, TempSalesLine);
                if TempSalesLine.Quantity <> 0 then begin
                    SalesLine.Validate(Quantity, TempSalesLine.Quantity);
                    SalesLine.Validate("Qty. to Assemble to Order", TempSalesLine."Qty. to Assemble to Order");
                end;
                SalesLine."Purchase Order No." := TempSalesLine."Purchase Order No.";
                SalesLine."Purch. Order Line No." := TempSalesLine."Purch. Order Line No.";
                SalesLine."Drop Shipment" := TempSalesLine."Drop Shipment";
            end;
            SalesLine.Validate("Shipment Date", TempSalesLine."Shipment Date");
        end;
        // OnBeforeSalesLineInsert(SalesLine, TempSalesLine, Rec);
        SalesLine.Insert();
        // OnAfterCreateSalesLine(SalesLine, TempSalesLine);
    end;
}