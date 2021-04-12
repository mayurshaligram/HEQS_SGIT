page 50106 "Zone Lookup"
{
    Caption = 'Zones';
    Editable = true;
    PageType = List;
    SourceTable = ZoneTable;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'Zone, ZoneTable';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order Price"; Rec."Order Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Order Price for Zone';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code';
                }
                field("Delivery Fee"; Rec."Delivery Fee")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the basic delivery fee for the Zone';

                }
                field(L1; Rec.L1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price for L1';
                }
                field(L2; Rec.L2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price for L2';
                }
                field(L3; Rec.L3)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price for L3';
                }
            }

        }

    }

    actions
    {
        area(navigation)
        {
            action(ItemList)
            {
                ApplicationArea = All;
                Caption = 'Advanced View';
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the Items page showing all possible columns.';

                trigger OnAction()
                var
                    ItemList: Page "Item List";
                begin
                    ItemList.SetTableView(Rec);
                    ItemList.SetRecord(Rec);
                    ItemList.LookupMode := true;

                    Commit();
                    if ItemList.RunModal = ACTION::LookupOK then begin
                        ItemList.GetRecord(Rec);
                        CurrPage.Close;
                    end;
                end;
            }
        }
    }
}

