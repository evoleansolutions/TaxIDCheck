table 50100 "TaxIDRequestSetup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CallID; Integer)
        { DataClassification = ToBeClassified; }
        field(2; API_URL; Text[250])
        { DataClassification = ToBeClassified; }
        field(3; "Success Code"; Text[30])
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