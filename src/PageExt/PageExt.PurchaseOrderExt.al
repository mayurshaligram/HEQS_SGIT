pageextension 50102 "Purchase Order_Ext" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            group("Work Description")
            {
                Caption = 'Work Description';
                field(WorkDescription; WorkDescription)
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }
    actions
    {
        modify("Create &Whse. Receipt")
        {
            trigger OnBeforeAction();
            var
                WarehouseRequest: Record "Warehouse Request";
                TempInteger: Integer;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
            begin
                // Recreate The Purchase Line to Solve the BOM Carry Problem
                // Rec.Status := Rec.Status::Open;
                // Rec.Modify();
                // Rec.Validate("Buy-from Vendor Name", Rec."Buy-from Vendor Name");
                // Rec.RecreatePurchLines(Rec."Buy-from Vendor Name");
                // Rec.Status := Rec.Status::Released;
                // Rec.Validate(Status, Rec.Status::Released);
                // Rec.Modify();
                // What is the Difference Between the System One BOM and Customer BOM TODO

                // No Warehouse Line Created
                // PurchaseLine.Reset();
                // PurchaseLine.SetRange("Document No.", Rec."No.");
                // if PurchaseLine.FindSet() then
                //     repeat
                //         PurchaseLine."Location Code" := 'NSW';
                //         PUrchaseLine.Modify();
                //     until PurchaseLine.Next() = 0;
                // PurchaseLine Code is Zero
                //     TempInteger := 39;
                //     if WarehouseRequest.get(WarehouseRequest.Type::Inbound, PurchaseLine."Location Code", TempInteger, WarehouseRequest."Source Subtype"::"1", Rec."No.") then begin
                //         WarehouseRequest."Source Type" := 39;
                //         WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                //         Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                //         WarehouseRequest.Modify();
                //     end
                //     else begin
                //         WarehouseRequest.Init();
                //         WarehouseRequest.Type := WarehouseRequest.Type::Inbound;
                //         WarehouseRequest."Location Code" := PurchaseLine."Location Code";
                //         WarehouseRequest."Source Subtype" := TempInteger;
                //         WarehouseRequest."Source No." := Rec."No.";
                //         WarehouseRequest."Source Type" := 39;
                //         WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                //         Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                //         WarehouseRequest.Insert();
                //     end;
            end;
            //    
        }
        modify(Release)
        {
            trigger OnBeforeAction();
            var
                PurchaseLine: Record "Purchase Line";
                LocationCode: Code[10];
                User: Record User;
            begin
                User.Get(Database.UserSecurityId());
                if (Rec.CurrentCompany = InventoryCompanyName) and (Rec."Sales Order Ref" = '') then begin
                    PurchaseLine.SetRange("BOM Item", true);
                    PurchaseLine.SetRange("Document Type", Rec."Document Type");
                    PurchaseLine.SetRange("Document No.", Rec."No.");
                    if PurchaseLine.FindSet() then
                        repeat
                            LocationCode := PurchaseLine."Location Code";
                            PurchaseLine.Validate("No.", PurchaseLine."No.");
                            PurchaseLine."Location Code" := LocationCode;
                            PurchaseLine.Modify();
                        until PurchaseLine.Next() = 0;
                end
                else
                    if User."Full Name" <> 'Pei Xu' then
                        Error('Please do release action in "%1", Sales Order: "%2"', Rec.CurrentCompany, Rec."Sales Order Ref");
            end;
        }
        modify(Reopen)
        {
            trigger OnBeforeAction();
            begin
                if (Rec.CurrentCompany = InventoryCompanyName) and (Rec."Sales Order Ref" = '') then begin

                end
                else
                    Error('Please do release action in "%1", Sales Order: "%2"', Rec.CurrentCompany, Rec."Sales Order Ref");
            end;
        }
        modify(CopyDocument)
        {
            trigger OnAfterAction()
            var
                PurchaseLine: Record "Purchase Line";
            begin
                Clear(PurchaseLine);
                PurchaseLine.Get(Rec."Document Type", Rec."No.");
                PayableMgt.PutPayableItem(PurchaseLine);
            end;
        }
    }
    var
        WorkDescription: Text;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

        IsPei: Boolean;
        PayableMgt: Codeunit PayableMgt;

    procedure GetWorkDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Work Description");
        Rec."Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;

    trigger OnAfterGetRecord()
    var
        IsAutomatePurchHeader: Boolean;
        User: Record User;

    begin
        user.Get(Database.UserSecurityId());
        WorkDescription := GetWorkDescription;

        IsAutomatePurchHeader := false;
        if (Rec.CurrentCompany <> InventoryCompanyName) and (Rec."Sales Order Ref" <> '') then
            IsAutomatePurchHeader := true;

        if IsAutomatePurchHeader then
            Currpage.Editable(false);

        if User."Full Name" = 'Pei Xu' then IsPei := true;
        if IsPei then CurrPage.Editable(true);
    end;
}
