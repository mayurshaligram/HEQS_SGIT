// tableextension 50111 BOMComponentExt extends "BOM Component"
// {
//     trigger OnAfterInsert()
//     var
//         TempText: Text;
//         RetailBOMComponent: Record "BOM Component";
//         LastRetailBomComponent: Record "BOM Component";
//         OtherCompanyRecord: Record Company;
//         TempLine: Integer;
//     begin
//         if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
//             OtherCompanyRecord.Reset();
//             if OtherCompanyRecord.Find('-') then
//                 repeat
//                     if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
//                         LastRetailBomComponent.ChangeCompany(OtherCompanyRecord.Name);
//                         LastRetailBomComponent.FindLast();
//                         RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
//                         RetailBOMComponent.SetRange("Parent Item No.", Rec."Parent Item No.");
//                         RetailBOMComponent.SetRange("No.", Rec."No.");
//                         if RetailBOMComponent.FindSet() = false then begin
//                             TempLine := LastRetailBomComponent."Line No." + 1000;
//                             RetailBOMComponent := Rec;
//                             RetailBOMComponent."Line No." := TempLine;
//                             RetailBOMComponent.Insert();
//                         end
//                         else begin
//                             TempLine := RetailBOMComponent."Line No.";
//                             RetailBOMComponent := Rec;
//                             RetailBOMComponent."Line No." := TempLine;
//                             RetailBOMComponent.Modify();
//                         end;
//                     end;
//                 until OtherCompanyRecord.Next() = 0;
//         end;
//     end;

//     trigger OnAfterModify()
//     var
//         TempText: Text;
//         RetailBOMComponent: Record "BOM Component";
//         LastRetailBomComponent: Record "BOM Component";
//         OtherCompanyRecord: Record Company;
//         TempLine: Integer;
//     begin
//         if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
//             OtherCompanyRecord.Reset();
//             if OtherCompanyRecord.Find('-') then
//                 repeat
//                     if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
//                         LastRetailBomComponent.ChangeCompany(OtherCompanyRecord.Name);
//                         LastRetailBomComponent.FindLast();
//                         RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
//                         RetailBOMComponent.SetRange("Parent Item No.", Rec."Parent Item No.");
//                         RetailBOMComponent.SetRange("No.", Rec."No.");
//                         if RetailBOMComponent.FindSet() = false then begin
//                             TempLine := LastRetailBomComponent."Line No." + 1000;
//                             RetailBOMComponent := Rec;
//                             RetailBOMComponent."Line No." := TempLine;
//                             RetailBOMComponent.Insert();
//                         end
//                         else begin
//                             TempLine := RetailBOMComponent."Line No.";
//                             RetailBOMComponent := Rec;
//                             RetailBOMComponent."Line No." := TempLine;
//                             RetailBOMComponent.Modify();
//                         end;
//                     end;
//                 until OtherCompanyRecord.Next() = 0;
//         end;
//     end;

//     trigger OnAfterDelete()
//     var
//         TempText: Text;
//         RetailBOMComponent: Record "BOM Component";
//         OtherCompanyRecord: Record Company;
//     begin
//         if Rec.CurrentCompany = 'HEQS International Pty Ltd' then begin
//             OtherCompanyRecord.Reset();
//             if OtherCompanyRecord.Find('-') then
//                 repeat
//                     if ('HEQS International Pty Ltd' <> OtherCompanyRecord.Name) then begin
//                         RetailBOMComponent.ChangeCompany(OtherCompanyRecord.Name);
//                         RetailBOMComponent.SetRange("Parent Item No.", Rec."Parent Item No.");
//                         RetailBOMComponent.SetRange("No.", Rec."No.");
//                         if RetailBOMComponent.FindSet() = true then begin
//                             RetailBOMComponent.Delete();
//                         end;
//                     end;
//                 until OtherCompanyRecord.Next() = 0;
//         end;
//     end;


// }