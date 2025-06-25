report 50001 "General Ledger Reduced"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'General Ledger Reduced';

    dataset
    {
        dataitem(DataItemName; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            trigger OnAfterGetRecord()
            begin
                if BranchCode = '' then
                    error(ErrorTextBranc);
                if StartDate = 0D then
                    error(ErrorTextStart);
                if StartDate > EndDate then
                    error(ErrorTextStart);
                if EndDate = 0D then
                    error(ErrorTextEnd);
                if EndDate < StartDate then
                    error(ErrorTextEnd);

                GLExport.SetFilterDateReduced(BranchCode, StartDate, EndDate);
                GLExport.CreateDateReduced();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';

                    field(BranchCode; BranchCode)
                    {
                        Caption = 'Branch Code';
                        TableRelation = "CADBR Branch Information";
                        trigger OnValidate()
                        begin
                            if BranchCode = '' then
                                error(ErrorTextBranc);

                        end;
                    }
                    field(StartDate; StartDate)
                    {
                        Caption = 'Start Date';
                        trigger OnValidate()
                        begin
                            if BranchCode = '' then
                                error(ErrorTextBranc);
                            if StartDate = 0D then
                                error(ErrorTextStart);
                        end;
                    }
                    field(EndDate; EndDate)
                    {
                        Caption = 'End Date';
                        trigger OnValidate()
                        begin
                            if BranchCode = '' then
                                error(ErrorTextBranc);
                            if StartDate = 0D then
                                error(ErrorTextStart);
                            if StartDate > EndDate then
                                error(ErrorTextStart);
                            if EndDate = 0D then
                                error(ErrorTextEnd);
                            if EndDate < StartDate then
                                error(ErrorTextEnd);
                        end;

                    }
                }
            }
        }


    }

    var
        StartDate: Date;
        EndDate: Date;
        BranchCode: code[20];
        GLExport: Codeunit "GLEntry File Export";
        ErrorTextBranc: label 'Branch Code cannot be Empty', Comment = 'Branch Code';
        ErrorTextStart: label 'Start Date cannot be Empty', Comment = 'Start Date';
        ErrorTextEnd: label 'End Date cannot be Empty', Comment = 'End Date';
}