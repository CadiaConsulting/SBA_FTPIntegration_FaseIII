tableextension 50019 "SBA CADBR CNAB Payment" extends "CADBR CNAB Payment"
{
    fields
    {
        field(50000; "Qty Total"; Integer)
        {
            Caption = 'Qty Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("CADBR CNAB Payment Line" where("CNAB Payment No." = field("No.")));
        }

        field(50001; "Amount Total"; Decimal)
        {
            Caption = 'Amount Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line".Amount where("CNAB Payment No." = field("No.")));
        }
        field(50002; "Net Amount Total"; Decimal)
        {
            Caption = 'Net Amount Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line"."Net Amount" where("CNAB Payment No." = field("No.")));
        }
        field(50003; "Discount Amount Total"; Decimal)
        {
            Caption = 'Discount Amount Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line"."Discount Amount" where("CNAB Payment No." = field("No.")));
        }
        field(50004; "Charge Amount Total"; Decimal)
        {
            Caption = 'Charge Amount Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line"."Charge Amount" where("CNAB Payment No." = field("No.")));
        }

        field(50005; "Interest Amount Total"; Decimal)
        {
            Caption = 'Interest Amount Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line"."Interest Amount" where("CNAB Payment No." = field("No.")));
        }
        field(50006; "Retained Taxes Total"; Decimal)
        {
            Caption = 'Retained Taxes Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("CADBR CNAB Payment Line"."Retained Taxes" where("CNAB Payment No." = field("No.")));
        }
    }
}
