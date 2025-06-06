tableextension 50020 "SBA CNAB Payment Line" extends "CADBR CNAB Payment Line"
{
    fields
    {
        field(50000; "Documents Applies"; Integer)
        {
            Caption = 'Documents Applies';
            DataClassification = CustomerContent;


            trigger OnLookup()
            var
                vendLedgEntry: Record "Vendor Ledger Entry";
                applyVendEntries: Page "CADBR Apply Vendor Entries";
            begin

                if "Vendor No." <> '' then begin
                    vendLedgEntry.SetCurrentkey("Vendor No.", Open, Positive, "Due Date");
                    vendLedgEntry.SetRange("Vendor No.", "Vendor No.");

                    if "Applies-to Doc. No." <> '' then begin
                        vendLedgEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        vendLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
                        if not vendLedgEntry.Find('-') then begin
                            vendLedgEntry.SetRange("Document Type");
                            vendLedgEntry.SetRange("Document No.");
                        end;
                    end;
                    if "Applies-to ID" <> '' then begin
                        vendLedgEntry.SetRange("Applies-to ID", "Applies-to ID");
                        if not vendLedgEntry.Find('-') then
                            vendLedgEntry.SetRange("Applies-to ID");
                    end;
                    if "Applies-to Doc. Type" <> "applies-to doc. type"::" " then begin
                        vendLedgEntry.SetRange("Document Type", "Applies-to Doc. Type");
                        if not vendLedgEntry.Find('-') then
                            vendLedgEntry.SetRange("Document Type");
                    end;
                    if "Applies-to Doc. No." <> '' then begin
                        vendLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
                        if not vendLedgEntry.Find('-') then
                            vendLedgEntry.SetRange("Document No.");
                    end;

                    applyVendEntries.SetCNABPayment(Rec, FieldNo("Applies-to Doc. No."));
                    applyVendEntries.SetTableview(vendLedgEntry);
                    applyVendEntries.SetRecord(vendLedgEntry);
                    applyVendEntries.LookupMode(true);
                    if applyVendEntries.RunModal = Action::LookupOK then begin


                    end;
                end;
            end;

        }




    }
}
