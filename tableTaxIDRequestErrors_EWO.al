table 50001 "TaxIDRequestErrors_EWO"
{
    Caption = 'Tax ID Request Errors';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Error Code"; Code[20])
        { DataClassification = ToBeClassified; }
        field(2; "Error Description"; Text[250])
        { DataClassification = ToBeClassified; }
    }

    keys
    {
        key(Key1; "Error Code")
        {
            Clustered = true;
        }
    }
}