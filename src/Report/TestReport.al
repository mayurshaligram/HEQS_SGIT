// report 50145 UpdateSalesBatch
// {
//     UsageCategory = Administration;
//     ApplicationArea = All;

//     dataset
//     {
//         dataitem("Sales Header"; "Sales Header")
//         {
//             column(External_Document_No_; "External Document No.")
//             {

//             }
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(Content)
//             {
//                 group(GroupName)
//                 {

//                 }
//             }
//         }

//         actions
//         {
//             area(processing)
//             {
//                 action(ActionName)
//                 {
//                     ApplicationArea = All;

//                 }
//             }
//         }
//     }
//     trigger OnInitReport()
//     var
//         SalesHeader: Record 36;
//     begin
//         SalesHeader.Reset();
//         if SalesHeader.CurrentCompany = 'HEQS International Pty Ltd' then begin
//             SalesHeader.SetRange("No.", 'INT105070');
//             if SalesHeader.FindFirst() then begin
//                 SalesHeader."External Document No." := 'FPO001036';
//                 SalesHeader.Modify();
//             end;
//         end;
//     end;

//     var
//         myInt: Integer;
// }