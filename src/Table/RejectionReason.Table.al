table 50080 "Rejection Reason"
{
    Caption = 'Rejection Reason';
    DataClassification = CustomerContent;
    DrillDownPageId = "Rejection Reason List";
    LookupPageId = "Rejection Reason List";

    fields
    {
        field(1; Code; code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
    }

}
