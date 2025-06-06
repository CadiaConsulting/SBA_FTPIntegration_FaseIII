pageextension 50034 "SBA CADBR CNAB Payment" extends "CADBR CNAB Payment"
{
    layout
    {
        addafter(Subpage)
        {
            group(Totals)
            {
                Caption = 'Totals';

                field("Qty Total"; rec."Qty Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Qty Total';
                }
                field("Amount Total"; rec."Amount Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount Total';
                }

                field("Net Amount Total"; rec."Net Amount Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Net Amount Total';
                }
                field("Discount Amount Total"; rec."Discount Amount Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Discount Amount Total';
                }
                field("Charge Amount Total"; rec."Charge Amount Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Charge Amount Total';
                }
                field("Interest Amount Total"; rec."Interest Amount Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Interest Amount Total';
                }
                field("Retained Taxes Total"; rec."Retained Taxes Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Retained Taxes Total';
                }
            }
        }
    }
}
