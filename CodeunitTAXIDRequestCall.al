codeunit 50100 TaxIDApiRequest
{
    trigger OnRun()
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
            IF TempXMLBuffer.FindFirst() then
                Message(TempXMLBuffer.Value);
        end;



    end;

    var
        TaxIDRequestSetup: Record TaxIDRequestSetup;
        CompanyInformation: Record "Company Information";
        Client: HttpClient;
        RequestURI: Text;
        IsSuccessful: Boolean;
        Response: HttpResponseMessage;
        ResponseText: Text;
        TempXMLBuffer: Record "XML Buffer" temporary;
        EntryNo: Integer;
}