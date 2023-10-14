
page 50001 "TaxIDRequestErrorList_EWO"
{
    Caption = 'Tax ID Request Error List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TaxIDRequestErrors_EWO";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Error Code"; Rec."Error Code")
                { ApplicationArea = All; }
                field("Error Description"; Rec."Error Description")
                { ApplicationArea = All; }
            }
        }
    }
}