pageextension 50102 "Purchase Order_Ext" extends "Purchase Order"
{
    Editable = false;
    layout
    {
        addlast(General)
        {
            group("Work Description")
            {
                Caption = 'Work Description';
                field(WorkDescription; WorkDescription)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }
    var
        WorkDescription: Text;

    procedure GetWorkDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Work Description");
        Rec."Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;

    trigger OnAfterGetRecord()
    begin
        WorkDescription := GetWorkDescription;
    end;
}
