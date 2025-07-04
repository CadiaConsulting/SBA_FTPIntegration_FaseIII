pageextension 50035 "SBA CNAB Payment Subform" extends "CADBR CNAB Payment Subform"
{
    layout
    {
        modify(ShortcutDim5)
        {
            Visible = true;
        }

        addafter(PaymentMethodCode)
        {
            field("Documents Applies"; rec."Documents Applies")
            {
                ApplicationArea = All;
                ToolTip = 'Documents Applies';
            }

        }
    }
    trigger OnAfterGetRecord()
    var
        vendLedgEntry: Record "Vendor Ledger Entry";
        applyVendEntries: Page "CADBR Apply Vendor Entries";
    begin

        if (rec."Vendor No." <> '') and ((rec."Applies-to Doc. No." <> '') or (rec."Applies-to ID" <> '')) then begin
            vendLedgEntry.SetCurrentkey("Vendor No.", Open, Positive, "Due Date");
            vendLedgEntry.SetRange("Vendor No.", rec."Vendor No.");

            if rec."Applies-to Doc. No." <> '' then begin
                vendLedgEntry.SetRange("Document Type", rec."Applies-to Doc. Type");
                vendLedgEntry.SetRange("Document No.", rec."Applies-to Doc. No.");
                if not vendLedgEntry.Find('-') then begin
                    vendLedgEntry.SetRange("Document Type");
                    vendLedgEntry.SetRange("Document No.");
                end;
            end;
            if rec."Applies-to ID" <> '' then begin
                vendLedgEntry.SetRange("Applies-to ID", rec."Applies-to ID");
                if not vendLedgEntry.Find('-') then
                    vendLedgEntry.SetRange("Applies-to ID");
            end;
            if rec."Applies-to Doc. Type" <> rec."applies-to doc. type"::" " then begin
                vendLedgEntry.SetRange("Document Type", rec."Applies-to Doc. Type");
                if not vendLedgEntry.Find('-') then
                    vendLedgEntry.SetRange("Document Type");
            end;
            if rec."Applies-to Doc. No." <> '' then begin
                vendLedgEntry.SetRange("Document No.", rec."Applies-to Doc. No.");
                if not vendLedgEntry.Find('-') then
                    vendLedgEntry.SetRange("Document No.");
            end;


            if vendLedgEntry.FindFirst() then begin
                rec."Documents Applies" := vendLedgEntry.Count;


            end;
        end;

    end;
}
