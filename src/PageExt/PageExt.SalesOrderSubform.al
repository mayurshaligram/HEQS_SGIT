pageextension 50117 "Sales Order Subform_Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field(NeedAssemble; Rec.NeedAssemble)
            {
                Caption = 'NeedAssemble';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specified whether this sales line needed to be assembled';
                Visible = true;
                Editable = true;

                trigger OnValidate();
                var
                    BOMSalesLine: Record "Sales Line";
                begin
                    if Rec."BOM Item" = true then
                        Error('Please only edit the main item, BOM line is managed by system.');
                    BOMSalesLine.SetRange("Document Type", Rec."Document Type");
                    BOMSalesLine.SetRange("Document No.", Rec."Document No.");
                    BOMSalesLine.SetRange("Main Item Line", Rec."Line No.");
                    if BOMSalesLine.FindSet() then begin
                        BOMSalesLine.NeedAssemble := Rec.NeedAssemble;
                        BOMSalesLine.Modify();
                    end;


                end;
            }
            field(UnitAssembleHour; Rec.UnitAssembleHour)
            {
                Caption = 'Unit Assemble Hour';
                ApplicationArea = Basic, Suite;
                ToolTip = 'THe unit hour for the item';
                Visible = true;
                Editable = true;

                trigger OnValidate();
                begin
                    Rec.AssemblyHour := Rec.UnitAssembleHour * Rec.Quantity;
                end;
            }

            field(AssemblyHour; Rec.AssemblyHour)
            {
                Caption = 'TotalAssemblyHours';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specified how long this sales line needed to be assembled';
                Visible = true;
                Editable = false;
            }

        }
        modify(Quantity)
        {
            trigger OnAfterValidate();
            begin
                Rec.AssemblyHour := Rec.UnitAssembleHour * Rec.Quantity;
            end;
        }
    }

    actions
    {
        addbefore(SelectMultiItems)
        {
            action("Expand BOM")
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Expand BOM';
                Image = NewItem;
                ToolTip = 'View BOM Sales line.';

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update();
                end;
            }
            action("Hide BOM")
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Hide BOM';
                Image = Delete;
                ToolTip = 'Hide BOM Sales line.';

                trigger OnAction()
                begin
                    Rec.SetView('where ("BOM Item" = filter (= false))');
                    CurrPage.Update();
                end;
            }
            action("Quick Fix")
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Quick Fix';
                Image = Delete;
                ToolTip = 'Quick Fix BOM Sales line.';

                trigger OnAction()
                begin
                    Rec.SetView('where ("BOM Item" = filter (= false))');
                    CurrPage.Update();
                end;
            }
        }
    }



    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

    trigger OnOpenPage();
    begin
        if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            Rec.SetView('where ("BOM Item" = filter (= false))');
            CurrPage.Update();
        end;
    end;
}
