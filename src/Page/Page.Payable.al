page 50110 Payable
{
    Caption = 'Payable';
    Editable = true;
    PageType = List;
    SourceTable = Payable;
    UsageCategory = Lists;
    ApplicationArea = All;
    AdditionalSearchTerms = 'Payable';

    // SourceTableView = WHERE("USD" = filter(> 0));
    PromotedActionCategories = 'New,Process,Report,Request Approval,Currency,Release,Posting,Print/Send,Type';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec.Approval;
                    ToolTip = 'Specifies the Document No. for the Payable';
                }
                field("Posted Invoice No"; Rec."Posted Invoice No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Posted Invoice No. if posted';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vendor Invoice No.';

                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Company';
                }
                field(Vendor; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vendor';
                }
                field(Item; Rec.Item)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Items for the payable';
                    MultiLine = true;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Visible = Default;
                    ToolTip = 'Specifies the currency code for the amount';
                }
                field(Amount; Rec."AUD")
                {
                    Caption = 'Amount';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount including GST';
                    Visible = Default;
                }
                field("Amount Remaining"; Rec."USD")
                {
                    Caption = 'Amount Remaining';
                    ApplicationArea = All;
                    ToolTip = 'Specifies Amount Remaining including GST';
                    Visible = Default;
                }
                field("Amount Received Not Invoiced"; Rec."Amount Received Not Invoiced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Amount Remaining including GST';
                    Visible = Default;
                }
                field("AUD Amount"; Rec."AUD Amount")
                {
                    Caption = 'Amount(AUD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AUD amount including GST';
                    Visible = IsAUDPage;
                }
                field("AUD Remaining Amount"; Rec."AUD Remaining Amount")
                {
                    Caption = 'Amoun Remaining(AUD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AUD amount Remainging including GST';
                    Visible = IsAUDPage;
                }
                field("AUD Rec Not Inv"; Rec."AUD Rec Not Inv")
                {
                    Caption = 'Amoun Rec Not Inv Remaining(AUD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AUD Rec Not Inv Remainging including GST';
                    Visible = IsAUDPage;
                }
                field("USD Amount"; Rec."USD Amount")
                {
                    Caption = 'Amount(USD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the USD amount including GST';
                    Visible = IsUSDPage;
                }
                field("USD Remaining Amount"; Rec."USD Remaining Amount")
                {
                    Caption = 'Amoun Remaining(USD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the USD amount Remainging including GST';
                    Visible = IsUSDPage;
                }
                field("USD Rec Not Inv"; Rec."USD Rec Not Inv")
                {
                    Caption = 'Amoun Rec Not Inv Remaining(USD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the USD Rec Not Inv Remainging including GST';
                    Visible = IsUSDPage;
                }
                field("CAD Amount"; Rec."CAD Amount")
                {
                    Caption = 'Amount(CAD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CAD amount including GST';
                    Visible = IsCADPage;
                }
                field("CAD Remaining Amount"; Rec."CAD Remaining Amount")
                {
                    Caption = 'Amoun Remaining(CAD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CAD amount Remainging including GST';
                    Visible = IsCADPage;
                }
                field("CAD Rec Not Inv"; Rec."CAD Rec Not Inv")
                {
                    Caption = 'Amoun Rec Not Inv Remaining(CAD)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CAD Rec Not Inv Remainging including GST';
                    Visible = IsCADPage;
                }
                field("CNY Amount"; Rec."CNY Amount")
                {
                    Caption = 'Amount(CNY)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CNY amount including GST';
                    Visible = IsCNYPage;
                }
                field("CNY Remaining Amount"; Rec."CNY Remaining Amount")
                {
                    Caption = 'Amoun Remaining(CNY)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CNY amount Remainging including GST';
                    Visible = IsCNYPage;
                }
                field("CNY Rec Not Inv"; Rec."CNY Rec Not Inv")
                {
                    Caption = 'Amoun Rec Not Inv Remaining(CNY)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the CNY Rec Not Inv Remainging including GST';
                    Visible = IsCNYPage;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field("Source of Cash"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Date of Payment"; Rec."Date of Payment")
                {
                    ApplicationArea = All;
                }
                field("Account Details"; Rec."Account Details")
                {
                    ApplicationArea = All;
                }

                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                }
                field("Bank Type"; Rec."Bank Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Period"; Rec."Payment Period")
                {
                    ApplicationArea = All;
                }
                field(Approval; Rec.Approval)
                {
                    ApplicationArea = All;
                }
                field("Director Approval"; Rec."Director Approval")
                {
                    ApplicationArea = All;
                    Editable = false;
                }


            }
        }

    }

    actions
    {
        area(processing)
        {
            action(Default)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Default';
                Image = SetupColumns;
                ToolTip = 'Display according to the default ordercurrency';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Default := Not Default;
                    CurrPage.Update();
                end;
            }

            action(AUD)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'AUD';
                Image = SetupColumns;
                ToolTip = 'View all Amount in AUD.';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    IsAUDPage := Not IsAUDPage;
                    UpdateAUD();
                    CurrPage.Update();
                end;
            }
            action(USD)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'USD';
                Image = SetupColumns;
                ToolTip = 'View all Amount in USD.';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    IsUSDPage := Not IsUSDPage;
                    UpdateUSD();
                    CurrPage.Update();
                end;
            }
            action(CNY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CNY';
                Image = SetupColumns;
                ToolTip = 'View all Amount in CAD.';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    IsCNYPage := Not IsCNYPage;
                    UpdateCNY();
                    CurrPage.Update();
                end;
            }
            action(CAD)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CAD';
                Image = SetupColumns;
                ToolTip = 'View all Amount in CAD.';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    IsCADPage := Not IsCADPage;
                    UpdateCAD();
                    CurrPage.Update();
                end;
            }
            action("Completed Payable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Completed Payable';
                Image = SetupColumns;
                ToolTip = 'View Complete Payable.';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Payable: Record Payable;
                begin
                    Payable.SetRange(USD, 0);
                    Payable.SetRange(AUD, 0.01, 9999999);
                    CurrPage.SetTableView(Payable);
                    CurrPage.Update();
                end;
            }

            action("OnGoing Payable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'OnGoing Payable';
                Image = SetupColumns;
                ToolTip = 'View OnGoing Payable';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Payable: Record Payable;
                begin
                    Payable.SetRange(USD, 0.01, 9999999);
                    Payable.SetRange(AUD, 0.01, 9999999);
                    CurrPage.SetTableView(Payable);
                    CurrPage.Update();
                end;
            }
            action("Draft Payable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Draft Payable';
                Image = SetupColumns;
                ToolTip = 'View Draft Payable';
                Visible = true;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Payable: Record Payable;
                begin
                    Payable.SetRange(USD, 0);
                    Payable.SetRange(AUD, 0);
                    CurrPage.SetTableView(Payable);
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        Default: Boolean;
        IsAUDPage: Boolean;
        IsUSDPage: Boolean;
        IsCADPage: Boolean;
        IsCNYPage: Boolean;

    trigger OnOpenPage()
    var
        User: Record User;
        TempBool: Boolean;
    begin
        TempBool := false;
        User.Reset();
        User.Get(Database.UserSecurityId());
        if (User."Full Name" = 'Kevin Lin') or (User."Full Name" = 'Karen Huang') or (User."Full Name" = 'Admin HEQS') or (User."Full Name" = 'Pei Xu') then
            TempBool := true;
        if TempBool = false then
            Error('Please contact admin to assign Payable Page Permission.');
        Default := true;
        IsAUDPage := false;
        IsUSDPage := false;
        IsCADPage := false;
        IsCNYPage := false;
    end;

    local procedure UpdateAUD();
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Payable: Record Payable;
    begin
        Payable.Reset();
        if Payable.FindSet() then
            repeat
                if Payable."Currency Code" = '' then begin
                    Payable."AUD Amount" := Payable.AUD;
                    Payable."AUD Rec Not Inv" := Payable."Amount Received Not Invoiced";
                    Payable."AUD Remaining Amount" := Payable.USD;
                end
                else begin
                    CurrencyExchangeRate.Reset();
                    CurrencyExchangeRate.SetRange("Currency Code", Payable."Currency Code");
                    if CurrencyExchangeRate.FindLast() then
                        if CurrencyExchangeRate."Exchange Rate Amount" = 0 then
                            Error('%Exchange rate can not set to 0');
                    Payable."AUD Amount" := Payable.AUD / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Rec Not Inv" := Payable."Amount Received Not Invoiced" / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Remaining Amount" := Payable.USD / CurrencyExchangeRate."Exchange Rate Amount";
                end;
                Payable.Modify();
            until Payable.Next() = 0;
    end;

    local procedure UpdateUSD();
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        USDCurrencyExchangeRate: Record "Currency Exchange Rate";
        Payable: Record Payable;
    begin
        USDCurrencyExchangeRate.Reset();
        USDCurrencyExchangeRate.SetRange("Currency Code", 'USD');
        if USDCurrencyExchangeRate.FindLast() = false then
            Error('Please Set Exchange Rate for USD.');
        Payable.Reset();
        if Payable.FindSet() then
            repeat
                if Payable."Currency Code" = '' then begin
                    Payable."USD Amount" := Payable.AUD;
                    Payable."USD Rec Not Inv" := Payable."Amount Received Not Invoiced";
                    Payable."USD Remaining Amount" := Payable.USD;
                end
                else begin
                    CurrencyExchangeRate.Reset();
                    CurrencyExchangeRate.SetRange("Currency Code", Payable."Currency Code");
                    if CurrencyExchangeRate.FindLast() then
                        if CurrencyExchangeRate."Exchange Rate Amount" = 0 then
                            Error('%Exchange rate can not set to 0');
                    Payable."AUD Amount" := Payable.AUD / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Rec Not Inv" := Payable."Amount Received Not Invoiced" / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Remaining Amount" := Payable.USD / CurrencyExchangeRate."Exchange Rate Amount";

                    Payable."USD Amount" := Payable."AUD Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."USD Rec Not Inv" := Payable."AUD Rec Not Inv" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."USD Remaining Amount" := Payable."AUD Remaining Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                end;
                Payable.Modify();
            until Payable.Next() = 0;
    end;

    local procedure UpdateCAD();
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        USDCurrencyExchangeRate: Record "Currency Exchange Rate";
        Payable: Record Payable;
    begin
        USDCurrencyExchangeRate.Reset();
        USDCurrencyExchangeRate.SetRange("Currency Code", 'CAD');
        if USDCurrencyExchangeRate.FindLast() = false then
            Error('Please Set Exchange Rate for CAD.');
        Payable.Reset();
        if Payable.FindSet() then
            repeat
                if Payable."Currency Code" = '' then begin
                    Payable."USD Amount" := Payable.AUD;
                    Payable."USD Rec Not Inv" := Payable."Amount Received Not Invoiced";
                    Payable."USD Remaining Amount" := Payable.USD;
                end
                else begin
                    CurrencyExchangeRate.Reset();
                    CurrencyExchangeRate.SetRange("Currency Code", Payable."Currency Code");
                    if CurrencyExchangeRate.FindLast() then
                        if CurrencyExchangeRate."Exchange Rate Amount" = 0 then
                            Error('%Exchange rate can not set to 0');
                    Payable."AUD Amount" := Payable.AUD / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Rec Not Inv" := Payable."Amount Received Not Invoiced" / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Remaining Amount" := Payable.USD / CurrencyExchangeRate."Exchange Rate Amount";

                    Payable."CAD Amount" := Payable."AUD Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."CAD Rec Not Inv" := Payable."AUD Rec Not Inv" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."CAD Remaining Amount" := Payable."AUD Remaining Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                end;
                Payable.Modify();
            until Payable.Next() = 0;
    end;

    local procedure UpdateCNY();
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        USDCurrencyExchangeRate: Record "Currency Exchange Rate";
        Payable: Record Payable;
    begin
        USDCurrencyExchangeRate.Reset();
        USDCurrencyExchangeRate.SetRange("Currency Code", 'CNY');
        if USDCurrencyExchangeRate.FindLast() = false then
            Error('Please Set Exchange Rate for CNY.');
        Payable.Reset();
        if Payable.FindSet() then
            repeat
                if Payable."Currency Code" = '' then begin
                    Payable."USD Amount" := Payable.AUD;
                    Payable."USD Rec Not Inv" := Payable."Amount Received Not Invoiced";
                    Payable."USD Remaining Amount" := Payable.USD;
                end
                else begin
                    CurrencyExchangeRate.Reset();
                    CurrencyExchangeRate.SetRange("Currency Code", Payable."Currency Code");
                    if CurrencyExchangeRate.FindLast() then
                        if CurrencyExchangeRate."Exchange Rate Amount" = 0 then
                            Error('%Exchange rate can not set to 0');
                    Payable."AUD Amount" := Payable.AUD / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Rec Not Inv" := Payable."Amount Received Not Invoiced" / CurrencyExchangeRate."Exchange Rate Amount";
                    Payable."AUD Remaining Amount" := Payable.USD / CurrencyExchangeRate."Exchange Rate Amount";

                    Payable."CNY Amount" := Payable."AUD Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."CNY Rec Not Inv" := Payable."AUD Rec Not Inv" * USDCurrencyExchangeRate."Exchange Rate Amount";
                    Payable."CNY Remaining Amount" := Payable."AUD Remaining Amount" * USDCurrencyExchangeRate."Exchange Rate Amount";
                end;
                Payable.Modify();
            until Payable.Next() = 0;
    end;
}


