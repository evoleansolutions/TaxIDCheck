<<<<<<< HEAD
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
=======
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
>>>>>>> 109e1ac40a46620f17a3051d014986e5c0380a19
