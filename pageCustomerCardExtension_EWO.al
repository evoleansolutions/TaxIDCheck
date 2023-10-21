pageextension 50003 CustomerCardExtension_EWO extends "Customer Card"
{
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
}