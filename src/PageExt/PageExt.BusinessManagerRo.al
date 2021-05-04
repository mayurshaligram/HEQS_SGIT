pageextension 50120 "Bus.Manager Role Center_Ext" extends "Business Manager Role Center"
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
                action("Archive Scheduling")
                {
                    ApplicationArea = Suite;
                    Caption = 'Archive Scheduling';
                    Image = PostedMemo;
                    RunObject = Page "Archive Schedule";
                    ToolTip = 'See Previous Archive Sales Order Scheduling.';
                }
                action("Zone")
                {
                    ApplicationArea = Suite;
                    Caption = 'Zone';
                    Image = PostedMemo;
                    RunObject = Page "Zone Lookup";
                    ToolTip = 'Price Zone';
                }
                action("Vehicle")
                {
                    ApplicationArea = Suite;
                    Caption = 'Vehicle';
                    Image = PostedMemo;
                    RunObject = Page "Vehicle Lookup";
                    ToolTip = 'Vehicle Zone';
                }
                action("Driver")
                {
                    ApplicationArea = Suite;
                    Caption = 'Driver';
                    Image = PostedMemo;
                    RunObject = Page "Driver Lookup";
                    ToolTip = 'Driver';
                }
                action("Payable")
                {
                    ApplicationArea = Suite;
                    Caption = 'Payable';
                    Image = PostedMemo;
                    RunObject = page Payable;
                    ToolTip = 'Payable';
                }
            }
        }
    }
}