tableextension 50000 Customer_EWO extends Customer
{
    fields
    {
        field(50000; "Tax ID Check Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}