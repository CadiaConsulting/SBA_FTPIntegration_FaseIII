codeunit 50079 "IntPurchVoidPayment"
{
    Permissions = tabledata "Detailed Vendor Ledg. Entry" = RIMD,
                tabledata "VAT Entry" = RIMD;

    trigger OnRun()
    begin

        //Check data and create journal
        CallCheckData();
        Commit();
        //Post Journal
        CallPostJournal
    end;

    procedure CheckData(var IntPurchVoidPayment: Record IntPurchVoidPayment): Boolean;
    var
        RecordTocheck: Record IntPurchVoidPayment;
        GenJournalLine: Record "Gen. Journal Line";
        FTPIntSetup: Record "FTP Integration Setup";
        IntegrationEmail: Codeunit "Integration Email";
        UserSetup: codeunit "User Setup Management";
        ErrorDate: Text;
    begin
        RecordTocheck.CopyFilters(IntPurchVoidPayment);
        RecordTocheck.SetFilter(Status, '%1', IntPurchVoidPayment.Status::Unapply);
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                if not UserSetup.TestAllowedPostingDate(RecordTocheck."Posting Date", ErrorDate) then begin
                    RecordTocheck.Status := RecordTocheck.Status::"Data Error";
                    RecordTocheck."Posting Message" := CopyStr(ErrorDate, 1, 200);
                    RecordTocheck.Modify();

                end else begin

                    if ValidateIntPurchVoidPaymentData(RecordTocheck) then begin
                        CreatePaymentJournal(RecordTocheck);

                        if (RecordTocheck."Tax Paid" = false) and (RecordTocheck."Tax Amount" <> 0) then begin
                            CreatePaymentTaxAJournal(RecordTocheck);
                            CreatePaymentTaxBJournal(RecordTocheck);
                        end;

                    end else begin

                        FTPIntSetup.Reset();
                        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Purchase Void Payment");
                        FTPIntSetup.SetRange(Sequence, 0);
                        FTPIntSetup.FindSet();
                        if FTPIntSetup."Send Email" then
                            IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", True, RecordTocheck."Posting Message", RecordTocheck."Excel File Name");
                    end;
                end;
            until RecordTocheck.Next() = 0;
        end;
    end;

    local procedure ValidateIntPurchVoidPaymentData(var RecordToCheck: Record IntPurchVoidPayment): Boolean
    begin
        RecordToCheck."Posting Message" := '';
        RecordToCheck.Modify();

        CheckJournalTemplate(RecordTocheck);
        CheckJournalBatch(RecordToCheck);
        CheckVendor(RecordToCheck);
        CheckBankAccount(RecordToCheck);
        ValidateDimensions(RecordToCheck);

        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(false);
        end
        else
            exit(true);
    end;

    local procedure CheckJournalTemplate(var RecordTocheck: Record IntPurchVoidPayment)
    var
        GenJournaltemplate: Record "Gen. Journal Template";
        JournalTempError: Label 'The Journal Template %1 does not exist.';
    begin
        if not GenJournaltemplate.Get(RecordTocheck."Journal Template Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalTempError, RecordTocheck."Journal Template Name"));
        end;
    end;

    local procedure CheckJournalBatch(var RecordToCheck: Record IntPurchVoidPayment)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalBatchError: Label 'The Journal Batch %1 does not exist.';
    begin
        if not GenJournalBatch.Get(RecordToCheck."Journal Template Name", RecordTocheck."Journal Batch Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalBatchError, RecordTocheck."Journal Batch Name"));
        end;
    end;

    local procedure CheckVendor(var RecordToCheck: Record IntPurchVoidPayment)
    var
        Vendor: Record Vendor;
        VendorError: Label 'the Vendor %1, does not exist.';
    begin
        if not Vendor.Get(RecordToCheck."Account No.") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(VendorError, RecordToCheck."Account No."));
        end;
    end;

    local procedure CheckBankAccount(var RecordToCheck: Record IntPurchVoidPayment)
    var
        BankAccount: Record "Bank Account";
        BankAccountError: Label 'the Bank Account %1 does not exist.';
    begin
        if not BankAccount.Get(RecordToCheck."Bal. Account No.") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BankAccountError, RecordToCheck."Bal. Account No."));
        end;
    end;

    local procedure ValidateDimensions(var RecordToCheck: Record IntPurchVoidPayment)
    begin
        if RecordToCheck."Dimension 1" <> '' then begin
            ValidateDim(1, RecordToCheck."Dimension 1");
        end;
        if RecordToCheck."Dimension 2" <> '' then begin
            ValidateDim(2, RecordToCheck."Dimension 2");
        end;
        if RecordToCheck."Dimension 3" <> '' then begin
            ValidateDim(3, RecordToCheck."Dimension 3");
        end;
        if RecordToCheck."Dimension 4" <> '' then begin
            ValidateDim(4, RecordToCheck."Dimension 4");
        end;
        if RecordToCheck."Dimension 5" <> '' then begin
            ValidateDim(5, RecordToCheck."Dimension 5");
        end;
        if RecordToCheck."Dimension 6" <> '' then begin
            ValidateDim(6, RecordToCheck."Dimension 6");
        end;
        if RecordToCheck."Dimension 7" <> '' then begin
            ValidateDim(7, RecordToCheck."Dimension 7");
        end;
        if RecordToCheck."Dimension 8" <> '' then begin
            ValidateDim(8, RecordToCheck."Dimension 8");
        end;
    end;

    procedure ValidateDim(DimSeq: Integer; ValueDim: Code[20])
    var
        DimensionValue: Record "Dimension Value";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionCode: Code[20];
        DimMngt: Codeunit DimensionManagement;
        GLSetupShortcutDimCode: array[8] of Code[20];
    begin
        DimMngt.GetGLSetup(GLSetupShortcutDimCode);
        CreateDim(DimSeq, GLSetupShortcutDimCode[DimSeq], ValueDim);
    end;

    procedure CreateDim(DimSeq: Integer; DimensionCode: Code[20]; ValueDim: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if not DimensionValue.Get(DimensionCode, ValueDim) then begin
            DimensionValue.Init();
            DimensionValue.Validate("Dimension Code", DimensionCode);
            DimensionValue.Validate(Code, ValueDim);
            DimensionValue.Name := ValueDim;
            DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
            if DimSeq in [1, 2] then
                DimensionValue."Global Dimension No." := DimSeq;
            DimensionValue.Insert(true);
        end;
    end;

    local procedure CreatePaymentJournal(var RecordToPost: Record IntPurchVoidPayment)
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CADBRPayTaxMgt: Codeunit "CADBR Payment Tax Mgt";
        GJL: Record "Gen. Journal Line";
        LineNo: Integer;

    begin

        GJL.Reset();
        GJL.SetRange("Journal Template Name", RecordToPost."Journal Template Name");
        GJL.SetRange("Journal Batch Name", RecordToPost."Journal Batch Name");
        if GJL.FindLast() then
            LineNo := GJL."Line No." + 10000
        else
            LineNo := 10000;

        RecordToPost."Journal Line No." := LineNo;
        RecordToPost.Modify();

        GenJournalLine.Reset();
        GenJournalLine.InitNewLine(RecordToPost."Posting Date", RecordToPost."Posting Date", RecordToPost."Posting Date",
                                     RecordToPost.Description, RecordToPost."dimension 1",
                                     RecordToPost."dimension 2", 0, '');

        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := RecordToPost."Journal Line No.";
        GenJournalLine."Account Type" := RecordToPost."Account Type";
        GenJournalLine."Account No." := RecordToPost."Account No.";

        //Valor
        GenJournalLine.VALIDATE(Amount, RecordToPost."Amount");

        GenJournalLine."Applies-to Doc. No." := RecordToPost."Applies-to Doc. No.";
        GenJournalLine."Applies-to Doc. Type" := RecordToPost."Applies-to Doc. Type"::Payment;
        GenJournalLine."Bal. Account No." := RecordToPost."Bal. Account No.";
        GenJournalLine."Bal. Account Type" := RecordToPost."Bal. Account Type";
        GenJournalLine."Document No." := RecordToPost."Document No.";
        GenJournalLine."Document Type" := RecordToPost."Document Type";

        if RecordToPost."Applies-to Doc. No." <> '' then begin
            VendorLedEntry.Reset();
            VendorLedEntry.SetCurrentKey("Document No.");
            VendorLedEntry.SetRange("Document No.", RecordToPost."Applies-to Doc. No.");
            if VendorLedEntry.FindFirst() then
                if VendorLedEntry."External Document No." <> '' then
                    GenJournalLine."External Document No." := VendorLedEntry."External Document No."
                else
                    GenJournalLine."External Document No." := VendorLedEntry."Document No.";

        end;

        if RecordToPost."Dimension 1" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 1 Code", RecordToPost."Dimension 1");
        if RecordToPost."Dimension 2" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 2 Code", RecordToPost."Dimension 2");
        if RecordToPost."Dimension 3" <> '' then
            GenJournalLine.ValidateShortcutDimCode(3, RecordToPost."Dimension 3");
        if RecordToPost."Dimension 4" <> '' then
            GenJournalLine.ValidateShortcutDimCode(4, RecordToPost."Dimension 4");
        if RecordToPost."Dimension 5" <> '' then
            GenJournalLine.ValidateShortcutDimCode(5, RecordToPost."Dimension 5");
        if RecordToPost."Dimension 6" <> '' then
            GenJournalLine.ValidateShortcutDimCode(6, RecordToPost."Dimension 6");
        if RecordToPost."Dimension 7" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 7");
        if RecordToPost."Dimension 8" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 8");

        RecordToPost.Status := RecordToPost.Status::Created;
        RecordToPost.Modify();

        GenJournalLine.Insert();

    end;

    local procedure CreatePaymentTaxAJournal(var RecordToPost: Record IntPurchVoidPayment)
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CADBRPayTaxMgt: Codeunit "CADBR Payment Tax Mgt";
        GJL: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        GJL.Reset();
        GJL.SetRange("Journal Template Name", RecordToPost."Journal Template Name");
        GJL.SetRange("Journal Batch Name", RecordToPost."Journal Batch Name");
        if GJL.FindLast() then
            LineNo := GJL."Line No." + 10000
        else
            LineNo := 10000;

        RecordToPost."Journal Line No." := LineNo;
        RecordToPost.Modify();

        GenJournalLine.Reset();
        GenJournalLine.InitNewLine(RecordToPost."Posting Date", RecordToPost."Posting Date", RecordToPost."Posting Date",
                                     RecordToPost.Description, RecordToPost."dimension 1",
                                     RecordToPost."dimension 2", 0, '');

        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := RecordToPost."Journal Line No.";
        GenJournalLine."Account Type" := RecordToPost."Account Type";
        GenJournalLine."Account No." := RecordToPost."Account No.";

        //Valor
        GenJournalLine.VALIDATE(Amount, RecordToPost."Tax Amount");

        GenJournalLine."Applies-to Doc. No." := RecordToPost."Applies-to Doc. No.";
        //GenJournalLine."Applies-to Doc. Type" := RecordToPost."Applies-to Doc. Type"::Payment;
        //GenJournalLine."Bal. Account No." := RecordToPost."Bal. Account No.";
        //GenJournalLine."Bal. Account Type" := RecordToPost."Bal. Account Type";
        GenJournalLine."Document No." := RecordToPost."Document No.";
        GenJournalLine."Document Type" := RecordToPost."Document Type";

        if RecordToPost."Applies-to Doc. No." <> '' then begin
            VendorLedEntry.Reset();
            VendorLedEntry.SetCurrentKey("Document No.");
            VendorLedEntry.SetRange("Document No.", RecordToPost."Applies-to Doc. No.");
            if VendorLedEntry.FindFirst() then
                if VendorLedEntry."External Document No." <> '' then
                    GenJournalLine."External Document No." := VendorLedEntry."External Document No."
                else
                    GenJournalLine."External Document No." := VendorLedEntry."Document No.";

        end;

        if RecordToPost."Dimension 1" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 1 Code", RecordToPost."Dimension 1");
        if RecordToPost."Dimension 2" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 2 Code", RecordToPost."Dimension 2");
        if RecordToPost."Dimension 3" <> '' then
            GenJournalLine.ValidateShortcutDimCode(3, RecordToPost."Dimension 3");
        if RecordToPost."Dimension 4" <> '' then
            GenJournalLine.ValidateShortcutDimCode(4, RecordToPost."Dimension 4");
        if RecordToPost."Dimension 5" <> '' then
            GenJournalLine.ValidateShortcutDimCode(5, RecordToPost."Dimension 5");
        if RecordToPost."Dimension 6" <> '' then
            GenJournalLine.ValidateShortcutDimCode(6, RecordToPost."Dimension 6");
        if RecordToPost."Dimension 7" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 7");
        if RecordToPost."Dimension 8" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 8");

        RecordToPost.Status := RecordToPost.Status::Created;
        RecordToPost.Modify();

        GenJournalLine.Insert();

    end;

    local procedure CreatePaymentTaxBJournal(var RecordToPost: Record IntPurchVoidPayment)
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CADBRPayTaxMgt: Codeunit "CADBR Payment Tax Mgt";
        GJL: Record "Gen. Journal Line";
        LineNo: Integer;
    begin

        GJL.Reset();
        GJL.SetRange("Journal Template Name", RecordToPost."Journal Template Name");
        GJL.SetRange("Journal Batch Name", RecordToPost."Journal Batch Name");
        if GJL.FindLast() then
            LineNo := GJL."Line No." + 10000
        else
            LineNo := 10000;

        RecordToPost."Journal Line No." := LineNo;
        RecordToPost.Modify();

        GenJournalLine.Reset();
        GenJournalLine.InitNewLine(RecordToPost."Posting Date", RecordToPost."Posting Date", RecordToPost."Posting Date",
                                     RecordToPost.Description, RecordToPost."dimension 1",
                                     RecordToPost."dimension 2", 0, '');

        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := RecordToPost."Journal Line No.";
        GenJournalLine."Account Type" := RecordToPost."Account Type";
        GenJournalLine."Account No." := RecordToPost."Tax Account No.";

        //Valor
        GenJournalLine.VALIDATE(Amount, Abs(RecordToPost."Tax Amount"));

        GenJournalLine."Applies-to Doc. No." := RecordToPost."Applies-to Doc. No.";
        //GenJournalLine."Applies-to Doc. Type" := RecordToPost."Applies-to Doc. Type"::Payment;
        //GenJournalLine."Bal. Account No." := RecordToPost."Bal. Account No.";
        //GenJournalLine."Bal. Account Type" := RecordToPost."Bal. Account Type";
        GenJournalLine."Document No." := RecordToPost."Document No.";
        GenJournalLine."Document Type" := RecordToPost."Document Type";

        if RecordToPost."Applies-to Doc. No." <> '' then begin
            VendorLedEntry.Reset();
            VendorLedEntry.SetCurrentKey("Document No.");
            VendorLedEntry.SetRange("Document No.", RecordToPost."Applies-to Doc. No.");
            if VendorLedEntry.FindFirst() then
                if VendorLedEntry."External Document No." <> '' then
                    GenJournalLine."External Document No." := VendorLedEntry."External Document No."
                else
                    GenJournalLine."External Document No." := VendorLedEntry."Document No.";

        end;

        if RecordToPost."Dimension 1" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 1 Code", RecordToPost."Dimension 1");
        if RecordToPost."Dimension 2" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 2 Code", RecordToPost."Dimension 2");
        if RecordToPost."Dimension 3" <> '' then
            GenJournalLine.ValidateShortcutDimCode(3, RecordToPost."Dimension 3");
        if RecordToPost."Dimension 4" <> '' then
            GenJournalLine.ValidateShortcutDimCode(4, RecordToPost."Dimension 4");
        if RecordToPost."Dimension 5" <> '' then
            GenJournalLine.ValidateShortcutDimCode(5, RecordToPost."Dimension 5");
        if RecordToPost."Dimension 6" <> '' then
            GenJournalLine.ValidateShortcutDimCode(6, RecordToPost."Dimension 6");
        if RecordToPost."Dimension 7" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 7");
        if RecordToPost."Dimension 8" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 8");

        RecordToPost.Status := RecordToPost.Status::Created;
        RecordToPost.Modify();

        GenJournalLine.Insert();

    end;

    procedure PostPaymentJournal(var IntPurchVoidPayment: Record IntPurchVoidPayment): Boolean;
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostIntPurchVoidPayment: Record IntPurchVoidPayment;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin

        PostIntPurchVoidPayment.Reset();
        PostIntPurchVoidPayment.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
        PostIntPurchVoidPayment.CopyFilters(IntPurchVoidPayment);
        PostIntPurchVoidPayment.SetRange(Status, PostIntPurchVoidPayment.Status::Created);
        if not PostIntPurchVoidPayment.IsEmpty then begin
            PostIntPurchVoidPayment.FindSet();
            GenJournalLine.SetRange("Journal Template Name", PostIntPurchVoidPayment."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", PostIntPurchVoidPayment."Journal Batch Name");
            if GenJournalLine.FindSet() then begin
                repeat

                    if ProcessLines(GenJournalLine) then begin
                        GenJnlPostBatch.SetPreviewMode(false);
                        GenJnlPostBatch.Run(GenJournalLine);
                    end;

                until GenJournalLine.Next() = 0;
            end;
        end;
    end;


    procedure ProcessLines(var GenJnlLine: Record "Gen. Journal Line"): Boolean
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        Gen: Codeunit "Gen. Jnl.-Check Line";
        PostIntPurchVoidPayment: Record IntPurchVoidPayment;
        Text001: Label ' is not within your range of allowed posting dates';
    begin
        repeat

            if Gen.DateNotAllowed(GenJnlLine."Posting Date", GenJnlLine."Journal Template Name") then begin

                PostIntPurchVoidPayment.Reset();
                PostIntPurchVoidPayment.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                PostIntPurchVoidPayment.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                PostIntPurchVoidPayment.SetRange("Journal Line No.", GenJnlLine."Line No.");
                if PostIntPurchVoidPayment.FindFirst() then begin
                    PostIntPurchVoidPayment."Posting Message" := Format(GenJnlLine."Posting Date") + Text001;
                    PostIntPurchVoidPayment.Status := PostIntPurchVoidPayment.Status::"Data Error";
                    PostIntPurchVoidPayment.Modify();

                end;
                exit(false);
            end else
                exit(true);

        until GenJnlLine.Next() = 0;

    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        RecordToCheck: Record IntPurchVoidPayment;
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + ' ' + OldMessage, 1, MaxStrLen(RecordToCheck."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")));
    end;

    local procedure CallCheckData()
    var
        IntPurchVoidPayment: Record IntPurchVoidPayment;
        FileToProcessTMP: Record IntPurchVoidPayment temporary;
        LastFile: Text;
    begin
        IntPurchVoidPayment.SetFilter(Status, '%1|%2', IntPurchVoidPayment.Status::Imported, IntPurchVoidPayment.Status::"Data Error");
        if not IntPurchVoidPayment.IsEmpty then begin
            IntPurchVoidPayment.FindSet();
            repeat
                if LastFile <> IntPurchVoidPayment."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchVoidPayment."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchVoidPayment.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                CheckData(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    local procedure CallPostJournal()
    var
        IntPurchVoidPayment: Record IntPurchVoidPayment;
        FileToProcessTMP: Record IntPurchVoidPayment temporary;
        LastFile: Text;
    begin
        IntPurchVoidPayment.SetRange(Status, IntPurchVoidPayment.Status::Created);
        if not IntPurchVoidPayment.IsEmpty then begin
            IntPurchVoidPayment.FindSet();
            repeat
                if LastFile <> IntPurchVoidPayment."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchVoidPayment."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchVoidPayment.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                PostPaymentJournal(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    local procedure CheckTax(var RecordToCheck: Record IntPurchVoidPayment)
    var
        VLE: Record "Vendor Ledger Entry";
    begin
        VLE.Reset();
        VLE.SetRange("Document No.", RecordToCheck."Purchase Document No");
        VLE.SetRange(Open, false);
        VLE.SetFilter("CADBR Tax Jurisdiction Code", '<>%1', '');
        if VLE.FindFirst() then begin
            RecordToCheck."Tax Paid" := true;
        end;

    end;

    procedure UnapplyPaymentVoidJournal(var VoidToUnapply: Record IntPurchVoidPayment): Boolean;
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        RecordTocheck: Record IntPurchVoidPayment;
        PaymentLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VLE: Record "Vendor Ledger Entry";
        ErrorPay: Boolean;
        TextLabel0001: Label 'Pagamento não localizado para Desaplicação do Cliente %1 - Tipo de documento %2 - Documento %3 - Aplicação %4';
        TextLabel0002: Label 'Pagamento já Desaplicado do Cliente %1 - Tipo de documento %2 - Documento %3 - Aplicação %4';
        UserSetup: codeunit "User Setup Management";
        ErrorDate: Text;
    begin
        RecordTocheck.Reset();
        RecordTocheck.SetCurrentKey("Account No.", "Vendor Ledger Entry No.");
        RecordTocheck.CopyFilters(VoidToUnapply);
        RecordTocheck.SetFilter(Status, '%1|%2', RecordTocheck.Status::Imported, RecordTocheck.Status::"Data Error");
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                Clear(ErrorPay);

                if not UserSetup.TestAllowedPostingDate(RecordTocheck."Posting Date", ErrorDate) then begin
                    RecordTocheck.Status := RecordTocheck.Status::"Data Error";
                    RecordTocheck."Posting Message" := CopyStr(ErrorDate, 1, 200);

                end else begin

                    VLE.Reset();
                    VLE.SetRange("Document No.", RecordTocheck."Applies-to Doc. No.");
                    VLE.SetFilter("CADBR Tax Jurisdiction Code", '<>%1', '');
                    VLE.SetRange("SBA Applies-to Doc. No.", RecordTocheck."Purchase Document No");
                    if VLE.FindFirst() then begin
                        vle.CalcFields(Amount);

                        RecordTocheck."Tax Amount" := VLE.Amount;
                        RecordTocheck."Tax Account No." := VLE."Vendor No.";
                    end;

                    PaymentLedgerEntry.Reset();
                    PaymentLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
                    PaymentLedgerEntry.SetRange("Vendor No.", RecordTocheck."Account No.");
                    PaymentLedgerEntry.SetRange("Document Type", RecordTocheck."Document Type"::" ");
                    PaymentLedgerEntry.SetRange("Document No.", RecordTocheck."Applies-to Doc. No.");
                    PaymentLedgerEntry.SetRange("SBA Applies-to Doc. No.", RecordTocheck."Purchase Document No");
                    if PaymentLedgerEntry.FindFirst() then begin

                        DetailedVendorLedgEntry.Reset();
                        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", Unapplied);
                        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PaymentLedgerEntry."Entry No.");
                        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
                        DetailedVendorLedgEntry.SetRange(Unapplied, false);
                        if DetailedVendorLedgEntry.FindFirst() then begin

                            ClearLastError();

                            UnapplyPayTaxVoid(RecordTocheck, DetailedVendorLedgEntry);
                            RecordTocheck."Posting Message" := GetLastErrorText();
                        end;

                    end;

                    PaymentLedgerEntry.Reset();
                    PaymentLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
                    PaymentLedgerEntry.SetRange("Vendor No.", RecordTocheck."Account No.");
                    PaymentLedgerEntry.SetRange("Document Type", RecordTocheck."Document Type"::Payment);
                    PaymentLedgerEntry.SetRange("Document No.", RecordTocheck."Applies-to Doc. No.");
                    PaymentLedgerEntry.SetRange("SBA Applies-to Doc. No.", RecordTocheck."Purchase Document No");
                    if not PaymentLedgerEntry.FindFirst() then begin
                        RecordTocheck."Posting Message" := StrSubstNo(TextLabel0001, RecordTocheck."Account No.", RecordTocheck."Document Type"::Payment,
                                                                      RecordTocheck."Applies-to Doc. No.", RecordTocheck."Purchase Document No");
                        RecordTocheck.Status := RecordTocheck.Status::"Data Error";
                        ErrorPay := true;
                    end else begin

                        DetailedVendorLedgEntry.Reset();
                        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", Unapplied);
                        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PaymentLedgerEntry."Entry No.");
                        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
                        DetailedVendorLedgEntry.SetRange(Unapplied, false);
                        if not DetailedVendorLedgEntry.FindFirst() then
                            RecordTocheck.Status := RecordTocheck.Status::Unapply
                        // RecordTocheck."Posting Message" := StrSubstNo(TextLabel0002, RecordTocheck."Account No.", RecordTocheck."Document Type"::Payment,
                        //                                               RecordTocheck."Applies-to Doc. No.", RecordTocheck."Purchase Document No")
                        else begin

                            Clear(ApplyUnapplyParameters);
                            GLSetup.GetRecordOnce();
                            if GLSetup."Journal Templ. Name Mandatory" then begin
                                GLSetup.TestField("Apply Jnl. Template Name");
                                GLSetup.TestField("Apply Jnl. Batch Name");
                                ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                                ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                                GenJnlBatch.Get(GLSetup."Apply Jnl. Template Name", GLSetup."Apply Jnl. Batch Name");
                            end;

                            ClearLastError();
                            if RecordTocheck."Posting Message" = '' then
                                UnapplyPayTaxVoid(RecordTocheck, DetailedVendorLedgEntry);


                            if RecordTocheck."Tax Paid" = true then
                                ApplyPayTaxVoid(RecordTocheck);

                        end;

                    end;


                    if GetLastErrorText() <> '' then
                        RecordTocheck."Posting Message" := GetLastErrorText();

                    RecordTocheck.CalcFields("Detail Ledger Document No.");
                    if ErrorPay = false then
                        if (RecordTocheck."Posting Message" <> '') and (RecordTocheck."Detail Ledger Document No." <> 0) then
                            RecordTocheck.Status := RecordTocheck.Status::"Error Unapply"
                        else
                            RecordTocheck.Status := RecordTocheck.Status::Unapply;

                    RecordTocheck.Modify();

                    Commit();

                end;

            until RecordTocheck.Next() = 0;

        end;
    end;

    [TryFunction]
    procedure UnapplyPayTaxVoid(var RecordTocheck: Record IntPurchVoidPayment; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        PaymentLedgerEntry: Record "Vendor Ledger Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin

        ApplyUnapplyParameters."Document No." := RecordTocheck."Applies-to Doc. No.";
        //ApplyUnapplyParameters."Posting Date" := DetailedVendorLedgEntry."Posting Date";
        ApplyUnapplyParameters."Posting Date" := RecordTocheck."Posting Date";

        VendEntryApplyPostedEntries.PostUnApplyVendor(DetailedVendorLedgEntry, ApplyUnapplyParameters);

    end;

    [TryFunction]
    local procedure ApplyPayTaxVoid(var RecordToAplly: Record IntPurchVoidPayment)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        ApplyID: Text;
        ApplicationDate: Date;
        GLSetup: Record "General Ledger Setup";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
    begin
        ApplyID := 'INTPAYMENT' + FORMAT(CURRENTDATETIME, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Thousands>');
        ApplyID := CopyStr(ApplyID, 1, MaxStrLen(PaymentLedger."Applies-to ID"));

        DocumentLedger.Reset();
        DocumentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
        DocumentLedger.SetRange("Vendor No.", RecordToAplly."Account No.");
        DocumentLedger.SetRange("Document Type", RecordToAplly."Document Type"::" ");
        DocumentLedger.SetRange("Document No.", RecordToAplly."Applies-to Doc. No.");
        DocumentLedger.SetRange("SBA Applies-to Doc. No.", RecordToAplly."Purchase Document No");
        if not DocumentLedger.IsEmpty then begin
            DocumentLedger.FindSet();

            PaymentLedger.Reset();
            PaymentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
            PaymentLedger.SetRange("Vendor No.", RecordToAplly."Account No.");
            //PaymentLedger.SetRange("Document Type", RecordToFilter."Document Type");
            PaymentLedger.SetRange("Document No.", RecordToAplly."Purchase Document No");
            PaymentLedger.SetRange(Open, true);
            if not PaymentLedger.IsEmpty then begin
                PaymentLedger.FindSet();
                PaymentLedger.CalcFields(Amount);
                DocumentLedger.CalcFields(Amount);
                DocumentLedger."Applying Entry" := true;
                DocumentLedger."Applies-to ID" := ApplyID;
                PaymentLedger."Applies-to ID" := ApplyID;
                DocumentLedger.CalcFields("Remaining Amount");
                DocumentLedger.Validate("Amount to Apply", DocumentLedger."Remaining Amount");
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", DocumentLedger);
                Commit();
                VendEntrySetApplID.SetApplId(PaymentLedger, DocumentLedger, ApplyID);
                ApplicationDate := VendEntryApplyPostedEntries.GetApplicationDate(DocumentLedger);

                GLSetup.Get();
                if GLSetup."Journal Templ. Name Mandatory" then begin
                    GLSetup.TestField("Apply Jnl. Template Name");
                    GLSetup.TestField("Apply Jnl. Batch Name");
                    ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                    ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                end;

                ApplyUnapplyParameters."Posting Date" := RecordToAplly."Posting Date";

                VendEntryApplyPostedEntries.Apply(DocumentLedger, ApplyUnapplyParameters);


            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnCheckUnappliedEntriesOnBeforeUnapplyAllEntriesError', '', false, false)]
    local procedure OnCheckUnappliedEntriesOnBeforeUnapplyAllEntriesError(var IsHandled: Boolean)
    var
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterPostGenJournalLine', '', false, false)]
    local procedure Codeunit_13_OnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean)
    var
        IntPurchVoidPayment: Record IntPurchVoidPayment;
        Vat: Record "VAT Entry";
    begin

        if Result then begin

            IntPurchVoidPayment.Reset();
            IntPurchVoidPayment.setrange("Journal Template Name", GenJournalLine."Journal Template Name");
            IntPurchVoidPayment.setrange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            IntPurchVoidPayment.SetRange("Journal Line No.", GenJournalLine."Line No.");
            IntPurchVoidPayment.SetRange("Document No.", GenJournalLine."Document No.");
            if IntPurchVoidPayment.FindFirst() then begin

                IntPurchVoidPayment.Status := IntPurchVoidPayment.Status::Posted;
                IntPurchVoidPayment."Journal Line No." := 0;
                IntPurchVoidPayment.Modify();

                if IntPurchVoidPayment."Tax Paid" = false then begin
                    Vat.Reset();
                    Vat.SetCurrentKey("Document No.", "Posting Date");
                    vat.SetRange("Document No.", IntPurchVoidPayment."Purchase Document No");
                    Vat.SetFilter("CADBR Payment/Receipt Base", '<>%1', 0);
                    if Vat.FindSet() then begin
                        repeat
                            vat.Base := 0;
                            vat."CADBR Payment Date" := 0D;
                            vat.Amount := 0;
                            vat.Modify();
                        until vat.Next() = 0;
                    end;
                end;
            end;

        end;

    end;


    procedure PostUnApplyVendorCommit(DtldVendLedgEntry2: Record "Detailed Vendor Ledg. Entry"; var VoidToUna: Record IntPurchVoidPayment)
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin

        if DtldVendLedgEntry2."Transaction No." = 0 then begin
            DtldVendLedgEntry.SetCurrentKey("Application No.", "Vendor No.", "Entry Type");
            DtldVendLedgEntry.SetRange("Application No.", DtldVendLedgEntry2."Application No.");
        end else begin
            DtldVendLedgEntry.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
            DtldVendLedgEntry.SetRange("Transaction No.", DtldVendLedgEntry2."Transaction No.");
        end;
        DtldVendLedgEntry.SetRange("Vendor No.", DtldVendLedgEntry2."Vendor No.");
        DtldVendLedgEntry.SetFilter("Entry Type", '<>%1', DtldVendLedgEntry."Entry Type"::"Initial Entry");
        DtldVendLedgEntry.SetRange(Unapplied, false);

        if DtldVendLedgEntry.Find('-') then
            repeat

                if DtldVendLedgEntry."Transaction No." <> 0 then
                    CheckUnappliedEntries(DtldVendLedgEntry, VoidToUna);
            until DtldVendLedgEntry.Next() = 0;

    end;

    local procedure CheckUnappliedEntries(DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; var VoidToUna2: Record IntPurchVoidPayment)
    var
        LastTransactionNo: Integer;
        IsHandled: Boolean;
    begin
        if DtldVendLedgEntry."Entry Type" = DtldVendLedgEntry."Entry Type"::Application then begin
            LastTransactionNo := FindLastApplTransactionEntry(DtldVendLedgEntry."Vendor Ledger Entry No.");

            if (LastTransactionNo <> 0) and (LastTransactionNo <> DtldVendLedgEntry."Transaction No.") then
                InsertUnappliedEntries(DtldVendLedgEntry, VoidToUna2);
        end;
        LastTransactionNo := FindLastTransactionNo(DtldVendLedgEntry."Vendor Ledger Entry No.");
        if (LastTransactionNo <> 0) and (LastTransactionNo <> DtldVendLedgEntry."Transaction No.") then
            InsertUnappliedEntries(DtldVendLedgEntry, VoidToUna2);
    end;

    local procedure FindLastTransactionNo(VendLedgEntryNo: Integer): Integer
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        LastTransactionNo: Integer;
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntryNo);
        DtldVendLedgEntry.SetRange(Unapplied, false);
        DtldVendLedgEntry.SetFilter(
            "Entry Type", '<>%1&<>%2',
            DtldVendLedgEntry."Entry Type"::"Unrealized Loss", DtldVendLedgEntry."Entry Type"::"Unrealized Gain");
        LastTransactionNo := 0;
        if DtldVendLedgEntry.FindSet() then
            repeat
                if LastTransactionNo < DtldVendLedgEntry."Transaction No." then
                    LastTransactionNo := DtldVendLedgEntry."Transaction No.";
            until DtldVendLedgEntry.Next() = 0;
        exit(LastTransactionNo);
    end;

    local procedure FindLastApplTransactionEntry(VendLedgEntryNo: Integer): Integer
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        LastTransactionNo: Integer;
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntryNo);
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
        LastTransactionNo := 0;
        if DtldVendLedgEntry.Find('-') then
            repeat
                if (DtldVendLedgEntry."Transaction No." > LastTransactionNo) and not DtldVendLedgEntry.Unapplied then
                    LastTransactionNo := DtldVendLedgEntry."Transaction No.";
            until DtldVendLedgEntry.Next() = 0;
        exit(LastTransactionNo);
    end;

    procedure TransUnapplyPaymentVoidJournal(var VoidToUnapply: Record IntPurchVoidPayment): Boolean;
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        RecordTocheck: Record IntPurchVoidPayment;
        PaymentLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VLE: Record "Vendor Ledger Entry";
        TextLabel0001: Label 'Pagamento não localizado para Desaplicação do Cliente %1 - Tipo de documento %2 - Documento %3 - Aplicação %4';
        TextLabel0002: Label 'Pagamento já Desaplicado do Cliente %1 - Tipo de documento %2 - Documento %3 - Aplicação %4';
        UserSetup: codeunit "User Setup Management";
        ErrorDate: Text;
    begin

        RecordTocheck.Reset();
        RecordTocheck.SetCurrentKey("Account No.", "Vendor Ledger Entry No.");
        RecordTocheck.CopyFilters(VoidToUnapply);
        RecordTocheck.SetFilter(Status, '%1|%2', RecordTocheck.Status::Imported, RecordTocheck.Status::"Data Error");
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat

                if not UserSetup.TestAllowedPostingDate(RecordTocheck."Posting Date", ErrorDate) then begin
                    RecordTocheck.Status := RecordTocheck.Status::"Data Error";
                    RecordTocheck."Posting Message" := CopyStr(ErrorDate, 1, 200);

                end else begin

                    RecordTocheck."Posting Message" := '';

                    PaymentLedgerEntry.Reset();
                    PaymentLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
                    PaymentLedgerEntry.SetRange("Vendor No.", RecordTocheck."Account No.");
                    PaymentLedgerEntry.SetRange("Document Type", RecordTocheck."Document Type"::" ");
                    PaymentLedgerEntry.SetRange("Document No.", RecordTocheck."Applies-to Doc. No.");
                    PaymentLedgerEntry.SetRange("SBA Applies-to Doc. No.", RecordTocheck."Purchase Document No");
                    if PaymentLedgerEntry.FindFirst() then begin

                        DetailedVendorLedgEntry.Reset();
                        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", Unapplied);
                        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PaymentLedgerEntry."Entry No.");
                        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
                        DetailedVendorLedgEntry.SetRange(Unapplied, false);
                        if DetailedVendorLedgEntry.FindFirst() then begin
                            PostUnApplyVendorCommit(DetailedVendorLedgEntry, RecordTocheck);

                        end;

                    end;

                end;

                RecordTocheck.Modify();

                Commit();

            until RecordTocheck.Next() = 0;

        end;
    end;

    local procedure InsertUnappliedEntries(DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; var VoidToUna3: Record IntPurchVoidPayment)
    var
        VoidTrans: Record IntPurchVoidPayTrans;
        OldVoidTrans: Record IntPurchVoidPayTrans;
        VendLed: Record "Vendor Ledger Entry";
        PaymentLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        LineNo: Integer;
    begin

        OldVoidTrans.Reset();
        OldVoidTrans.SetRange("Journal Template Name", VoidToUna3."Journal Template Name");
        OldVoidTrans.SetRange("Journal Batch Name", VoidToUna3."Journal Batch Name");
        OldVoidTrans.SetRange("Line No.", VoidToUna3."Line No.");
        OldVoidTrans.SetRange("Excel File Name", VoidToUna3."Excel File Name");
        if OldVoidTrans.FindLast() then
            LineNo := OldVoidTrans."Trans Line No." + 1
        else
            LineNo := 1;

        OldVoidTrans.Reset();
        OldVoidTrans.SetRange("Journal Template Name", VoidToUna3."Journal Template Name");
        OldVoidTrans.SetRange("Journal Batch Name", VoidToUna3."Journal Batch Name");
        OldVoidTrans.SetRange("Line No.", VoidToUna3."Line No.");
        OldVoidTrans.SetRange("Excel File Name", VoidToUna3."Excel File Name");
        OldVoidTrans.SetRange("Trans Vendor Ledger Entry No.", DtldVendLedgEntry."Vendor Ledger Entry No.");
        if not OldVoidTrans.FindSet() then begin

            VoidTrans.Init();
            VoidTrans.TransferFields(VoidToUna3);
            VoidTrans."Trans Line No." := LineNo;
            VoidTrans."Trans Vendor Ledger Entry No." := DtldVendLedgEntry."Vendor Ledger Entry No.";
            VendLed.get(DtldVendLedgEntry."Vendor Ledger Entry No.");
            VoidTrans."Trans. Document No." := VendLed."Document No.";
            VoidTrans.Insert();

            VoidToUna3.Status := VoidToUna3.Status::"Error Unapply";
            VoidToUna3."Posting Message" := 'Um ou mais movimentos para desaplicar, seguir com o processo manual';
            VoidToUna3.Modify();

            PaymentLedgerEntry.Reset();
            if PaymentLedgerEntry.Get(DtldVendLedgEntry."Vendor Ledger Entry No.") then begin

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", Unapplied);
                DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PaymentLedgerEntry."Entry No.");
                DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
                DetailedVendorLedgEntry.SetRange(Unapplied, false);
                if DetailedVendorLedgEntry.FindFirst() then
                    PostUnApplyVendorCommit(DetailedVendorLedgEntry, VoidToUna3);

            end;

        end else begin

            VoidToUna3.Status := VoidToUna3.Status::"Error Unapply";
            VoidToUna3."Posting Message" := 'Um ou mais movimentos para desaplicar, seguir com o processo manual';
            VoidToUna3.Modify();

        end;
    end;
}
