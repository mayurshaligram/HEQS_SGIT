// Codeunit modified existed Sales-Post
// For Post Shipment Only
codeunit 50106 "Sales-Post (Yes/No) Ext"
{
    EventSubscriberInstance = Manual;
    TableNo = "Sales Header";


    trigger OnRun()
    var

        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        TempInteger: Integer;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SalesHeader: Record "Sales Header";
        InventorySaleOrder: Record "Sales Header";
        Temp: Text;
        TempType: Enum "Sales Document Type";

        RetailSalesLine: Record "Sales Line";
        InventorySalesHeader: Record "Sales Header";
        InventorySalesLine: Record "Sales Line";

        ICSalesHeader: Record "Sales Header";
    begin

        // OnBeforeOnRun(Rec);

        // if not Find then
        //     Error(NothingToPostErr);
        Temp := Rec."External Document No.";
        TempType := Rec."Document Type";
        Rec."External Document No." := '';
        Rec.Status := Rec.Status::Open;



        Rec.Modify();

        TempInteger := 37;
        // message('OnBeforeActionCreating');
        // ReleaseSalesDoc.PerformManualRelease(Rec);

        // InventorySalesHeader.Reset();
        // InventorySalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        // InventorySalesHeader.SetRange(RetailSalesHeader, Rec."No.");
        // InventorySalesHeader.FindSet();

        // InventorySalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
        // InventorySalesLine.SetRange("Document Type", InventorySalesHeader."Document Type");
        // InventorySalesLine.SetRange("Document No.", InventorySalesHeader."No.");
        // if InventorySalesLine.FindSet() then begin
        //     RetailSalesLine.Reset();
        //     RetailSalesLine.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //     RetailSalesLine.Get(Rec."Document Type", Rec."No.", InventorySalesLine."Line No.");
        //     RetailSalesLine.Validate("Qty. to Ship", InventorySalesLine."Quantity Shipped");
        //     RetailSalesLine.Modify();
        // end;
        Rec.Status := Rec.Status::Released;

        ICSalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        ICSalesHeader.Get(TempType, Temp);
        ChangeQuantityToShipment(ICSalesHeader, Rec);
        Rec.Modify();

        SalesHeader.Copy(Rec);
        Code(SalesHeader, false);
        InventorySaleOrder.ChangeCompany('HEQS International Pty Ltd');
        InventorySaleOrder.Get(TempType, Temp);
        InventorySaleOrder."External Document No." := Rec."Automate Purch.Doc No.";
        InventorySaleOrder.Modify();


        // InventorySalesHeader.Reset();
        // InventorySalesHeader.ChangeCompany(SalesTruthMgt.InventoryCompany());
        // InventorySalesHeader.SetRange(RetailSalesHeader, Rec."No.");
        // InventorySalesHeader.FindSet();

        // if InventorySalesLine.FindSet() then begin
        //     RetailSalesLine.Reset();
        //     RetailSalesLine.ChangeCompany(InventorySalesHeader."Sell-to Customer Name");
        //     RetailSalesLine.Get(Rec."Document Type", Rec."No.", InventorySalesLine."Line No.");
        //     RetailSalesLine."Qty. to Invoice" := InventorySalesLine."Qty. to Invoice";
        //     RetailSalesLine.Modify();
        // end;
    end;

    var
        ShipInvoiceQst: Label '&Ship,&Invoice,Ship &and Invoice';
        PostConfirmQst: Label 'Do you want to post the %1?', Comment = '%1 = Document Type';
        ReceiveInvoiceQst: Label '&Receive,&Invoice,Receive &and Invoice';
        NothingToPostErr: Label 'There is nothing to post.';
        TaxDocPostConfirmQst: Label 'Do you want to post the Tax Document?';

    [Scope('OnPrem')]
    procedure PostAndSend(var SalesHeader: Record "Sales Header")
    var
        SalesHeaderToPost: Record "Sales Header";
    begin
        SalesHeaderToPost.Copy(SalesHeader);
        Code(SalesHeaderToPost, true);
        SalesHeader := SalesHeaderToPost;
    end;

    local procedure "Code"(var SalesHeader: Record "Sales Header"; PostAndSend: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        HideDialog: Boolean;
        IsHandled: Boolean;
        DefaultOption: Integer;
    begin
        HideDialog := false;
        IsHandled := false;
        DefaultOption := 1;
        // OnBeforeConfirmSalesPost(SalesHeader, HideDialog, IsHandled, DefaultOption, PostAndSend);
        // if IsHandled then
        //     exit;

        // if not HideDialog then
        //     if not ConfirmPost(SalesHeader, DefaultOption) then
        //         exit;

        // OnAfterConfirmPost(SalesHeader);
        ConfirmPost(SalesHeader, DefaultOption);
        SalesSetup.Get();
        CheckTaxNoSeries(SalesHeader, SalesSetup);
        if SalesSetup."Post with Job Queue" and not PostAndSend then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
        else
            RunSalesPost(SalesHeader);

        // OnAfterPost(SalesHeader);
    end;

    local procedure RunSalesPost(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunSalesPost(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
    end;

    local procedure ConfirmPost(var SalesHeader: Record "Sales Header"; DefaultOption: Integer) Result: Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        Selection: Integer;
        IsHandled: Boolean;
    begin
        // IsHandled := false;
        // OnBeforeConfirmPost(SalesHeader, DefaultOption, Result, IsHandled);
        // if IsHandled then
        //     exit(Result);
        // if DefaultOption > 3 then
        //     DefaultOption := 3;
        // if DefaultOption <= 0 then
        //     DefaultOption := 1;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    // Selection := StrMenu(ShipInvoiceQst, DefaultOption);
                    SalesHeader.Ship := true;
                    // Invoice := Selection in [2, 3];
                    // if Selection = 0 then
                    //     exit(false);
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    // Selection := StrMenu(ReceiveInvoiceQst, DefaultOption);
                    // if Selection = 0 then
                    //     exit(false);
                    SalesHeader.Receive := true;
                    // Receive := Selection in [1, 3];
                    // Invoice := Selection in [2, 3];
                end
            else
                if not ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(PostConfirmQst, LowerCase(Format(SalesHeader."Document Type"))), true)
                then
                    exit(false);
        end;
        SalesHeader."Print Posted Documents" := false;

        exit(true);
    end;

    local procedure CheckTaxNoSeries(SalesHeader: Record "Sales Header"; SalesSetup: Record "Sales & Receivables Setup")
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if SalesHeader.Invoice or (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) then begin
            GLSetup.Get();
            //     if GLSetup."Enable Tax Invoices" then begin
            //         if "Tax Document Marked" then
            //             SalesSetup.TestField("Posted Tax Invoice Nos.");
            //         if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
            //             if "Tax Document Marked" then
            //                 SalesSetup.TestField("Posted Tax Credit Memo Nos");
            //     end;
        end;
    end;

    procedure Preview(var SalesHeader: Record "Sales Header")
    var
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(SalesPostYesNo);
        GenJnlPostPreview.Preview(SalesPostYesNo, SalesHeader);
    end;

    local procedure ChangeQuantityToShipment(var ICSalesHeader: Record "Sales Header"; var RetailSalesHeader: Record "Sales Header");
    var
        ICSalesLine: Record "Sales Line";
        RetailSalesLine: Record "Sales Line";
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
    begin
        // Need to consider the occasion for both sales order and sales return order
        ICSalesLine.ChangeCompany(SalesTruthMgt.InventoryCompany());
        ICSalesLine.SetRange("Document Type", ICSalesHeader."Document Type");
        ICSalesLine.SetRange("Document No.", ICSalesHeader."No.");
        // Currently Only Concern about the IC Sales Order
        if (ICSalesHeader."Document Type" = ICSalesHeader."Document Type"::"Order") and (ICSalesLine.FindSet() = true) then
            repeat
                RetailSalesLine.Reset();
                RetailSalesLine.Get(RetailSalesHeader."Document Type"::Order, RetailSalesHeader."No.", ICSalesLine."Line No.");
                RetailSalesLine."Qty. to Ship" := ICSalesLine."Quantity Shipped" - RetailSalesLine."Quantity Shipped";
                RetailSalesLine."Qty. to Ship (Base)" := RetailSalesLine."Qty. to Ship";
                RetailSalesLine.Modify();
            until ICSalesLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(var SalesHeader: Record "Sales Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 19, 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.Copy(RecVar);
        SalesHeader.Receive := SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order";
        SalesHeader.Ship := SalesHeader."Document Type" = SalesHeader."Document Type"::Order;
        SalesHeader.Invoice := true;


        OnRunPreviewOnAfterSetPostingFlags(SalesHeader);

        SalesPost.SetPreviewMode(true);
        Result := SalesPost.Run(SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunPreviewOnAfterSetPostingFlags(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var DefaultOption: Integer; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmSalesPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer; var PostAndSend: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunSalesPost(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;
}

