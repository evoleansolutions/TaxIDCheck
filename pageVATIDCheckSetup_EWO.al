
page 50000 "VATIDCheckSetup_EWO"
{
    Caption = 'VAT ID Check Setup';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "VATIDCheckSetup_EWO";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Request ID"; Rec.CallID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
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
                field("Account Validation"; Rec."Account Validation")
                { ApplicationArea = All; }
            }

        }

    }

    var
        Customer: Record Customer;
        APICodeunit: Codeunit "VATIDCheckRequest_EWO";

}
