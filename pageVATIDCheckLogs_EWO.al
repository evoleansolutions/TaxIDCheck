page 50002 VATIDCheckLogs_EWO
{
    Caption = 'VAT ID Check Logs';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = VATIDCheckLogs_EWO;
    Editable = false;

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
                field("Requested VAT ID"; Rec."Requested VAT ID")
                { ApplicationArea = All; }
                field("Requested Field"; Rec."Requested Field")
                { ApplicationArea = All; }
                field("Response Code"; Rec."Response Code")
                { ApplicationArea = All; }
                field("Response Description"; Rec."Response Description")
                { ApplicationArea = All; }
                field("Account Value"; Rec."Account Value")
                { ApplicationArea = All; }

            }
        }
    }
}