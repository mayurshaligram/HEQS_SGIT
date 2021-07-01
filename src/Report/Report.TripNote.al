report 50103 TripReport
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = 'TripReport.docx';

    dataset
    {
        dataitem(Trip; Trip)
        {
            RequestFilterFields = "No.";

            column(Driver; Driver)
            {

            }
            column(Vehicle; Vehicle)
            {

            }
            column(Delivery_Date; DateText)
            {

            }
            dataitem(Schedule; Schedule)
            {
                DataItemLink = "Trip No." = field("No.");
                // DataItemLinkReference = "Warehouse Activity Header";
                DataItemTableView = SORTING("Trip No.", "Trip Sequece");


                column(Order_No; "Subsidiary Source No.")
                {

                }
                column(Delivery_Items; TempText)
                {

                }
                column(Delivery_Time; "Delivery Time")
                {

                }
                column(Assemble; AssembleText)
                {

                }

                trigger OnAfterGetRecord();
                var
                    CR: Char;

                begin
                    CR := 13;
                    TempText := "Delivery Items".Replace(',', CR);
                    if Assemble then
                        AssembleText := 'Yes'
                    else
                        AssembleText := 'No';
                end;
            }


            trigger OnAfterGetRecord()
            begin
                DateText := format("Delivery Date", 0, '<Year4> <Month Text> <Day,2>');
            end;
        }
    }

    requestpage
    {
        // layout
        // {
        //     area(Content)
        //     {
        //         group(Options)
        //         {
        //             Caption = 'Options';
        //             field(Driver; "No.")
        //             {
        //                 ApplicationArea = Basic, Suite;
        //                 Caption = 'Posting Date';
        //                 ToolTip = 'Specifies the posting date for the invoice(s) that the batch job creates. This field must be filled in.';
        //             }
        //         }
        //     }
        // }

        // actions
        // {
        //     area(processing)
        //     {
        //         action(ActionName)
        //         {
        //             ApplicationArea = All;

        //         }
        //     }
        // }
    }



    var
        DateText: Text;
        TempText: Text;
        AssembleText: Text;
}