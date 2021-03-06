#pragma implicitwith disable
page 50103 "Purch Order Lines"
{
    Caption = 'Released Purchase Order Lines';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Line';
    SourceTable = "Purchase Line";
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Purchase Header"."No." where(Status = filter(Released));
                    HideValue = DocumentNoHideValue;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the number of the related document.';

                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the vendor who delivered the items.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line type.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of a list of purchases that were posted.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the location where you want the items to be placed when they are received.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units were posted as received or received and invoiced.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost of one unit of the selected item or resource.';
                    Visible = false;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost, in LCY, of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                    Visible = false;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as invoiced.';
                    Visible = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                    Visible = false;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                    Visible = false;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the related production order.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity per unit of measure of the item that was received.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        PurchRcptHeader: Record "Purch. Rcpt. Header";
                    begin
                        PurchRcptHeader.Get(Rec."Document No.");
                        PAGE.Run(PAGE::"Posted Purchase Receipt", PurchRcptHeader);
                    end;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    // trigger OnAction()
                    // begin
                    //     ShowItemTrackingLines;
                    // end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DocumentNoHideValue := false;
        DocumentNoOnFormat;
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnOpenPage()
    var
        ReleasedPurchaseHeader: Record "Purchase Header";
    begin
        Rec.FilterGroup(2);
        ReleasedPurchaseHeader.Reset();
        ReleasedPurchaseHeader.SetCurrentKey(Status);
        ReleasedPurchaseHeader.SetRange(Status, ReleasedPurchaseHeader.Status::Released);
        ReleasedPurchaseHeader.SetRange(Status, ReleasedPurchaseHeader.Status::Released);
        if ReleasedPurchaseHeader.Find('-') then
            repeat

                Rec.SetCurrentKey("Document No.");
                Rec.SetRange("Document No.", ReleasedPurchaseHeader."No.");
                if Rec.Find('-') then
                    repeat
                        Rec.Mark(True);
                    until Rec.Next = 0;
            until ReleasedPurchaseHeader.Next() = 0;
        Rec.SetRange("Document No.");
        Rec.MarkedOnly(True);


        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetFilter(Quantity, '<>0');
        // SetRange(Correction, false);
        Rec.FilterGroup(0);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush;
    end;

    var
        FromPurchRcptLine: Record "Purchase Line";
        TempPurchRcptLine: Record "Purchase Line" temporary;
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        UnitCost: Decimal;
        [InDataSet]
        DocumentNoHideValue: Boolean;

    procedure Initialize(NewItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; NewUnitCost: Decimal)
    begin
        ItemChargeAssgntPurch := NewItemChargeAssgntPurch;
        UnitCost := NewUnitCost;
        OnAfterInitialize(ItemChargeAssgntPurch, UnitCost);
    end;

    local procedure IsFirstDocLine(): Boolean
    var
        PurchRcptLine: Record "Purchase Line";
    begin
        TempPurchRcptLine.Reset();
        TempPurchRcptLine.CopyFilters(Rec);
        TempPurchRcptLine.SetRange("Document No.", Rec."Document No.");
        if not TempPurchRcptLine.FindFirst then begin
            Rec.FilterGroup(2);
            PurchRcptLine.CopyFilters(Rec);
            Rec.FilterGroup(0);
            PurchRcptLine.SetRange("Document No.", Rec."Document No.");
            if not PurchRcptLine.FindFirst then
                exit(false);
            TempPurchRcptLine := PurchRcptLine;
            TempPurchRcptLine.Insert();
        end;
        if Rec."Line No." = TempPurchRcptLine."Line No." then
            exit(true);
    end;

    local procedure LookupOKOnPush()
    var
        // NextLine Provider
        ItemChargeAssgntPurch3: Record "Item Charge Assignment (Purch)";
        LocalFromPurchRcpLine: Record "Purch. Rcpt. Line";
        ItemChargeAssgntPurch2: Record "Item Charge Assignment (Purch)";
        NextLine: Integer;
    begin
        ItemChargeAssgntPurch3.Reset();
        if ItemChargeAssgntPurch3.FindLast() then;
        FromPurchRcptLine.Copy(Rec);
        CurrPage.SetSelectionFilter(FromPurchRcptLine);
        if FromPurchRcptLine.FindFirst then begin
            ItemChargeAssgntPurch."Unit Cost" := UnitCost;
            NextLine := ItemChargeAssgntPurch3."Line No." + 10000;
            ItemChargeAssgntPurch2.SetRange("Document Type", ItemChargeAssgntPurch."Document Type");
            ItemChargeAssgntPurch2.SetRange("Document No.", Rec."Document No.");
            ItemChargeAssgntPurch2.SetRange("Document Line No.", ItemChargeAssgntPurch."Document Line No.");
            ItemChargeAssgntPurch2.SetRange(
              "Applies-to Doc. Type", ItemChargeAssgntPurch2."Applies-to Doc. Type"::"Order");
            repeat
                ItemChargeAssgntPurch2.SetRange("Applies-to Doc. No.", FromPurchRcptLine."Document No.");
                ItemChargeAssgntPurch2.SetRange("Applies-to Doc. Line No.", FromPurchRcptLine."Line No.");
                if not ItemChargeAssgntPurch2.FindFirst() then
                    AssignItemChargePurch.InsertItemChargeAssignment(
                        ItemChargeAssgntPurch, FromPurchRcptLine."Document Type",
                        FromPurchRcptLine."Document No.", FromPurchRcptLine."Line No.",
                        FromPurchRcptLine."No.", FromPurchRcptLine.Description, NextLine);
            until FromPurchRcptLine.Next() = 0;
        end;
    end;

    local procedure DocumentNoOnFormat()
    begin
        if not IsFirstDocLine then
            DocumentNoHideValue := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitialize(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; var UnitCost: Decimal)
    begin
    end;
}

#pragma implicitwith restore

