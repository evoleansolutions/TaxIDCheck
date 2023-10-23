page 50002 TaxIDRequestLogs_EWO
{
    Caption = 'Tax ID Request Logs';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = TaxIDRequestLogs_EWO;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                { ApplicationArea = All; }
                field("Request DateTime"; Rec."Request DateTime")
                { ApplicationArea = All; }
                field("Requested Tax ID"; Rec."Requested Tax ID")
                { ApplicationArea = All; }
                field("Requested Field"; Rec."Requested Field")
                { ApplicationArea = All; }
                field("Response Code"; Rec."Response Code")
                { ApplicationArea = All; }
                field("Response Description"; Rec."Response Description")
                { ApplicationArea = All; }
            }
        }
    }
}