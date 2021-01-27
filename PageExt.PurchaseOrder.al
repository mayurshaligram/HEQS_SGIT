pageextension 50102 "Purchase Order_Ext" extends "Purchase Order"
{

    PromotedActionCategories = 'New,Process,Report,Approve,Posting,Prepare,Order,Request Approval,Print/Send,Navigate';
    Caption = 'Purchase Order';
    layout
    {
        addlast(General)
        {
            group("Work Description")
            {
                Caption = 'Work Description';
                // add the same contrain to the PO order like SO
                // But workdescription does not exist in the current context
                // could be possible to 

                // make BLOB to string to display
                // should work in the table ext

                // if fail
                // test string

                field(WorkDescription; rec."WorkDescription")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the products or service being offered.';


                    // trigger OnValidate()
                    // begin
                    //     SetWorkDescription(WorkDescription);
                    // end;
                }
            }
        }
    }
}
