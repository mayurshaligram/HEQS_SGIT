pageextension 50103 "Sales Order_Ext" extends "Sales Order"
{
    actions
    {
        modify(Release){

            trigger OnAfterAction()
            var
                pageV : Page "Purchase Order";
                ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                processRec: Record "Purchase Header";
                tempText: Text[20];
                hasPO: Boolean;
                SORecord : Record "Sales Header";
                ICRec: Record "Sales Header";
            begin
                // Send PO
                // Message('release la qiuqiu le');
                tempText := rec."No.";
                tempText[2] := 'P';
                hasPO := processRec.Get(Rec."Document Type"::Order,tempText);
                processRec."Posting Date" := rec."Posting Date";
                processRec."Buy-from IC Partner Code" := 'HEQSINTERNATIONAL';
                processRec.status := rec.Status::Released;
                processRec.Modify();
                SORecord.ChangeCompany('Test Company');
                SORecord.SetCurrentKey("External Document No."); 
                SORecord.SetRange("External Document No.", tempText);
                // Message('Anchor');
                // Message('%1', rec.Status);
                if not (SORecord.findset) then
                    if ApprovalsMgmt.PrePostApprovalCheckPurch(processRec) then
                        ICInOutboxMgt.SendPurchDoc(processRec, false);


                if (SORecord.findset) then
                //message('AnChor2');
                    repeat
                        ICrec.ChangeCompany('Test Company');
                        // Message('%1, %2',SORecord."Document type", SORecord."No.");
                        ICRec.get(SORecord."Document type", SORecord."No.");
                        // Message('ICREC %1', ICRec."No.");
                        // Message('%1, %2', rec.Status, ICRec.Status);
                        ICRec.Status := rec.Status;
                        Message('ICrec no %1, status %2', ICRec."No.", icrec.Status);
                        ICrec."Work Description" := rec."Work Description";
                        rec.CALCFIELDS("Work Description");
                        ICrec."Work Description" := rec."Work Description";
                        ICRec."Retail Sales Pending" := (rec.Status = rec.Status::Open);
                        ICREC.Modify();
                    until (SORecord.next() = 0)
            end;
        }

    }

  trigger OnOpenPage();
  var
    Rrec: Record "Sales Header";
    temptext: Text[20];
  begin
      if rec.CurrentCompany = 'Test Company' then begin
          temptext := rec."External Document No.";
          temptext[2] := 'S';
          Rrec.ChangeCompany('Priceworth Pty Ltd');
          Rrec.get(rec."Document Type", temptext);
          rec.Status := Rrec.status;
          rec."Ship-to Name" := rrec."Ship-to Name";
          rec."Ship-to Address" := rrec."Ship-to Address";
          rec.Ship := rrec.ship;
          rrec.CalcFields("Work Description");
          rec."Work Description" := rrec."Work Description";
          rec."Retail Sales Pending" := Rrec."Retail Sales Pending";
          rec.Modify();

      end;
  end;


//   trigger OnClosePage();
//     var
//         IVrec: Record "Sales Header";
//         ICrec: Record "Sales Header";
//         temptext: Text[20];
//     begin
//         Message(rec.CurrentCompany);
//         if (rec.CurrentCompany = 'Priceworth Pty Ltd') then begin
//             IVrec.ChangeCompany('Test Company');
//             temptext := rec."No.";
//             IVrec.SetCurrentKey("External Document No."); 
//             IVrec.SetRange("External Document No.", tempText);
//             if (IVRec.findset) then
//                     repeat
//                         ICRec.get(IVrec."Document type", IVrec."No.");
//                         ICRec.Status := rec.Status;
//                         ICRec."Retail Sales Pending" := (rec.Status = rec.Status::Open);
//                         ICREC.Modify();
//                     until (IVrec.next() = 0)
//         end;
//     end;
 
}