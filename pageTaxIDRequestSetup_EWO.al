
page 50000 "TaxIDRequestSetup_EWO"
{
    Caption = 'Tax ID Request Setup';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TaxIDRequestSetup_EWO";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Request ID"; Rec.CallID)
                { ApplicationArea = All; }
                field(URL; Rec.API_URL)
                { ApplicationArea = All; }
                field("Success Code"; Rec."Success Code")
                { ApplicationArea = All; }
                field("XML Error Tag"; Rec."XML Error Tag")
                { ApplicationArea = All; }
                field("Control Period"; Rec."Control Period")
                { ApplicationArea = All; }
                field("Name Check Tag"; Rec."Name Check Tag")
                { ApplicationArea = All; }
                field("City Check Tag"; Rec."City Check Tag")
                { ApplicationArea = All; }
                field("Post Code Check Tag"; Rec."Post Code Check Tag")
                { ApplicationArea = All; }
                field("Street Check Tag"; Rec."Street Check Tag")
                { ApplicationArea = All; }
            }

        }

    }
    actions
    {
        area(Processing)
        {
            action("Call API")
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    Customer.GET('D00020 ');
                    APICodeunit.ValidateRequest(0, Customer."No.");
                end;
            }
        }
    }
    var
        Customer: Record Customer;
        APICodeunit: Codeunit "TaxIDRequest_EWO";

}
