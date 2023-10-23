pageextension 50003 CustomerCardExtension_EWO extends "Customer Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("VAT ID Validation"; Rec."VAT ID Validation")
            {
                Caption = 'VAT Reg. No. Validation';
                ApplicationArea = All;
                trigger OnAssistEdit()
                begin
                    VatIDRequestCall.ShowResponseLogs_AccountCard(Rec."VAT Registration No.");
                end;
            }
        }
    }
    actions
    {
        addlast(Creation)
        {
            group(VatIDAccountCheck)
            {
                Caption = 'Vat ID Account Check';
                action(CheckCustomerAccount)
                {
                    ApplicationArea = Basic;
                    Caption = 'Check Customer Account';
                    trigger OnAction()
                    var
                        VATIdRequestCall: Codeunit TaxIDRequest_EWO;
                    begin
                        VATIdRequestCall.ValidateRequest(0, Rec."No.");
                    end;
                }
            }
        }
    }
    var
        VatIDRequestCall: Codeunit TaxIDRequest_EWO;
}