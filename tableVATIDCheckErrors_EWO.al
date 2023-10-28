table 50001 "VATIDCheckErrors_EWO"
{
    Caption = 'VAT ID Check Errors';
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