pageextension 50017 "INTPurchaseOrderList" extends "Purchase Order List"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Buy-from Vendor Name")
        {
            field("Buy-from City"; rec."Buy-from City")
            {
                ApplicationArea = All;
                ToolTip = 'Buy-from City';
            }
            field("Posting Message"; rec."Posting Message")
            {
                ApplicationArea = All;
                ToolTip = 'Posting Message';
            }
            field("Vendor Invoice No."; rec."Vendor Invoice No.")
            {
                ApplicationArea = All;
                ToolTip = 'Número da NF';
            }
            field("CADBR Fiscal Document Type"; rec."CADBR Fiscal Document Type")
            {
                ApplicationArea = All;
                ToolTip = 'Tipo Documento Fiscal';
            }
            field("CADBR Print Serie"; rec."CADBR Print Serie")
            {
                ApplicationArea = All;
                ToolTip = 'Série Impressão';
            }
            field("CADBR CFOP Code"; rec."CADBR CFOP Code")
            {
                ApplicationArea = All;
                ToolTip = 'Cod. CFOP';
            }
            field("CADBR Service Delivery City"; rec."CADBR Service Delivery City")
            {
                ApplicationArea = All;
                ToolTip = 'Município Prestação Serviço';
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(DeleteRecords)
            {
                Caption = 'Delete/Cancel';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Delete;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                    intPur: Record "Integration Purchase";
                    importForm: Page "Rejection Reason Dialog";
                    RejectionCode: Code[20];
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);

                    if not (importForm.RunModal = Action::OK) then
                        exit;
                    RejectionCode := importForm.GetReject();
                    if RejectionCode <> '' then begin

                        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                        if not PurchaseHeader.IsEmpty then begin
                            if Confirm('You will delete %1 records, do you want to continue?', false, Format(PurchaseHeader.Count())) then begin
                                if PurchaseHeader.FindSet() then
                                    repeat

                                        intPur.Reset();
                                        intPur.SetRange("Document No.", PurchaseHeader."No.");
                                        if not intPur.IsEmpty then begin
                                            intPur.ModifyAll("Rejection Reason", RejectionCode);
                                            intPur.ModifyAll(Status, intpur.Status::Cancelled);
                                        end;

                                        PurchaseHeader."Posting No." := '';
                                        PurchaseHeader.Modify();
                                        PurchaseHeader.Delete(false);

                                    until PurchaseHeader.Next() = 0;

                            end;
                        end;
                    end;

                end;
            }
        }

        addAfter(Reopen)
        {

            action(UnderAnalysis)
            {
                Caption = 'Under Analysis';
                ApplicationArea = Suite;
                Image = Undo;
                trigger OnAction()
                var
                    IntPurchase: Record "Integration Purchase";
                    IntegrationPurchase: Codeunit "Integration Purchase";
                    PurchaseHead: Record "Purchase Header";
                    PurchaseHeader: Record "Purchase Header";
                    Label50020: Label 'Under Analysis';
                    PostingTemplateMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
                    ProcessConfirmWithSkipQst: Label 'You have selected multiple documents for processing. \Some of the documents are not available and will be skipped. (Selected %1, Skipping %2)\\Do you want to continue?', Comment = '%1=integer(number of rows selected) %2=integer(number of rows skipped)';
                    ProcessConfirmWithoutSkipQst: Label 'You have selected multiple documents for processing. (Selected %1, Skipping 0)\\Do you want to continue?', Comment = '%1=integer(number of rows selected)';
                    Window: Dialog;
                    CounterTotal: Integer;
                    CounterToPost: Integer;
                    ConfirmManagement: Codeunit "Confirm Management";
                    ProcessConfirmQst: Text;
                    NoSelected: Integer;
                    NoSkipped: Integer;
                begin

                    CurrPage.SetSelectionFilter(PurchaseHead);
                    if PurchaseHead.FindSet() then begin
                        if GuiAllowed() then
                            Window.Open(PostingTemplateMsg);

                        CounterTotal := PurchaseHead.Count();

                        NoSelected := PurchaseHead.Count();

                        CurrPage.SetSelectionFilter(PurchaseHeader);
                        PurchaseHeader.FilterGroup(10);
                        PurchaseHeader.SetFilter(Status, '<>%1', PurchaseHeader.Status::"Under Analysis");
                        NoSkipped := NoSelected - PurchaseHeader.Count;
                        if (NoSkipped <> 0) or (NoSelected <> 0) then begin
                            if NoSkipped <> 0 then
                                ProcessConfirmQst := StrSubstNo(ProcessConfirmWithSkipQst, NoSelected, NoSkipped)
                            else
                                ProcessConfirmQst := StrSubstNo(ProcessConfirmWithoutSkipQst, NoSelected);
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ProcessConfirmQst, NoSelected, NoSkipped), true) then
                                exit;
                        end;

                        repeat
                            IntPurchase.Reset();
                            IntPurchase.SetRange("Document No.", PurchaseHead."No.");
                            if IntPurchase.FindFirst() then begin

                                CounterToPost += 1;
                                if GuiAllowed() then
                                    Window.Update(1, Round(CounterToPost / CounterTotal * 10000, 1));

                                IntPurchase.Reset();
                                IntPurchase.SetRange("Document No.", IntPurchase."Document No.");
                                IntPurchase.SetRange("Line No.", IntPurchase."Line No.");
                                IntPurchase.SetRange("Excel File Name", IntPurchase."Excel File Name");
                                if IntPurchase.FindFirst() then
                                    IntegrationPurchase.UnderAnalysis(IntPurchase);
                            end;

                        until PurchaseHead.Next() = 0;

                        if GuiAllowed then
                            Window.Close();


                    end;

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message(Label50020);

                end;
            }

        }
        modify(Release)
        {
            Visible = false;
        }
        addafter(Release)
        {
            action(ReleaseSBA)
            {
                Caption = 'Release';
                ApplicationArea = Suite;
                Image = ReleaseDoc;
                trigger OnAction()
                var
                    IntPurchase: Record "Integration Purchase";
                    IntegrationPurchase: Codeunit "Integration Purchase";
                    PurchaseHead: Record "Purchase Header";
                    PurchaseHeader: Record "Purchase Header";
                    Release: Label 'Release Order';
                    PostingTemplateMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
                    ProcessConfirmWithSkipQst: Label 'You have selected multiple documents for processing. \Some of the documents are not available and will be skipped. (Selected %1, Skipping %2)\\Do you want to continue?', Comment = '%1=integer(number of rows selected) %2=integer(number of rows skipped)';
                    ProcessConfirmWithoutSkipQst: Label 'You have selected multiple documents for processing. (Selected %1, Skipping 0)\\Do you want to continue?', Comment = '%1=integer(number of rows selected)';
                    Window: Dialog;
                    CounterTotal: Integer;
                    CounterToPost: Integer;
                    ConfirmManagement: Codeunit "Confirm Management";
                    ProcessConfirmQst: Text;
                    NoSelected: Integer;
                    NoSkipped: Integer;
                begin

                    CurrPage.SetSelectionFilter(PurchaseHead);
                    if PurchaseHead.FindSet() then begin

                        if GuiAllowed() then
                            Window.Open(PostingTemplateMsg);

                        CounterTotal := PurchaseHead.Count();

                        NoSelected := PurchaseHead.Count();

                        CurrPage.SetSelectionFilter(PurchaseHeader);
                        PurchaseHeader.FilterGroup(10);
                        PurchaseHeader.SetFilter(Status, '<>%1', PurchaseHeader.Status::Released);
                        NoSkipped := NoSelected - PurchaseHeader.Count;

                        if (NoSkipped <> 0) or (NoSelected <> 0) then begin
                            if NoSkipped <> 0 then
                                ProcessConfirmQst := StrSubstNo(ProcessConfirmWithSkipQst, NoSelected, NoSkipped)
                            else
                                ProcessConfirmQst := StrSubstNo(ProcessConfirmWithoutSkipQst, NoSelected);
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ProcessConfirmQst, NoSelected, NoSkipped), true) then
                                exit;
                        end;

                        repeat

                            IntPurchase.Reset();
                            IntPurchase.SetRange("Document No.", PurchaseHead."No.");
                            if IntPurchase.FindFirst() then begin

                                CounterToPost += 1;
                                if GuiAllowed() then
                                    Window.Update(1, Round(CounterToPost / CounterTotal * 10000, 1));

                                IntPurchase.Reset();
                                IntPurchase.SetRange("Document No.", IntPurchase."Document No.");
                                IntPurchase.SetRange("Line No.", IntPurchase."Line No.");
                                IntPurchase.SetRange("Excel File Name", IntPurchase."Excel File Name");
                                if IntPurchase.FindFirst() then
                                    IntegrationPurchase.PurchRealse(IntPurchase);
                            end;

                        until PurchaseHead.Next() = 0;

                        if GuiAllowed then
                            Window.Close();

                    end;

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message(Release);

                end;
            }
        }
    }
}