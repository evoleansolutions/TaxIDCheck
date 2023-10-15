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


    }

    keys
    {
        key(Key1; CallID)
        {
            Clustered = true;
        }
    }
}