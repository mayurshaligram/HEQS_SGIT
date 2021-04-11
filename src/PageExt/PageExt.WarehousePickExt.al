pageextension 50103 "Warehouse Pick_Ext" extends "Warehouse Pick"
{
    Caption = 'Warehouse Pick_Ext';
    layout
    {
        addlast(General)
        {
            field("New Sorting Method"; Rec."New Sorting Method")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the method by which the lines are sorted on the warehouse header, such as Item or Document.';
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("Sorting Field One"; Rec."Sorting Field 1")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the method by which the lines are sorted on the warehouse header, such as Item or Document.';
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("Sorting Field Two"; Rec."Sorting Field 2")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the method by which the lines are sorted on the warehouse header, such as Item or Document.';
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("Sorting Field Three"; Rec."Sorting Field 3")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the method by which the lines are sorted on the warehouse header, such as Item or Document.';
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }

        }

    }
    actions
    {
        addafter("&Print")
        {
            action("Export to Excek")
            {
                Caption = 'Export to Excel';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Export;

                trigger OnAction()
                var
                begin
                    ExportCustLedgerEntries(Rec);
                    // // message('From the Excel Button');
                end;
            }
        }

    }
    local procedure ExportCustLedgerEntries(var WarehousePick: Record "Warehouse Activity Header")
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        WarehousePickLbl: Label 'Warehouse Pick';
        ExcelFileName: Label 'WarehousePick_%1_%2';
        WarehouseActivityLine: Record "Warehouse Activity Line";
        counter: Dictionary of [Code[20], Integer];
    begin
        WarehouseActivityLine.SetRange("No.", WarehousePick."No.");
        if WarehouseActivityLine.FindSet() then
            repeat
                if counter.ContainsKey(WarehouseActivityLine."Item No.") then
                    counter.Set(WarehouseActivityLine."Item No.", counter.Get(WarehouseActivityLine."Item No.") + WarehouseActivityLine.Quantity)
                else
                    counter.add(WarehouseActivityLine."Item No.", 1);
            until WarehouseActivityLine.Next() = 0;
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Picking List', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetRange("No.", WarehousePick."No.");
        WarehouseActivityLine.SetCurrentKey("Pick-up Item", "Zone Code", "Bin Code", "Item No.");
        WarehouseActivityLine.SetAscending("Pick-up Item", false);
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Source Document"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Source No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Pick-up Item"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Total Pick-up Item"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Destination Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Destination No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Due Date"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Action Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Item No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption(Description), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Variant Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Zone Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Bin Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Qty. Outstanding (Base)"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Qty. to Handle"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Unit of Measure Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(WarehouseActivityLine.FieldCaption("Qty. Handled"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        if WarehouseActivityLine.FindSet() then
            repeat
                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Source Document", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Source No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Pick-up Item", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(counter.Get(WarehouseActivityLine."Item No.") / 2, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Destination Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Destination No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Due Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Action Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Item No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Variant Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Zone Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Bin Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Qty. Outstanding (Base)", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Qty. to Handle", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Unit of Measure Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(WarehouseActivityLine."Qty. Handled", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            until WarehouseActivityLine.Next() = 0;

        TempExcelBuffer.CreateNewBook(WarehousePickLbl);
        TempExcelBuffer.WriteSheet(WarehousePickLbl, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(StrSubstNo(ExcelFileName, CurrentDateTime, UserId));
        TempExcelBuffer.OpenExcel();
    end;

    [ServiceEnabled]
    procedure PingPong(): Text
    begin
        exit('Pong');
    end;
}

