pageextension 50012 "SBAPaymentJournal" extends "Payment Journal"
{
    // actions
    // {
    //     modify(Post)
    //     {
    //         Visible = false;
    //     }
    //     addafter(Post)
    //     {
    //         action(PostSBA)
    //         {

    //             ApplicationArea = Basic, Suite;
    //             Caption = 'P&ost';
    //             Image = PostOrder;
    //             Promoted = true;
    //             PromotedCategory = "Category8";
    //             PromotedIsBig = true;
    //             ShortCutKey = 'F9';
    //             ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

    //             trigger OnAction()
    //             var
    //                 IntPurchPayment: Record IntPurchPayment;
    //                 GJL: Record "Gen. Journal Line";
    //             begin
    //                 IntPurchPayment.Reset();
    //                 IntPurchPayment.SetRange("Document No.", Rec."Document No.");
    //                 IntPurchPayment.SetRange("Applies-to Doc. No.", Rec."Applies-to Doc. No.");
    //                 IntPurchPayment.SetRange(Status, IntPurchPayment.Status::Created);
    //                 IntPurchPayment.FindFirst();

    //                 Rec.SendToPosting(Codeunit::"Gen. Jnl.-Post");

    //                 GJL.Reset();
    //                 GJL.SetRange("Journal Template Name", IntPurchPayment."Journal Template Name");
    //                 GJL.SetRange("Journal Batch Name", IntPurchPayment."Journal Batch Name");
    //                 GJL.SetRange("Document No.", IntPurchPayment."Document No.");
    //                 GJL.SetRange(GJL."Applies-to Doc. No.", IntPurchPayment."Applies-to Doc. No.");
    //                 if not GJL.FindFirst() then begin
    //                     //repeat
    //                     /*IntPurchPayment.Reset();
    //                     IntPurchPayment.SetRange("Document No.", Rec."Document No.");
    //                     IntPurchPayment.SetRange("Applies-to Doc. No.", Rec."Applies-to Doc. No.");
    //                     IntPurchPayment.SetRange(Status, IntPurchPayment.Status::Created);
    //                     if IntPurchPayment.FindFirst() then*/
    //                     IntPurchPayment.ModifyAll(Status, IntPurchPayment.Status::Posted);
    //                     //until Rec.Next = 0;
    //                 end;

    //                 CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
    //                 //SetJobQueueVisibility();
    //                 CurrPage.Update(false);
    //             end;
    //         }
    //     }
    // }
}
