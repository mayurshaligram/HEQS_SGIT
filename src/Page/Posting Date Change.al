// page 50140 PostingDateChange
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = Administration;
//     //SourceTable = TableName;

//     layout
//     {
//         area(Content)
//         {
//             group(GroupName)
//             {
//                 field("Posting Date"; PostingDate)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Posting Date';
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(Post)
//             {
//                 ApplicationArea = Basic, Suite;
//                 Image = PostOrder;
//                 trigger OnAction()
//                 var
//                     SalesLine: Record "Sales Line";
//                     WarehouseRequest: Record "Warehouse Request";
//                     ReleaseSalesDoc: Codeunit "Release Sales Document";
//                     InventorySalesOrder: Record "Sales Header";
//                     SessionId: Integer;
//                     PurchaseHeader: Record "Purchase Header";
//                     PurchaseLine: Record "Purchase Line";
//                     PostedSalesInvoiceHeader: Record "Sales Invoice Header";
//                     NoSeries: Record "No. Series";
//                     NoSeriesMgt: Codeunit NoSeriesManagement;
//                     RetailSalesLine: Record "Sales Line";
//                     VendorInvoiceNo: Code[20];
//                     TempText: Text[20];
//                     TempNum: Text[20];
//                     TempInteger: Integer;
//                     TempSalesLine: Record "Sales Line";
//                     TempItem: Record Item;
//                     IsValideIC: Boolean;
//                     SalesTruthMgt: Codeunit "Sales Truth Mgt";
//                     Text1: Label 'Please only post invoice in the retail company %1';
//                     PostedPurchaseInvoice: Record "Purch. Inv. Header";
//                     // Only the Sales Header associated with more then one inventory item sale line could be pass
//                     Shipped: Boolean;
//                     SalesHeader: Record "Sales Header";
//                 begin
//                     CurrPage.SetSelectionFilter(SalesHeader);
//                     if SalesHeader.FindSet() then
//                         repeat
//                             IF PostingDate <> 0D then begin
//                                 SalesHeader."Posting Date" := PostingDate;
//                                 SalesHeader.Modify();
//                             end;
//                             SalesTruthMgt.AutoPost(SalesHeader);
//                         until SalesHeader.Next() = 0;
//                     CurrPage.Close();
//                 end;


//             }
//         }
//     }
//     trigger OnInit()
//     begin
//         PostingDate := WorkDate();
//     end;


//     // trigger OnClosePage()
//     // var
//     //     SalesLine: Record "Sales Line";
//     //     WarehouseRequest: Record "Warehouse Request";
//     //     ReleaseSalesDoc: Codeunit "Release Sales Document";
//     //     InventorySalesOrder: Record "Sales Header";
//     //     SessionId: Integer;
//     //     PurchaseHeader: Record "Purchase Header";
//     //     PurchaseLine: Record "Purchase Line";
//     //     PostedSalesInvoiceHeader: Record "Sales Invoice Header";
//     //     NoSeries: Record "No. Series";
//     //     NoSeriesMgt: Codeunit NoSeriesManagement;
//     //     RetailSalesLine: Record "Sales Line";
//     //     VendorInvoiceNo: Code[20];
//     //     TempText: Text[20];
//     //     TempNum: Text[20];
//     //     TempInteger: Integer;
//     //     TempSalesLine: Record "Sales Line";
//     //     TempItem: Record Item;
//     //     IsValideIC: Boolean;
//     //     SalesTruthMgt: Codeunit "Sales Truth Mgt";
//     //     Text1: Label 'Please only post invoice in the retail company %1';
//     //     PostedPurchaseInvoice: Record "Purch. Inv. Header";
//     //     // Only the Sales Header associated with more then one inventory item sale line could be pass
//     //     Shipped: Boolean;
//     //     SalesHeader: Record "Sales Header";
//     // begin
//     //     CurrPage.SetSelectionFilter(SalesHeader);
//     //     if SalesHeader.FindSet() then
//     //         repeat
//     //             IF PostingDate <> 0D then
//     //                 SalesHeader."Posting Date" := PostingDate;
//     //             SalesHeader.Modify();
//     //             SalesTruthMgt.AutoPost(SalesHeader);
//     //         until SalesHeader.Next() = 0;
//     // end;

//     //trigger OnAfterGetCurrRecord()

//     var
//         PostingDate: Date;
//     //Salesorderlist:  "Sales Order List";
// }