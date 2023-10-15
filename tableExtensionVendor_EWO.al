tableextension 50001 Vendor_EWO extends Vendor
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