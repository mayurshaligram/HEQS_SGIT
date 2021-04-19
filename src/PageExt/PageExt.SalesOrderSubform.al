pageextension 50118 "Sales Order Subform_Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("No.")
        {
            field(Sequence; Rec.Sequence)
            {
                Caption = 'Sequence';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specified the sequnce view of the line';
                Visible = false;
                Editable = true;
            }
        }
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
        modify("Line No.")
        {
            Editable = false;
        }
        modify("Line Amount")
        {
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate();
            begin
                CurrPage.Update();
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
        }
    }



    var
        SalesTruthMgt: Codeunit "Sales Truth Mgt";

        Sequence: Integer;

    trigger OnOpenPage();
    var
        Text1: Label 'Please release the current Sales Order in at "%1"';
        Text2: Label 'Please provide the location code for the Sales Line';
        Text3: Label 'Please provide the location code for the Sales Order';
        Text4: Label 'There BOM component Inconsistency for the Sales Line, Please report to administrator.';
        SalesLine: Record "Sales Line";
        MainSalesLine: Record "Sales Line";
        TempLineNo: Integer;
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        BOMSalesLine: Record "Sales Line";
        CorrectMainSalesLine: Record "Sales Line";
    begin
        if Rec.CurrentCompany <> SalesTruthMgt.InventoryCompany() then begin
            Rec.SetView('where ("BOM Item" = filter (= false))');
            CurrPage.Update();
        end;
    end;

}
