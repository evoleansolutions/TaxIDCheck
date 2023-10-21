table 50000 "TaxIDRequestSetup_EWO"
{
    Caption = 'Tax ID Request Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CallID; Integer)
        { DataClassification = ToBeClassified; }
        field(2; API_URL; Text[250])
        { DataClassification = ToBeClassified; }
        field(3; "Success Code"; Text[30])
        { DataClassification = ToBeClassified; }
        field(4; "XML Error Tag"; Text[30])
        { DataClassification = ToBeClassified; }
        field(5; "Control Period"; DateFormula)
        { DataClassification = ToBeClassified; }
        field(6; "Request Error Code"; Code[20])
        { DataClassification = ToBeClassified; }
        field(7; "Post Code Check Tag"; Text[10])
        { DataClassification = ToBeClassified; }
        field(8; "City Check Tag"; Text[10])
        { DataClassification = ToBeClassified; }
        field(9; "Name Check Tag"; Text[10])
        { DataClassification = ToBeClassified; }
        field(10; "Street Check Tag"; Text[10])
        { DataClassification = ToBeClassified; }
    }

    keys
    {
        key(Key1; CallID)
        {
            Clustered = true;
        }
    }
}