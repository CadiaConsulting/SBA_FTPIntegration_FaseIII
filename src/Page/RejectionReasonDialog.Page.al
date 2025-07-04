page 50084 "Rejection Reason Dialog"
{
    PageType = StandardDialog;
    Caption = 'Rejection Reason Dialog';
    Permissions = tabledata "Sales Invoice Header" = RIMD,
                tabledata "Sales Invoice Line" = RIMD;
    layout
    {
        area(content)
        {
            field(RejectionReasonCode; CodeReason)
            {
                ApplicationArea = All;
                Caption = 'Rejection Reason';
                ToolTip = 'Rejection Reason';

                TableRelation = "Rejection Reason";
            }
        }
    }

    var
        CodeReason: Code[10];


    procedure GetReject(): code[10]
    begin
        exit(codeReason);

    end;

}