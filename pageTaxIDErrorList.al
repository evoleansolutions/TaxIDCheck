/// <summary>
/// Page Tax ID Request Error List (ID 50102).
/// </summary>
page 50102 "Tax ID Request Error List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TaxIDRequestErrors";

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