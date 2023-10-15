
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
        ErrorTxt: Label 'Request is not completed due to a server error. Please try again later.';

    begin
        TaxIDRequestSetup.Get(1);
        CompanyInformation.Get();
        InsertRequestLog(RequestedTaxID);
        RequestURI := StrSubstNo(TaxIDRequestSetup.API_URL, CompanyInformation."VAT Registration No.", RequestedTaxID);
        IsSuccessful := Client.Get(RequestURI, Response);
        if not IsSuccessful then
            UpdateRequstLog('', ErrorTxt)
        else begin
            Response.Content().ReadAs(ResponseText);
            TempXMLBuffer.LoadFromText(ResponseText);
            TempXMLBuffer.Reset();
            TempXMLBuffer.SetRange(Value, TaxIDRequestSetup."XML Error Tag");
            IF TempXMLBuffer.FindFirst() THEN begin
                EntryNo := TempXMLBuffer."Entry No.";
                TempXMLBuffer.Reset();
                TempXMLBuffer.SetFilter("Entry No.", '>%1', EntryNo);
                TempXMLBuffer.SetFilter(Value, '<>%1', '');
                IF TempXMLBuffer.FindFirst() then begin
                    IF TaxIDRequestErrors.GET(TempXMLBuffer.Value) then begin
                        Message(TaxIDRequestErrors."Error Description");
                        UpdateRequstLog(TaxIDRequestErrors."Error Code", TaxIDRequestErrors."Error Description");
                    end;
                end;
            end;
        end;
    end;

    procedure InsertRequestLog(TaxID: Text[30])
    begin
        Clear(TaxIDRequestLogs);
        TaxIDRequestLogs."Request DateTime" := CreateDateTime(Today, Time);
        TaxIDRequestLogs."Requested Tax ID" := TaxID;
        TaxIDRequestLogs.Insert(true);
    end;

    procedure UpdateRequstLog(ResponseCode: Text[30]; ResponseText: Text[250])
    begin
        TaxIDRequestLogs."Response Code" := ResponseCode;
        TaxIDRequestLogs."Response Description" := ResponseText;
        TaxIDRequestLogs.Modify();
    end;

    var
        TaxIDRequestLogs: Record TaxIDRequestLogs_EWO;
}