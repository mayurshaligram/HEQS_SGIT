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
                    Editable = false;
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
                PurchaseLine: Record "Purchase Line";
                WarehouseRequest: Record "Warehouse Request";
                TempInteger: Integer;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
            begin
                // Recreate The Purchase Line to Solve the BOM Carry Problem
                Rec.Status := Rec.Status::Open;
                Rec.Modify();
                Rec.RecreatePurchLines(Rec."Buy-from Vendor Name");
                Rec.Status := Rec.Status::Released;
                Rec.Validate(Status, Rec.Status::Released);
                Rec.Modify();
                // What is the Difference Between the System One BOM and Customer BOM TODO

                // No Warehouse Line Created
                PurchaseLine.Reset();
                PurchaseLine.SetRange("Document No.", Rec."No.");
                if PurchaseLine.FindSet() then
                    repeat
                        PurchaseLine."Location Code" := 'NSW';
                        PUrchaseLine.Modify();
                    until PurchaseLine.Next() = 0;
                // PurchaseLine Code is Zero
                TempInteger := 39;
                if WarehouseRequest.get(WarehouseRequest.Type::Inbound, PurchaseLine."Location Code", TempInteger, WarehouseRequest."Source Subtype"::"1", Rec."No.") then begin
                    WarehouseRequest."Source Type" := 39;
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Modify();
                end
                else begin
                    WarehouseRequest.Init();
                    WarehouseRequest.Type := WarehouseRequest.Type::Inbound;
                    WarehouseRequest."Location Code" := PurchaseLine."Location Code";
                    WarehouseRequest."Source Subtype" := TempInteger;
                    WarehouseRequest."Source No." := Rec."No.";
                    WarehouseRequest."Source Type" := 39;
                    WarehouseRequest."Document Status" := WarehouseRequest."Document Status"::Released;
                    Warehouserequest."Shipment Date" := DT2Date(system.CurrentDateTime);
                    WarehouseRequest.Insert();
                end;
            end;
            //    
        }
        modify(Release)
        {
            trigger OnBeforeAction();
            begin
                if (Rec.CurrentCompany = InventoryCompanyName) and (Rec."Sales Order Ref" = '') then begin

                end
                else
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
    }
    var
        WorkDescription: Text;
        InventoryCompanyName: Label 'HEQS International Pty Ltd';

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
    begin
        WorkDescription := GetWorkDescription;

        IsAutomatePurchHeader := false;
        if (Rec.CurrentCompany <> InventoryCompanyName) and (Rec."Sales Order Ref" <> '') then
            IsAutomatePurchHeader := true;

        if IsAutomatePurchHeader then
            Currpage.Editable(false);
    end;
}
