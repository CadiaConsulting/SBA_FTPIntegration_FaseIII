pageextension 50033 "SBA Tax Area" extends "Tax Area"
{

    layout
    {
        addafter(Description)
        {
            field("CADBR Base Calc. Credit Code"; rec."CADBR Base Calc. Credit Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Base Calc. Credit Code field.';
            }

        }

    }
}
