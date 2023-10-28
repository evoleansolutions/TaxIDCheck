
page 50001 "VATIDCheckErrorList_EWO"
{
    Caption = 'VAT ID Check Error List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "VATIDCheckErrors_EWO";

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