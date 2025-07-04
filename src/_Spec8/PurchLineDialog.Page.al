page 50028 "Purch Line Dialog"
{
    PageType = StandardDialog;
    Caption = 'Purch Line Dialog';

    layout
    {
        area(content)
        {
            field(DocumentNo; DocumentNo)
            {
                ApplicationArea = All;
                Caption = 'Document No.';
                ToolTip = 'Document No.';
                Editable = false;
            }
            field(NCMCode; NCMCode)
            {
                ApplicationArea = All;
                Caption = 'NCM Code';
                ToolTip = 'NCM Code';
                TableRelation = "CADBR NCM Code";
                Editable = true;
            }

            field(ServiceCode; ServiceCode)
            {
                ApplicationArea = All;
                Caption = 'Service Code';
                ToolTip = 'Service Code';
                TableRelation = "CADBR NFS Service Code";
                Editable = true;
            }

        }
    }

    var
        DocumentNo: Code[20];
        NCMCode: Code[20];
        ServiceCode: Code[20];


    procedure SetDocumentInfo(NewDocumentNo: Code[20])
    begin
        DocumentNo := NewDocumentNo;

    end;

    procedure SetNCMCode()
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document No.", DocumentNo);
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        if PurchLine.FindSet() then
            repeat
                if NCMCode <> '' then
                    PurchLine.Validate("CADBR NCM Code", NCMCode);

                if ServiceCode <> '' then
                    PurchLine.Validate("CADBR Service Code", ServiceCode);

                PurchLine.Modify();

            until PurchLine.Next() = 0;

    end;
}