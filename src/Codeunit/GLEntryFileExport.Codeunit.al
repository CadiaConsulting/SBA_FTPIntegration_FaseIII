Codeunit 50080 "GLEntry File Export"
{

    procedure CreateDateComplete()
    var
        fileExportMgt: Codeunit "CADBR File Export Mgt";
        newText: Text;
        textTmp: Text;
        func: Codeunit "CADBR Fiscal Functions";
        inStream: InStream;
        i: Integer;

    begin
        fileExportMgt.Create;
        LineCount := 1;

        with GLEntry do begin
            Progress.OPEN(Text000);
            Progress.Update(2, format(GLEntry.Count));

            newText := FieldCaption("Posting Date") + ';' +
                        FieldCaption("Document Date") + ';' +
                        FieldCaption("Document Type") + ';' +
                        FieldCaption("Document No.") + ';' +
                        FieldCaption("G/L Account No.") + ';' +
                        FieldCaption("G/L Account Name") + ';' +
                        FieldCaption(Description) + ';' +
                        FieldCaption("Global Dimension 1 Code") + ';' +
                        FieldCaption("Global Dimension 2 Code") + ';' +
                        FieldCaption(Amount) + ';' +
                        FieldCaption("Bal. Account No.") + ';' +
                        FieldCaption("Entry No.") + ';' +
                        FieldCaption("External Document No.") + ';' +
                        FieldCaption("Applies-to Doc. No.") + ';' +
                        FieldCaption("Source Code") + ';' +
                        FieldCaption("CADBR Additional Description") + ';' +
                        FieldCaption("Source Type") + ';' +
                        FieldCaption("Source No.") + ';' +
                        FieldCaption("Shortcut Dimension 3 Code") + ';' +
                        FieldCaption("Shortcut Dimension 4 Code") + ';' +
                        FieldCaption("Shortcut Dimension 5 Code") + ';' +
                        FieldCaption("Shortcut Dimension 6 Code") + ';' +
                        FieldCaption("User ID");

            for i := 1 to StrLen(newText) do
                if not (newText[i] in [10, 13, 9]) then
                    textTmp += CopyStr(newText, i, 1);
            newText := ConvertStr(textTmp, ' ', ' ');
            textTmp := '';

            if newText <> '' then
                fileExportMgt.WriteLine(newText);

            FindSet;
            repeat
                Progress.Update(1, LineCount);
                LineCount += 1;

                newText := Format("Posting Date") + ';' +
                        Format("Document Date") + ';' +
                        Format("Document Type") + ';' +
                        "Document No." + ';' +
                        "G/L Account No." + ';' +
                        "G/L Account Name" + ';' +
                        Description + ';' +
                        "Global Dimension 1 Code" + ';' +
                        "Global Dimension 2 Code" + ';' +
                        Format(Amount) + ';' +
                        "Bal. Account No." + ';' +
                        Format("Entry No.") + ';' +
                        "External Document No." + ';' +
                        "Applies-to Doc. No." + ';' +
                        "Source Code" + ';' +
                        "CADBR Additional Description" + ';' +
                        Format("Source Type") + ';' +
                        "Source No." + ';' +
                        "Shortcut Dimension 3 Code" + ';' +
                        "Shortcut Dimension 4 Code" + ';' +
                        "Shortcut Dimension 5 Code" + ';' +
                        "Shortcut Dimension 6 Code" + ';' +
                        "User ID";

                for i := 1 to StrLen(newText) do
                    if not (newText[i] in [10, 13, 9]) then
                        textTmp += CopyStr(newText, i, 1);
                newText := ConvertStr(textTmp, ' ', ' ');
                textTmp := '';

                if newText <> '' then
                    fileExportMgt.WriteLine(newText);
            until Next = 0;
            Progress.Close();
        end;

        fileExportMgt.Download(Filename);
    end;

    var
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        Filename: Text;
        Progress: Dialog;
        LineCount: Integer;
        Text000: Label 'Processing #1 of #2';

    procedure SetFilterDateComplete(BranchCode: code[20]; StartDate: Date; EndDate: date)
    begin
        GLEntry.Reset();
        GLEntry.SetCurrentKey("Posting Date");
        GLEntry.SetRange("Posting Date", StartDate, EndDate);
        GLEntry.SetRange("CADBR Branch Code", BranchCode);
        Filename := 'GeneralLedgerComplete.txt';
    end;

    procedure SetFilterDateReduced(BranchCode: code[20]; StartDate: Date; EndDate: date)
    begin
        GLEntry.Reset();
        GLEntry.SetCurrentKey("Posting Date");
        GLEntry.SetRange("Posting Date", StartDate, EndDate);
        GLEntry.SetRange("CADBR Branch Code", BranchCode);
        Filename := 'GeneralLedgerReduced.txt';
    end;

    procedure CreateDateReduced()
    var
        fileExportMgt: Codeunit "CADBR File Export Mgt";
        newText: Text;
        textTmp: Text;
        func: Codeunit "CADBR Fiscal Functions";
        inStream: InStream;
        i: Integer;

    begin
        fileExportMgt.Create;

        with GLEntry do begin
            Progress.OPEN(Text000);
            Progress.Update(2, format(GLEntry.Count));

            newText := FieldCaption("Posting Date") + ';' +
                        FieldCaption("Document Date") + ';' +
                        FieldCaption("Document No.") + ';' +
                        FieldCaption("G/L Account No.") + ';' +
                        FieldCaption("G/L Account Name") + ';' +
                        FieldCaption(Description) + ';' +
                        FieldCaption("Global Dimension 2 Code") + ';' +
                        FieldCaption(Amount) + ';' +
                        FieldCaption("Entry No.") + ';' +
                        FieldCaption("External Document No.") + ';' +
                        FieldCaption("CADBR Additional Description") + ';' +
                        FieldCaption("Source No.") + ';' +
                        FieldCaption("Shortcut Dimension 3 Code") + ';' +
                        FieldCaption("Shortcut Dimension 4 Code") + ';' +
                        FieldCaption("Shortcut Dimension 5 Code");

            for i := 1 to StrLen(newText) do
                if not (newText[i] in [10, 13, 9]) then
                    textTmp += CopyStr(newText, i, 1);
            newText := ConvertStr(textTmp, ' ', ' ');
            textTmp := '';

            if newText <> '' then
                fileExportMgt.WriteLine(newText);

            FindSet;
            repeat
                Progress.Update(1, LineCount);
                LineCount += 1;

                newText := Format("Posting Date") + ';' +
                        Format("Document Date") + ';' +
                        "Document No." + ';' +
                        "G/L Account No." + ';' +
                        "G/L Account Name" + ';' +
                        Description + ';' +
                        "Global Dimension 2 Code" + ';' +
                        Format(Amount) + ';' +
                        Format("Entry No.") + ';' +
                        "External Document No." + ';' +
                        "CADBR Additional Description" + ';' +
                        "Source No." + ';' +
                        "Shortcut Dimension 3 Code" + ';' +
                        "Shortcut Dimension 4 Code" + ';' +
                        "Shortcut Dimension 5 Code";

                for i := 1 to StrLen(newText) do
                    if not (newText[i] in [10, 13, 9]) then
                        textTmp += CopyStr(newText, i, 1);
                newText := ConvertStr(textTmp, ' ', ' ');
                textTmp := '';

                if newText <> '' then
                    fileExportMgt.WriteLine(newText);
            until Next = 0;
            Progress.Close();

        end;

        fileExportMgt.Download(Filename);
    end;

}

