// Codeunit modified existed Sales-Post
// For Post Shipment Only
codeunit 50103 "Sales-Post (Yes/No) Ext Inv"
{
    EventSubscriberInstance = Manual;
    TableNo = "Sales Header";


    trigger OnRun()
    var


        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        TempInteger: Integer;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SalesHeader: Record "Sales Header";
    begin
        // OnBeforeOnRun(Rec);

        // if not Find then
        //     Error(NothingToPostErr);

        // Rec.Status := Rec.Status::Open;
        // Rec.Modify();
        // Rec.RecreateSalesLinesExt('Sell-to Customer');
        // SalesLine.SetRange("Document No.", Rec."No.");
        // if SalesLine.FindSet() then
        //     repeat
        //         SalesLine."Location Code" := 'NSW';
        //         SalesLine.Modify();
        //     until SalesLine.Next() = 0;
        // TempInteger := 37;
        // // message('OnBeforeActionCreating');
        // // ReleaseSalesDoc.PerformManualRelease(Rec);
        // Rec.Status := Rec.Status::Released;
        // Rec.Modify();

        SalesHeader.Copy(Rec);
        Code(SalesHeader, false);
        Rec := SalesHeader;
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
        DefaultOption := 2;
        // OnBeforeConfirmSalesPost(SalesHeader, HideDialog, IsHandled, DefaultOption, PostAndSend);
        // if IsHandled then
        //     exit;

        // if not HideDialog then
        //     if not ConfirmPost(SalesHeader, DefaultOption) then
        //         exit;

        //OnAfterConfirmPost(SalesHeader);
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
                    // Ship := true;
                    SalesHeader.Invoice := true;
                    if Selection = 0 then
                        exit(false);
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    // Selection := StrMenu(ReceiveInvoiceQst, DefaultOption);
                    // if Selection = 0 then
                    //     exit(false);
                    // Receive := Selection in [1, 3];
                    // Invoice := Selection in [2, 3];
                    SalesHeader.Invoice := true;
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
            // if GLSetup."Enable Tax Invoices" then begin
            //     if "Tax Document Marked" then
            //         SalesSetup.TestField("Posted Tax Invoice Nos.");
            //     if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
            //         if "Tax Document Marked" then
            //             SalesSetup.TestField("Posted Tax Credit Memo Nos");
            // end;
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

