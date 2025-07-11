page 50019 IntSalesCreditNotePosted
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = IntSalesCreditNote;
    SourceTableView = sorting("Excel File Name", "No.", "Line No.") where(Status = filter(Posted | Cancelled));
    Editable = false;
    Caption = 'Integration Sales Credit Memo Posted';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No.';
                }

                field("Sell-to Customer No."; rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Customer No.';
                }

                field("Your Reference"; rec."Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your Reference';
                }
                field("Order Date"; rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Date';
                }
                field("Posting Date"; rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Date';
                }

                field("Document Date"; rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document Date';
                }
                field("External Document No."; rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'External Document No.';
                }
                field("Customer Posting Group"; rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer Posting Group';
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                }
                field("Freight Billed To"; rec."Freight Billed To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Freight Billed To';
                }

                field("Shortcut Dimension 1 Code"; rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 1 Code';
                }
                field("Shortcut Dimension 2 Code"; rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 2 Code';
                }
                field("Shortcut Dimension 3 Code"; rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 3 Code';
                }
                field("Shortcut Dimension 4 Code"; rec."Shortcut Dimension 4 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 4 Code';
                }
                field("Shortcut Dimension 5 Code"; rec."Shortcut Dimension 5 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 5 Code';
                }
                field("Shortcut Dimension 6 Code"; rec."Shortcut Dimension 6 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 6 Code';
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
                }
                field(Type; rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Type';
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No.';
                }

                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }

                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity';
                }
                field("Unit Price"; rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unit Price';
                }

                field("G/L Account"; rec."G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'G/L Account';
                }
                field("Tax From Billing APP (PIS)"; rec."Tax From Billing APP (PIS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax From Billing APP (PIS)';
                }
                field("Tax From Billing APP (COFINS)"; rec."Tax From Billing APP (COFINS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax From Billing APP (COFINS)';
                }
                field("Tax (PIS) Order"; rec."Tax (PIS) Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax (PIS) Order';
                }
                field("Tax (COFINS) Order"; rec."Tax (COFINS) Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax (COFINS) Order';
                }
                field("Tax (PIS) line"; rec."Tax (PIS) Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax (PIS) Line';
                }
                field("Tax (COFINS) Line"; rec."Tax (COFINS) Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax (COFINS) Line';
                }
                field("Posting Message"; rec."Posting Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Message';
                }
                field("Error Order"; rec."Error Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Order';
                }
                field("Errors Import Excel"; rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Import Excel';
                }
                field("Excel File Name"; rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Excel File Name';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(SalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Sales Credit Memo Card';
                Image = Document;
                ToolTip = 'Sales Return Order Card';

                trigger OnAction();
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    if SalesCrMemoHeader.get(rec."No.") then
                        PAGE.Run(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
            }
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer Card';
                Image = Customer;
                ToolTip = 'Customer Card';

                trigger OnAction();
                var
                    Cust: Record Customer;
                begin
                    Cust."No." := rec."Sell-to Customer No.";
                    PAGE.Run(PAGE::"Customer Card", Cust);
                end;
            }
            action(Iten)
            {
                ApplicationArea = All;
                Caption = 'Item Card';
                Image = Item;
                ToolTip = 'Item Card';

                trigger OnAction();
                var
                    Item: Record Item;
                begin
                    Item."No." := rec."Item No.";
                    PAGE.Run(PAGE::"Item Card", Item);
                end;
            }

        }
    }

}