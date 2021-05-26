// reportextension 50100 "StandardSalesOrderConf.Ext" extends "Standard Sales - Order Conf."
// {
//     dataset
//     {
//         add(Header)
//         {
//             column(Your_Reference; "Your Reference")
//             {
//             }
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             addafter(LogInteraction)
//             {
//                 field(Your_Reference; Header."Your Reference")
//                 {
//                     ApplicationArea = Assembly;
//                     Caption = 'Nima kai xin jiu hao';
//                     ToolTip = 'Specifies if you want the report to include information about components that were used in linked assembly orders that supplied the item(s) being sold. (Only possible for RDLC report layout.)';
//                 }
//             }
//         }
//     }
// }