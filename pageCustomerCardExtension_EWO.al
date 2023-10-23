pageextension 50003 CustomerCardExtension_EWO extends "Customer Card"
{
    layout
    {
        addlast(Invoicing)
        {
            field("VAT ID Validation"; Rec."VAT ID Validation")
            {
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