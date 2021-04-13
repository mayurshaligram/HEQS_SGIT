page 50109 "DevPage"
{
    Caption = 'DevPage';
    Editable = true;
    PageType = List;
    SourceTable = Driver;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'DevPage';
    Permissions = TableData 7312 = rimd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No for the Driver';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the First Name';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Middle Name';

                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last name';
                }
            }
        }

    }
    trigger OnOpenPage();
    var
        WarehouseEntry: Record "Warehouse Entry";
    begin
        // Delete all the WarehouseEntry in the Batch NSWWIJ
        WarehouseEntry.Reset();
        if WarehouseEntry.FindSet() then
            repeat
                WarehouseEntry.Delete();
            until WarehouseEntry.Next() = 0;
    end;
}

