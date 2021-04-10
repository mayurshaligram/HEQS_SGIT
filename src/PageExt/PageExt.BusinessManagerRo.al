pageextension 50148 "Bus.Manager Role Center_Ext" extends "Business Manager Role Center"
{
    actions
    {
        addBefore(SetupAndExtensions)
        {
            group("Schedule")
            {
                action("Scheduling")
                {
                    ApplicationArea = Suite;
                    Caption = 'Scheduling';
                    Image = PostedMemo;
                    RunObject = Page Schedule;
                    ToolTip = 'Scheduling the Sales Order.';
                }
            }
        }
    }
}