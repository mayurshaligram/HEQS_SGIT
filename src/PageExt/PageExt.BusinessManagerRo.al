pageextension 50120 "Bus.Manager Role Center_Ext" extends "Business Manager Role Center"
{
    actions
    {
        addBefore(SetupAndExtensions)
        {
            group("Schedule")
            {
                action("NSW Schedule")
                {
                    ApplicationArea = Suite;
                    Caption = 'NSW';
                    Image = PostedMemo;
                    RunObject = Page "Schedule List";
                    RunPageLink = "From Location Code" = CONST('NSW');
                    ToolTip = 'From NSW Scheduling the Sales Order, Transfer Order, Sales Return Order ';
                }
                action("VIC Schedule")
                {
                    ApplicationArea = Suite;
                    Caption = 'VIC';
                    Image = PostedMemo;
                    RunObject = Page "Schedule List";
                    RunPageLink = "From Location Code" = CONST('VIC');
                    ToolTip = 'From VIC Scheduling the Sales Order, Transfer Order, Sales Return Order.';
                }
                action("QLD Schedule")
                {
                    ApplicationArea = Suite;
                    Caption = 'QLD';
                    Image = PostedMemo;
                    RunObject = Page "Schedule List";
                    RunPageLink = "From Location Code" = const('QLD');
                    ToolTip = 'From QLD Scheduling the Sales Order, Transfer Order, Sales Return Order.';
                }
                action("Trip")
                {
                    ApplicationArea = Suite;
                    Caption = 'Trip Scheduling';
                    Image = PostedMemo;
                    RunObject = Page "Trip List";
                    ToolTip = 'Scheduled Trip.';
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
                action("Scheduling(Deprecated)")
                {
                    ApplicationArea = Suite;
                    Caption = 'Scheduling(Deprecated)';
                    Image = ServiceHours;
                    RunObject = page Schedule;
                    ToolTip = 'Deprecated Section will be deleted in the next update, please use NSW, QLD, VIC';
                }
                action("Archive Scheduling(Deprecated")
                {
                    ApplicationArea = Suite;
                    Caption = 'Archive Scheduling(Deprecated)';
                    Image = Archive;
                    RunObject = page "Archive Schedule";
                    ToolTip = 'Deprecated Section will be deleted in the next update, please use NSW, QLD, VIC';
                }
            }
        }
    }
}