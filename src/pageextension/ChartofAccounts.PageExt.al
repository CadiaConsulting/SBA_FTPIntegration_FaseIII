pageextension 50036 "SBA Chart of Accounts" extends "Chart of Accounts"
{
    actions
    {
        addafter("CADBR Trial Balance (Brazil)")
        {

            action(Complete)
            {
                Caption = 'General Ledger Complete';
                ApplicationArea = all;
                Image = Report;
                RunObject = report "General Ledger Complete";
            }
            action(Reduzed)
            {
                Caption = 'General Ledger Reduced';
                ApplicationArea = all;
                Image = Report;
                RunObject = report "General Ledger Reduced";
            }
        }
    }
}
