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
                    VATIDCheckCall.ShowResponseLogs_AccountCard(Rec."VAT Registration No.");
                end;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action(CheckCustomerAccount)
            {
                ApplicationArea = Basic;
                Caption = 'Check VAT Validation';
                trigger OnAction()
                var
                    VATIDCheckCall: Codeunit VATIDCheckRequest_EWO;
                begin
                    VATIDCheckCall.ValidateRequest(0, Rec."No.");
                end;
            }
        }
    }
    var
        VATIDCheckCall: Codeunit VATIDCheckRequest_EWO;
}