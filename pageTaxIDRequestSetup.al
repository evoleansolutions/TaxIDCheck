/// <summary>
/// Page Tax ID Request Setup (ID 50101).
/// </summary>
page 50101 "Tax ID Request Setup"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TaxIDRequestSetup";

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
        APICodeunit: Codeunit "Tax ID Request";
}
