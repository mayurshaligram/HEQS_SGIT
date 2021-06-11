page 50111 "SO Import Worksheet"
{
    Caption = 'SO Import Worksheet';
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sales Header";
    SourceTableView = sorting("Batch Name", "No.");
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Line No."; Rec."No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Batch Name"; Rec."Batch Name")
                {

                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }


            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Import")
            {
                Caption = '&Import';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Import data from excel.';

                trigger OnAction()
                var
                    Other_Same_Date_Sales_Order: Record "Sales Header";
                begin
                    Other_Same_Date_Sales_Order.SetRange("Document Date", DT2Date(system.CurrentDateTime));
                    if Other_Same_Date_Sales_Order.FindLast() then
                        if NumberSequence.Exists('BatchSequence', true) = false then
                            NumberSequence.Insert('BatchSequence', 1)
                        else
                            BatchName := FORMAT(NumberSequence.Next('BatchSequence', true)) + '_' + FORMAT(DT2Date(system.CurrentDateTime))
                    else begin
                        if NumberSequence.Exists('BatchSequence', true) then
                            NumberSequence.Delete('BatchSequence');
                        NumberSequence.Insert('BatchSequence', 1);
                        BatchName := FORMAT(NumberSequence.Next('BatchSequence', true)) + '_' + FORMAT(DT2Date(system.CurrentDateTime));
                    end;
                    ReadExcelSheet();
                end;
            }

        }
    }



    var
        BatchName: Code[30];
        FileName: Text[100];
        SheetName: Text[100];

        TempExcelBuffer: Record "Excel Buffer" temporary;
        UploadMsg: Label 'Please Choose the Xlsx file(If you want to upload more than one please upload .ZIP file).';
        NoFileFoundMsg: Label 'No Excel file found!';
        ExcelImportSucess: Label 'Excel is successfully imported.';


    local procedure ReadExcelSheet()
    var
        FileMgt: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        IStream: InStream;
        FromFile: Text[100];
        EntryList: List of [Text];
        EntryListKey: Text;
        EntryOutStream: OutStream;
        EntryInStream: InStream;
        Length: Integer;
        TempBlob: Codeunit "Temp Blob";
        templist: List of [Integer];
    begin
        UploadIntoStream(UploadMsg, '', '', FromFile, IStream);
        if FromFile.EndsWith('.zip') then begin
            DataCompression.OpenZipArchive(IStream, false);
            DataCompression.GetEntryList(EntryList);
            foreach EntryListKey in EntryList do begin
                Clear(TempBlob);
                Clear(EntryInStream);
                Clear(EntryOutStream);
                FileName := FileMgt.GetFileName(EntryListKey);
                // message('%1', FileName);
                TempBlob.CreateOutStream(EntryOutStream);
                DataCompression.ExtractEntry(EntryListKey, EntryOutStream, Length);
                TempBlob.CreateInStream(EntryInStream);
                SheetName := TempExcelBuffer.SelectSheetsNameStream(EntryInStream);
                TempExcelBuffer.Reset();
                TempExcelBuffer.DeleteAll();
                TempExcelBuffer.OpenBookStream(EntryInStream, SheetName);
                TempExcelBuffer.ReadSheet();
                ImportExcelData();
            end
        end
        else begin
            if FromFile <> '' then begin
                FileName := FileMgt.GetFileName(FromFile);
                SheetName := TempExcelBuffer.SelectSheetsNameStream(IStream);
            end else
                Error(NoFileFoundMsg);
            TempExcelBuffer.Reset();
            TempExcelBuffer.DeleteAll();
            TempExcelBuffer.OpenBookStream(IStream, SheetName);
            TempExcelBuffer.ReadSheet();
            ImportExcelData();
        end;
    end;

    local procedure ImportExcelData()
    var
        SOImportBuffer: Record "Sales Header";
        SLImportBuffer: Record "Sales Line";
        RowNo: Integer;
        ColNo: Integer;
        TempRow: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        temp: Text;
        tempdecimal: Decimal;
        TempItemNo: Code[20];
        Show: Text;
        TempCode: Code[20];

        TempHeaderText: Text;
        TempWorkDescription: Text;
        TempDate: Date;
        SaleLineSubPage: Page "Sales Order Subform";

        TotalAmount: Decimal;
        NoAssemblyList: List of [Text];

        PriceDecimal: Decimal;
        TempText: Text;
    begin
        InitializeNoAssembly(NoAssemblyList);
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;

        // Sales Header
        SOImportBuffer.Init();
        Evaluate(SOImportBuffer."Batch Name", BatchName);
        Show := GetValueAtCell(1, 4);
        if Show = '' then
            Show := 'blank';
        SOImportBuffer.Validate("Sell-to Customer Name", ExamSamePrefixName(Show));
        SOImportBuffer."Document Type" := SOImportBuffer."Document Type"::Order;
        // PO number to Your reference
        TempHeaderText := GetValueAtCell(1, 7);
        if TempHeaderText <> '' then
            SOImportBuffer."Your Reference" := TempHeaderText;
        // Person Orderding to Ship-to Contact
        TempHeaderText := GetValueAtCell(2, 4);
        if TempHeaderText <> '' then
            SOImportBuffer."Sell-to Contact" := TempHeaderText;
        // Client's Name to Ship-to Contact
        TempHeaderText := GetValueAtCell(3, 4);
        if TempHeaderText <> '' then
            SOImportBuffer."Ship-to Name" := TempHeaderText;
        // Client's Contact Name
        TempHeaderText := GetValueAtCell(3, 7);
        if TempHeaderText <> '' then
            SOImportBuffer."Ship-to Contact" := TempHeaderText;
        // Caseworker's Name and CaseWorker Contact Name
        TempText := GetValueAtCell(4, 4);
        if TempText <> '' then
            TempWorkDescription += 'CaseWorker: ' + TempText + '  ';
        TempText := GetValueAtCell(4, 7);
        if TempText <> '' then
            TempWorkDescription += 'CaseWorker No: ' + TempText + '  ';
        TempText := GetValueAtCell(5, 7);
        if TempText <> '' then
            TempWorkDescription += 'CaseWorker No 2: ' + TempText + '  ';
        // Date Ordered to Order Date
        if GetValueAtCell(5, 4) <> '' then begin
            if Evaluate(TempDate, GetValueAtCell(5, 4)) then
                SOImportBuffer."Order Date" := TempDate
        end;
        // Delivery Address
        TempHeaderText := GetValueAtCell(6, 4);
        if TempHeaderText <> '' then begin
            SOImportBuffer."Ship-to Address" := TempHeaderText;
        end;
        // Floor
        TempHeaderText := GetValueAtCell(7, 4);
        if TempHeaderText <> '' then
            TempWorkDescription += '  Floor' + TempHeaderText;
        // Prefered Delivery date to Promised Delivery date
        if GetValueAtCell(7, 7) <> '' then begin
            if Evaluate(TempDate, GetValueAtCell(5, 7)) then
                SOImportBuffer."Requested Delivery Date" := TempDate
        end;
        // Special 
        TempHeaderText := GetValueAtCell(8, 5);
        if TempHeaderText <> '' then
            TempWorkDescription += '  Other' + TempHeaderText;
        // City 
        // TempHeaderText := GetValueAtCell(8, 2);
        // if TempHeaderText <> '' then
        //     SOImportBuffer.validate("Ship-to City", TempHeaderText);
        // // PostCode
        // TempHeaderText := GetValueAtCell(8, 4);
        // if TempHeaderText <> '' then
        //     SOImportBuffer.validate("Ship-to Post Code", TempHeaderText);
        // // Preferred Delivery Period
        // TempHeaderText := GetValueAtCell(8, 6);
        // if TempHeaderText <> '' then
        //     if TempHeaderText = 'M' then
        //         SOImportBuffer."Request Delivery Period" := SOImportBuffer."Request Delivery Period"::"Morning 8am - 1pm"
        //     else
        //         SOImportBuffer."Request Delivery Period" := SOImportBuffer."Request Delivery Period"::"Afternoon 1pm - 6pm";
        // // Manage Approve
        // TempHeaderText := GetValueAtCell(8, 8);
        // if TempHeaderText <> '' then
        //     if TempHeaderText <> 'Y' then
        //         SOImportBuffer."Need Manage Approval" := true
        //     else
        //         SOImportBuffer."Need Manage Approval" := false;


        // // Send Email
        // TempHeaderText := GetValueAtCell(11, 4);
        // if TempHeaderText <> '' then
        //     if TempHeaderText <> '' then
        //         SOImportBuffer."Sell-to E-Mail" := TempHeaderText;
        LSetWorkDescription(SOImportBuffer, TempWorkDescription);
        if SOImportBuffer."Ship-to Address" <> '' then
            SOImportBuffer.Delivery := SOImportBuffer.Delivery::Delivery;
        SOImportBuffer.Insert(true);
        temp := GetValueAtCell(TempRow, 5);
        TempRow := 15;
        repeat
            Clear(SLImportBuffer);
            SLImportBuffer.init();
            SLImportBuffer."Document Type" := SLImportBuffer."Document Type"::Order;
            SLImportBuffer."Document No." := SOImportBuffer."No.";
            SLImportBuffer.Type := SLImportBuffer.Type::Item;
            temp := GetValueAtCell(TempRow, 6);
            if (temp <> '') AND (Evaluate(PriceDecimal, temp)) then begin
                Evaluate(TempCode, GetValueAtCell(TempRow, 2));
                if TempCode <> 'CODE' then begin
                    SLImportBuffer.Validate("No.", TempCode);
                    Evaluate(tempdecimal, GetValueAtCell(TempRow, 6));
                    SLImportBuffer.Validate(Quantity, tempdecimal);
                    Evaluate(tempdecimal, GetValueAtCell(TempRow, 7));
                    SLImportBuffer.Validate("Unit Price", tempdecimal);
                    SLImportBuffer."Location Code" := SOImportBuffer."Location Code";
                    // Need Assembly Checking
                    if NoAssemblyList.Contains(SLImportBuffer."No.") = false then
                        SLImportBuffer.NeedAssemble := true;
                    SLImportBuffer.Insert(true);
                    if SLImportBuffer.Description.StartsWith('(M)') then
                        if Dialog.Confirm('Do you want to explode BOM for Pac ' + SLImportBuffer."No." + ', you need to assign the proper price the BOM price to maintain total price not change.') then
                            CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", SLImportBuffer);
                end;
            end;
            TempRow += 1;
        until TempRow > 200;
        SOImportBuffer.CalcFields("Amount Including VAT");
        if SOImportBuffer."Amount Including VAT" <= 300 then begin
            Clear(SLImportBuffer);
            SLImportBuffer.init();
            SLImportBuffer."Document Type" := SLImportBuffer."Document Type"::Order;
            SLImportBuffer."Document No." := SOImportBuffer."No.";
            SLImportBuffer.Type := SLImportBuffer.Type::Item;
            SLImportBuffer.Validate("No.", '9010000');
            SLImportBuffer.Validate(Quantity, 1);
            SLImportBuffer.Validate("Unit Price", 50);
            SLImportBuffer."Location Code" := SOImportBuffer."Location Code";
            SLImportBuffer.Insert(true);
        end;
    end;

    local procedure ExamSamePrefixName(Show: Text): Text
    var
        Customer: Record Customer;
        OptionMembers: Text;
        OptionNumber: Integer;
        DefaultNumber: Integer;
        Instruction: Label 'Please Select the customer name.';
        Seperator: List of [Text];
        OptionList: List of [Text];
        CustomerName: Text;
    begin

        Customer.SETFILTER(Name, '@' + Show + '*');
        if Customer.FindSet() then begin
            repeat
                if OptionMembers <> '' then
                    OptionMembers := OptionMembers + ',' + Customer.Name
                else
                    OptionMembers := Customer.Name;
            until Customer.Next() = 0;
            DefaultNumber := 1;
            OptionNumber := Dialog.StrMenu(OptionMembers, DefaultNumber, Instruction);
            Seperator.Add(',');
            OptionList := OptionMembers.Split(Seperator);
            CustomerName := OptionList.Get(OptionNumber);
            Message(CustomerName);
        end
        else
            CustomerName := Show;
        exit(CustomerName);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin

        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure LSetWorkDescription(var SalesHeader: Record "Sales Header"; NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear(SalesHeader."Work Description");
        SalesHeader."Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        // SalesHeader.Modify;
    end;

    local procedure InitializeNoAssembly(var NoAssemblyList: List of [Text])
    begin
        // Mattress and Kitchen
        NoAssemblyList.Add('1210002');
        NoAssemblyList.Add('1210010');
        NoAssemblyList.Add('1210006');
        NoAssemblyList.Add('1210003');
        // King
        NoAssemblyList.Add('1240002');
        NoAssemblyList.Add('1240010');
        NoAssemblyList.Add('1240009');
        // Double
        NoAssemblyList.Add('1220002');
        NoAssemblyList.Add('1220010');
        NoAssemblyList.Add('1220006');
        NoAssemblyList.Add('1220003');
        // Queen Size
        NoAssemblyList.Add('1230002');
        NoAssemblyList.Add('1230006');
        NoAssemblyList.Add('1230003');
        // Kitchen
        NoAssemblyList.Add('7020001');
        NoAssemblyList.Add('7020002');
        NoAssemblyList.Add('7020003');
        NoAssemblyList.Add('7020004');
        NoAssemblyList.Add('7020005');
        NoAssemblyList.Add('7020006');
        NoAssemblyList.Add('7020007');
        NoAssemblyList.Add('7020008');
        NoAssemblyList.Add('7030001');
        NoAssemblyList.Add('7030002');
        NoAssemblyList.Add('7030020');
        NoAssemblyList.Add('7030004');
        NoAssemblyList.Add('7030005');
        NoAssemblyList.Add('7030006');
        NoAssemblyList.Add('7030007');
        NoAssemblyList.Add('7030008');
        NoAssemblyList.Add('7030009');
        NoAssemblyList.Add('7030010');
        NoAssemblyList.Add('7030011');
        NoAssemblyList.Add('7030012');
        NoAssemblyList.Add('7030022');
        NoAssemblyList.Add('7030014');
        NoAssemblyList.Add('7030015');
        NoAssemblyList.Add('7030016');
        NoAssemblyList.Add('7030019');
        NoAssemblyList.Add('7030018');
        NoAssemblyList.Add('7040001');
        NoAssemblyList.Add('7040002');
        NoAssemblyList.Add('7050006');
        NoAssemblyList.Add('7050013');
        NoAssemblyList.Add('7050004');
        NoAssemblyList.Add('7050002');
        NoAssemblyList.Add('7050007');
        NoAssemblyList.Add('7050005');
        NoAssemblyList.Add('7060001');
        NoAssemblyList.Add('7060002');
        NoAssemblyList.Add('7060003');
        NoAssemblyList.Add('7060004');
        NoAssemblyList.Add('7060005');
        NoAssemblyList.Add('7060006');
        NoAssemblyList.Add('7060007');
        NoAssemblyList.Add('9030000');
    end;

}