
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
