pageextension 50106 "Sales Return Order_Ext" extends "Sales Return Order"
{

    actions
    {
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                Text1: Label 'Please release the current Sales Order in at "%1"';
            begin
                if SalesTruthMgt.IsICSalesHeader(Rec) then Error(Text1, Rec."Sell-to Customer Name")
            end;

            trigger OnAfterAction()
            var
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                PurchaseHeader: Record "Purchase Header";
                SORecord: Record "Sales Header";
                ICRec: Record "Sales Header";
                SLrec: Record "Sales Line";
                ISLrec: Record "Sales Line";
                ISOsrec: Record "Sales Header";
                Whship: Record "Warehouse Request";
                TempText: Text[20];
                hasPO: Boolean;
                InventoryCompanyName: Text;
            begin
                if SalesTruthMgt.IsRetailSalesHeader(Rec) then begin
                    PurchaseHeader.Get(Rec."Document Type", Rec."Automate Purch.Doc No.");
                    Rec.UpdatePurchaseHeader(PurchaseHeader);
                    SORecord.ChangeCompany(InventoryCompanyName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if not (SORecord.findset) then
                        // message('should create the SO in the inventory.');
                    if ApprovalsMgmt.PrePostApprovalCheckPurch(PurchaseHeader) then
                            ICInOutboxMgt.SendPurchDoc(PurchaseHeader, false);
                    SORecord.ChangeCompany(InventoryCompanyName);
                    SORecord.SetCurrentKey("External Document No.");
                    SORecord.SetRange("External Document No.", Rec."Automate Purch.Doc No.");
                    if (SORecord.findset) then
                        repeat
                            Whship.ChangeCompany(InventoryCompanyName);
                            Whship.Init();
                            Whship."Source Document" := Whship."Source Document"::"Sales Order";
                            Whship."Source No." := SORecord."No.";
                            Whship."External Document No." := SORecord."External Document No.";
                            Whship."Destination Type" := Whship."Destination Type"::Customer;
                            Whship."Destination No." := SORecord."Sell-to Customer No.";
                            Whship."Shipping Advice" := Whship."Shipping Advice"::Partial;
                            Whship.Insert();
                            ICrec.ChangeCompany(InventoryCompanyName);
                            // // message('%1, %2',SORecord."Document type", SORecord."No.");
                            ICRec.get(SORecord."Document type", SORecord."No.");
                            // // message('ICREC %1', ICRec."No.");
                            // // message('%1, %2', Rec.Status, ICRec.Status);
                            if Rec.Status = Rec.Status::Released then
                                if ICRec.Status <> Rec.Status then
                                    ReleaseSalesDoc.PerformManualRelease(ICrec);
                            // message('ICrec no %1, status %2', ICRec."No.", icrec.Status);
                            ICrec."Work Description" := Rec."Work Description";
                            Rec.CALCFIELDS("Work Description");
                            ICrec."Work Description" := Rec."Work Description";
                            ICRec.Status := Rec.Status;
                            ICREC.Modify();
                        until (SORecord.next() = 0);
                    // ISL updata
                end;
            end;
        }
        modify(Reopen)
        {
            trigger OnBeforeAction();
            var
                SalesOrder: Text;
                ErrorMessage: Label 'Please reopen the current Sales Order(%1) in at Retail Company';
                InventoryCompanyName: Text;
            begin
                InventoryCompanyName := 'HEQS International Pty Ltd';
                if Rec.CurrentCompany = InventoryCompanyName then
                    Error(ErrorMessage, Rec."No.");
            end;
        }
    }
    var
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnAfterGetRecord();
    var
        IsICSalesHeader: Boolean;
    begin
        IsICSalesHeader := SalesTruthMgt.IsICSalesHeader(Rec);

        // Temperory Solution
        if IsICSalesHeader then begin
            Currpage.Editable(false);
        end;
    end;

    //////////////////////////////////////////////////////////////////////////////////////

}