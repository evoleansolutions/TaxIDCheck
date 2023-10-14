
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
                field(URL; rec.API_URL)
                { ApplicationArea = All; }
                field("Success Code"; rec."Success Code")
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
                    APICodeunit.RUN();
                end;
            }
        }
    }
    var
        APICodeunit: Codeunit "TaxIDRequest_EWO";

}
