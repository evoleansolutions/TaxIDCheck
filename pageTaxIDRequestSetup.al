page 50101 TaxIDRequestSetup
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = TaxIDRequestSetup;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(RequestID; Rec.CallID)
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
            action(CallAPI)
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
        APICodeunit: Codeunit TaxIDApiRequest;
}
