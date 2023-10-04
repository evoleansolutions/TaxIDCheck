<<<<<<< HEAD
table 50100 TaxIDRequestSetup
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CallID; Integer)
        { DataClassification = ToBeClassified; }
        field(2; API_URL; Text[250])
        { DataClassification = ToBeClassified; }
    }

    keys
    {
        key(Key1; CallID)
        {
            Clustered = true;
        }
    }
=======
table 50100 TaxIDRequestSetup
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CallID; Integer)
        { DataClassification = ToBeClassified; }
        field(2; API_URL; Text[250])
        { DataClassification = ToBeClassified; }
    }

    keys
    {
        key(Key1; CallID)
        {
            Clustered = true;
        }
    }
>>>>>>> 109e1ac40a46620f17a3051d014986e5c0380a19
}