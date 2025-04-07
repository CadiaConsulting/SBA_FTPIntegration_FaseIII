tableextension 50014 "INTGenJournalLine" extends "Gen. Journal Line"
{
    fields
    {
        field(50000; "Service Delivery City"; Code[7])
        {
            DataClassification = ToBeClassified;
            Caption = 'Service Delivery City';
            TableRelation = "CADBR Municipio";
        }
        field(50001; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }
        field(50002; "Integration Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
    }

}