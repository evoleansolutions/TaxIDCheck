
codeunit 50000 "TaxIDRequest_EWO"
{
    trigger OnRun()
    begin
        MakeRequest('NL854437691B01');
    end;

    procedure MakeRequest(RequestedTaxID: Text[30])
    var
        Client: HttpClient;
        RequestURI: Text;
        IsSuccessful: Boolean;
        Response: HttpResponseMessage;
        ResponseText: Text;
        TempXMLBuffer: Record "XML Buffer" temporary;
        EntryNo: Integer;
        TaxIDRequestSetup: Record "TaxIDRequestSetup_EWO";
        CompanyInformation: Record "Company Information";
        TaxIDRequestErrors: Record "TaxIDRequestErrors_EWO";

    begin
        TaxIDRequestSetup.GET(1);
        CompanyInformation.GET();
        InsertRequestLogs(RequestedTaxID, '', '', 1);
        RequestURI := StrSubstNo(TaxIDRequestSetup.API_URL, CompanyInformation."VAT Registration No.", RequestedTaxID);
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

    procedure InsertRequestLogs(TaxID: Text[30]; ResponseCode: Text[30]; ResponseText: Text[250]; Type: Integer)
    begin
        if Type = 1 then begin
            Clear(TaxIDRequestLogs);
            TaxIDRequestLogs."Request DateTime" := CreateDateTime(Today, Time);
            TaxIDRequestLogs."Requested Tax ID" := TaxID;
            TaxIDRequestLogs.Insert(true)
        end else
            if Type = 2 then begin
                TaxIDRequestLogs."Response Code" := ResponseCode;
                TaxIDRequestLogs."Response Description" := ResponseText;
                TaxIDRequestLogs.Modify();
            end;
    end;

    var
        TaxIDRequestLogs: Record TaxIDRequestLogs_EWO;
}