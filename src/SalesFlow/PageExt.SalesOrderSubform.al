pageextension 50130 "Sales Order Subform_Ext" extends "Sales Order Subform"
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
}
