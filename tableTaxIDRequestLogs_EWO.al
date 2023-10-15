table 50002 TaxIDRequestLogs_EWO
{
    Caption = 'Tax ID Request Logs';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Request DateTime"; DateTime)
        { DataClassification = ToBeClassified; }
        field(3; "Requested Tax ID"; Text[30])
        { DataClassification = ToBeClassified; }
        field(4; "Response Code"; Text[30])
        { DataClassification = ToBeClassified; }
        field(5; "Response Description"; Text[250])
        { DataClassification = ToBeClassified; }
        field(6; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Customer,Vendor;
        }
        field(7; "Account No."; Code[20])
        { DataClassification = ToBeClassified; }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}