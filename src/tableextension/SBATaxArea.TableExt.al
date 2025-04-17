tableextension 50012 "SBA Tax Area" extends "Tax Area"
{
    fields
    {
        field(50000; "CADBR Base Calc. Credit Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Calculation Credit Code';
            TableRelation = "CADBR Base Calc. Credit Code";
        }
    }
}
