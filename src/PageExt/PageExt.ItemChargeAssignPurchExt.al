pageextension 50108 "ItemChargeAssign(Purch)_Ext" extends "Item Charge Assignment (Purch)"
{
    Editable = true;
    // layout
    // {
    //     modify("Qty. to Assign")
    //     {
    //         trigger OnAfterValidate()
    //         begin
    //             Message('OnAfterValidate');
    //         end;
    //     }
    // }
    actions
    {
        modify(SuggestItemChargeAssignment)
        {
            trigger OnAfterAction()
            var
                PurchaseLine2: Record "Purchase Line";
                ItemChargeAssign: Record "Item Charge Assignment (Purch)";
            begin
                PurchaseLine2.Reset();
                PurchaseLine2.Get(Rec."Document Type", Rec."Document No.", Rec."Document Line No.");
                ItemChargeAssign.Reset();
                ItemChargeAssign.CopyFilters(Rec);
                if ItemChargeAssign.FindSet() then
                    repeat
                        ItemChargeAssign."Amount to Assign" := ItemChargeAssign."Qty. to Assign" * PurchaseLine2."Unit Cost";
                        ItemChargeAssign.Modify()
                    until ItemChargeAssign.Next() = 0;
            end;
        }
        addafter(GetReceiptLines)
        {
            action(GetReleasedPurchaseLines)
            {
                AccessByPermission = TableData "Purch. Rcpt. Header" = R;
                ApplicationArea = ItemCharges;
                Caption = 'Get &Released Purchase Lines';
                Image = Receipt;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Select a posted purchase receipt for the item that you want to assign the item charge to, for example, if you received an invoice for the item charge after you posted the original purchase receipt.';

                trigger OnAction()
                var
                    // Variable From Page Object Integration
                    // Data Validation And Changing
                    PurchLine2: Record "Purchase Line";
                    // SetTable View 
                    ReleasedPurchLine: Record "Purchase Line";
                    // Released Header
                    ReleasedPurchHeader: Record "Purchase Header";

                    ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
                    PurchLines: Page "Purch Order Lines";
                begin
                    ReleasedPurchLine.FilterGroup(2);
                    ReleasedPurchLine.SetFilter("No.", '<>%1', '');
                    ReleasedPurchLine.SetFilter("Document Type", Format(ReleasedPurchLine."Document Type"::Order));
                    ReleasedPurchLine.SetFilter(Quantity, '<>0');
                    ReleasedPurchLine.Type := ReleasedPurchLine.Type::Item;

                    ReleasedPurchLine.FilterGroup(0);

                    PurchLines.SetTableView(ReleasedPurchLine);
                    // if ItemChargeAssgntPurch.FindLast then
                    //     ReceiptLines.Initialize(ItemChargeAssgntPurch, PurchLine2."Unit Cost")
                    // else
                    //     ReceiptLines.Initialize(Rec, PurchLine2."Unit Cost");
                    PurchLines.Initialize(Rec, Rec."Unit Cost");
                    PurchLines.LookupMode(true);
                    PurchLines.RunModal;
                end;
            }
        }

    }
    // trigger OnClosePage()
    // var
    //     PurchaseLine2: Record "Purchase Line";
    //     ItemChargeAssign: Record "Item Charge Assignment (Purch)";
    // begin
    //     PurchaseLine2.Reset();
    //     PurchaseLine2.Get(Rec."Document Type", Rec."Document No.", Rec."Document Line No.");
    //     ItemChargeAssign.Reset();
    //     ItemChargeAssign.CopyFilters(Rec);
    //     if ItemChargeAssign.FindSet() then
    //         repeat
    //             ItemChargeAssign."Amount to Assign" := ItemChargeAssign."Qty. to Assign" * PurchaseLine2."Unit Cost";
    //             ItemChargeAssign.Modify()
    //         until ItemChargeAssign.Next() = 0;
    // end;
}