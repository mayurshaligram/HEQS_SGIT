query 50100 "Sample Query"
{
    QueryType = Normal;
    Caption = 'Sales Overview';

    elements
    {
        dataitem(Sales_Header; "Sales Header")
        {
            column(Promised_Delivery_Date; "Promised Delivery Date")
            {

            }
            column(Ship_to_Code; "Ship-to Code")
            {

            }
            column(Sell_to_Customer; "Sell-to Customer Name")
            {

            }
            column(No; "No.")
            {

            }
            //  assambly; 
            column(Full_Address; "Ship-to Address")
            {

            }
            column(Money; Money)
            {

            }



            dataitem(Sales_Line; "Sales Line")
            {
                DataItemLink = "Document No." = Sales_Header."No.";
                // Change the SqlJoinType value to suit the desired results: LeftOuterJoin, InnerJoin, RighOuterJoin, FullJoin, CrossJoin.
                SqlJoinType = InnerJoin;

                column(item_Description; "Description")
                {

                }
                column(Quantity; Quantity)
                {

                }
                column(Car_ID; "Car ID")
                {

                }
                column(Type; Type)
                {

                }

            }
        }
    }
}