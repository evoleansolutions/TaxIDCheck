tableextension 50000 Customer_EWO extends Customer
{
    fields
    {
        field(50000; "VAT ID Check Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50001; "VAT ID Validation"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Validated,"Not Validated";
        }
    }
}