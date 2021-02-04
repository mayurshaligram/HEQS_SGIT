pageextension 50102 "workdescription" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            group("Work Description")
            {
                Caption = 'Work Description';
                field(WorkDescription; rec."WorkDescription")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the products or service being offered.';
                }
            }
        }
    }
}
