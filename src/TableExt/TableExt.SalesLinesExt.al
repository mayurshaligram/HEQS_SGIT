tableextension 50103 "Sales line_Ext" extends "Sales Line"
{
    fields
    {
        modify("Requested Delivery Date")
        {
            trigger OnAfterValidate();
            begin
                Rec.Token := true;
            end;
        }
        field(50100; "BOM Item"; Boolean)
        {
            Caption = 'IsBOM';
            Description = 'Indicate the Line is Sales Item or Inventory BOM';
            Editable = false;
        }
        field(50101; "Package Tracking ID"; Code[20])
        {
            Description = 'Package Tracking ID for this sales line';
            Editable = false;
        }
        field(50102; "Car ID"; Code[20])
        {
            Description = 'Car ID for Delivery';
            Editable = false;
        }
        field(50103; NeedAssemble; Boolean)
        {
            Description = 'The Line Need Assemble.';
            Editable = true;
        }
        field(50104; AssemblyHour; Decimal)
        {
            Description = 'Assembly Hour';
            Editable = true;
        }
        field(50105; UnitAssembleHour; Decimal)
        {
            Description = 'The Assemble hour for just one item';
            Editable = true;
        }
        field(50106; "Main Item Line"; Integer)
        {
            Description = 'Main Item Line';
            Editable = false;
        }
        field(50107; Token; Boolean)
        {
            Description = 'Developing Internal Only';
            Editable = false;
        }
        field(50108; Sequence; Integer)
        {
            Description = 'Sequence the view the line';
            Editable = true;
        }
    }
    trigger OnBeforeInsert();
    var
        LastSalesLine: Record "Sales Line";
        SalesLine: RecordRef;
        MyFieldRef: FieldRef;
        TempLine: Integer;
    begin
        if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            LastSalesLine.Reset();
            LastSalesLine.SetRange("Document Type", Rec."Document Type");
            LastSalesLine.SetRange("Document No.", Rec."Document No.");
            if LastSalesLine.FindLast() then
                Rec."Line No." := LastSalesLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;

    trigger OnAfterInsert();
    var
        Item: Record Item;
        IsItemLine: Boolean;
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            if Item.Get(Rec."No.") then
                if (Item.Type = Item.Type::Inventory) then IsItemLine := true;
        end;

        if (Rec.CurrentCompany <> 'HEQS International Pty Ltd') and IsItemLine then begin
            if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = rec."Document Type"::"Return Order") then
                onInsertPurchICBOM(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure onInsertPurchICBOM(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnBeforeModify();
    begin
        if Rec.Type <> xRec.Type then begin
            Error('Please delete this line, and recreat the different line');
        end;
        if Rec.Token = false then begin
            if Rec.Type = Rec.Type::Item then
                if Rec."BOM Item" = true then
                    Error('Please Only Edit Main Item, Bom is managed by system only')
        end
        else
            Rec.Token := false;
    end;

    trigger OnAfterModify();
    var
        Item: Record Item;
        IsItemLine: Boolean;
        LastSalesLine: Record "Sales Line";
        LastLineNo: Integer;
        NewSalesLine: Record "Sales Line";
    begin
        // if (Rec."No." <> xRec."No.") and (Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany()) then begin
        //     Message('No has changed.');
        //     LastSalesLine.Reset();
        //     LastSalesLine.SetRange("Document Type", LastSalesLine."Document Type"::Order);
        //     LastSalesLine.SetRange("Document No.", Rec."Document No.");
        //     if LastSalesLine.FindLast() then
        //         LastLineNo := LastSalesLine."Line No.";
        //     NewSalesLine := Rec;
        //     SalesTruthMgt.DeleteBOMSalesLine(Rec);

        //     // NewSalesLine."Line No." := LastLineNo + 10000;
        //     // NewSalesLine.Insert(true);
        // end
        // else begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;
        end;

        if (Rec."Promised Delivery Date" <> xRec."Promised Delivery Date") then IsItemLine := true;

        if (Rec.CurrentCompany <> 'HEQS International Pty Ltd') and IsItemLine then begin
            if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = rec."Document Type"::"Return Order") then
                OnUpdatePurchICBOM(Rec);
        end;

    end;

    local procedure ChangeLineItemNo(var SalesLine: Record "Sales Line");
    var
        PreviousLine: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
    begin
        if SalesLine.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            NewSalesLine := SalesLine;
            PreviousLine := SalesLine;
            if PreviousLine.Get(PreviousLine."Document Type", PreviousLine."Document No.", PreviousLine."Line No.") then begin
                SalesLine.Delete(true);
                NewSalesLine.Insert(true);
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdatePurchICBOM(var SalesLine: Record "Sales Line");
    begin
    end;


    // Could be refactorize to CodeUnit
    [IntegrationEvent(false, false)]
    local procedure OnDeleteBOMPurchIC(var SalesLine: Record "Sales Line");
    begin
    end;

    trigger OnBeforeDelete();
    var
        User: Record User;
    begin
        user.Get(Database.UserSecurityId());
        if User."Full Name" <> 'Pei Xu' then begin
            if (Rec.Token = false) and (Rec.CurrentCompany <> InventoryCompanyName) then
                if Rec.Type = Rec.Type::Item then
                    if Rec."BOM Item" = true then
                        Error('Please Only Edit Main Item, Bom is managed by system only');
            Rec.Token := false;
        end;
    end;

    trigger OnAfterDelete();
    var
        FromSO: Record "Sales Header";
        PO: Record "Purchase Header";
        PLrec: Record "Purchase Line";
        ISLrec: Record "Sales Line";
        ISOrec: Record "Sales Header";
        temp: text[20];

        Item: Record Item;
        IsItemLine: Boolean;
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
    begin
        IsItemLine := false;

        if (Rec.Type = Rec.Type::Item) then begin
            Item.Get(Rec."No.");
            if (Item.Type = Item.Type::Inventory) then IsItemLine := true;

            if (Rec."BOM Item" = false) and (IsItemLine = true) and (Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany()) then
                if (Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = rec."Document Type"::"Return Order") then
                    OnDeleteBOMPurchIC(Rec);
            // if (rec.CurrentCompany <> 'HEQS International Pty Ltd') and (rec.Type = rec.Type::Item) then begin
            //     FromSO.Get(Rec."Document Type", Rec."Document No.");
            //     PO.Get(Rec."Document Type", FromSO."Automate Purch.Doc No.");
            //     PLrec.get(rec."Document Type", PO."NO.", rec."Line No.");
            //     PLrec.Delete();
            //     // ISO line
            //     ISLrec.ChangeCompany('HEQS International Pty Ltd');
            //     ISOrec.ChangeCompany('HEQS International Pty Ltd');
            //     ISOrec.SetCurrentKey("External Document No.");
            //     ISORec.SetRange("External Document No.", PO."No.");
            //     if (ISORec.findset) then
            //         repeat
            //             ISLrec.get(rec."Document Type", ISOrec."No.", rec."Line No.");
            //             ISLrec.Delete();
            //         until (ISORec.next() = 0);
            // end;
        end;


    end;

    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";
        InventoryCompanyName: Label 'HEQS International Pty Ltd';
        Text003: Label 'There is not enough space to explode the BOM.';
        ToSalesLine: Record "Sales Line";
        FromBOMComp: Record "BOM Component";
        SalesHeader: Record "Sales Header";
        ItemTranslation: Record "Item Translation";
        Item: Record Item;
        Resource: Record Resource;
        UOMMgt: Codeunit "Unit of Measure Management";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        BOMItemNo: Code[20];
        LineSpacing: Integer;
        NextLineNo: Integer;
        NoOfBOMComp: Integer;
        Selection: Integer;

}

