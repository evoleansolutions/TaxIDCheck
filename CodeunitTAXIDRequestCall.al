codeunit 50102 "Tax ID Request"
{
    trigger OnRun()
    begin
        MakeRequest();
    end;

    procedure MakeRequest()
    var
        Client: HttpClient;
        RequestURI: Text;
        IsSuccessful: Boolean;
        Response: HttpResponseMessage;
        ResponseText: Text;
        TempXMLBuffer: Record "XML Buffer" temporary;
        EntryNo: Integer;
        TaxIDRequestSetup: Record "TaxIDRequestSetup";
        CompanyInformation: Record "Company Information";
        TaxIDRequestErrors: Record "TaxIDRequestErrors";

    begin
        TaxIDRequestSetup.GET(1);
        CompanyInformation.GET();
        RequestURI := StrSubstNo(TaxIDRequestSetup.API_URL, CompanyInformation."VAT Registration No.", 'NL854437691B01');
        IsSuccessful := Client.Get(RequestURI, Response);
        Response.Content().ReadAs(ResponseText);
        TempXMLBuffer.LoadFromText(ResponseText);
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Value, 'ErrorCode');
        IF TempXMLBuffer.FindFirst() THEN begin
            EntryNo := TempXMLBuffer."Entry No.";
            TempXMLBuffer.Reset();
            TempXMLBuffer.SetFilter("Entry No.", '>%1', EntryNo);
            TempXMLBuffer.SetFilter(Value, '<>%1', '');
            IF TempXMLBuffer.FindFirst() then begin
                IF TaxIDRequestErrors.GET(TempXMLBuffer.Value) then
                    Message(TaxIDRequestErrors."Error Description");
            end;
        end;
    end;
}