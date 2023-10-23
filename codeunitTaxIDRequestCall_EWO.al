
codeunit 50000 "TaxIDRequest_EWO"
{
    trigger OnRun()
    begin
        MakeRequest();
    end;

    procedure ValidateRequest(AccountType: Option pCustomer,pVendor; AccountNo: Code[20])
    var
        TaxIDRequestSetup: Record "TaxIDRequestSetup_EWO";
        ControlDate: Date;
    begin
        gAccountType := AccountType;
        TaxIDRequestSetup.Get(1);
        ControlDate := CalcDate('-' + Format(TaxIDRequestSetup."Control Period"), Today);
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    Customer.get(AccountNo);
                    if Customer."VAT ID Check Date" = 0D then
                        MakeRequest()
                    else begin
                        if Customer."VAT ID Check Date" > ControlDate then
                            ResponseAction(TaxIDRequestSetup."Success Code")
                        else
                            MakeRequest();
                    end;
                end;
            AccountType::pVendor:
                begin
                    Vendor.get(AccountNo);
                    if Vendor."VAT ID Check Date" = 0D then
                        MakeRequest()
                    else begin
                        if Vendor."VAT ID Check Date" > ControlDate then
                            ResponseAction(TaxIDRequestSetup."Success Code")
                        else
                            MakeRequest();
                    end;
                end;
        end;
    end;

    procedure MakeRequest()
    var
        TaxIDRequestErrors: Record "TaxIDRequestErrors_EWO";
        TaxIDRequestSetup: Record "TaxIDRequestSetup_EWO";
        CompanyInformation: Record "Company Information";
        Client: HttpClient;
        RequestURI: Text;
        IsSuccessful: Boolean;
    begin
        TaxIDRequestSetup.Get(1);
        CompanyInformation.Get();
        FillKeyValues;
        TaxIDRequestLogs.FindLast();
        LastLogEntryNo := TaxIDRequestLogs."Entry No.";
        RequestURI := StrSubstNo(TaxIDRequestSetup.API_URL, CompanyInformation."VAT Registration No.", gAccountTaxID, gAccountName, gAccountCity, gAccountPostCode, gAccountStreet);
        IsSuccessful := Client.Get(RequestURI, Response);
        if not IsSuccessful then begin
            TaxIDRequestErrors.GET(TaxIDRequestSetup."Request Error Code");
            InsertUpdateRequestLog('', TaxIDRequestSetup."Request Error Code", TaxIDRequestErrors."Error Description");
            ResponseAction(TaxIDRequestErrors."Error Code");
        end else
            ParseResponse();
    end;

    procedure FillKeyValues()
    begin
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    gAccountTaxID := Customer."VAT Registration No.";
                    gAccountName := Customer.Name;
                    gAccountCity := Customer.City;
                    gAccountPostCode := Customer."Post Code";
                    gAccountStreet := Customer.Address;
                end;
            gAccountType::pVendor:
                begin
                    gAccountTaxID := Vendor."VAT Registration No.";
                    gAccountName := Vendor.Name;
                    gAccountCity := Vendor.City;
                    gAccountPostCode := Vendor."Post Code";
                    gAccountStreet := Vendor.Address;
                end;
        end;
    end;

    procedure ParseResponse()
    var
        i: Integer;
    begin
        TempXMLBuffer.DeleteAll();
        TaxIDRequestSetup.GET('1');
        Response.Content().ReadAs(ResponseText);
        TempXMLBuffer.LoadFromText(ResponseText);
        for i := 1 to 5 do begin
            case i OF
                1:
                    FindValues(TaxIDRequestSetup."XML Error Tag");
                2:
                    FindValues(TaxIDRequestSetup."Name Check Tag");
                3:
                    FindValues(TaxIDRequestSetup."City Check Tag");
                4:
                    FindValues(TaxIDRequestSetup."Post Code Check Tag");
                5:
                    FindValues(TaxIDRequestSetup."Street Check Tag");
            end;
        end;
        ShowResponseLogs;
    end;

    procedure FindValues(TagName: Text)
    var
        TaxIDRequestErrors: Record "TaxIDRequestErrors_EWO";
        EntryNo: Integer;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Value, TagName);
        IF TempXMLBuffer.FindFirst() THEN begin
            EntryNo := TempXMLBuffer."Entry No.";
            TempXMLBuffer.Reset();
            TempXMLBuffer.SetFilter("Entry No.", '>%1', EntryNo);
            TempXMLBuffer.SetFilter(Value, '<>%1', '');
            IF TempXMLBuffer.FindFirst() then begin
                IF TaxIDRequestErrors.GET(TempXMLBuffer.Value) then
                    InsertUpdateRequestLog(TagName, TaxIDRequestErrors."Error Code", TaxIDRequestErrors."Error Description")
                else
                    InsertUpdateRequestLog(TagName, TempXMLBuffer.Value, '');
            end else
                InsertUpdateRequestLog(TagName, '', '');
        end else
            InsertUpdateRequestLog(TagName, '', '');
    end;

    procedure InsertRequestLog(TaxID: Text[30])
    begin
        Clear(TaxIDRequestLogs);
        TaxIDRequestLogs."Request DateTime" := CreateDateTime(Today, Time);
        TaxIDRequestLogs."Requested Tax ID" := TaxID;
        TaxIDRequestLogs.Insert(true);
    end;

    procedure InsertUpdateRequestLog(RequestedField: Text[30]; ResponseCode: Text[30]; ResponseText: Text[250])
    begin
        Clear(TaxIDRequestLogs);
        TaxIDRequestLogs."Request DateTime" := CreateDateTime(Today, Time);
        TaxIDRequestLogs."Requested Tax ID" := gAccountTaxID;
        TaxIDRequestLogs."Response Code" := ResponseCode;
        TaxIDRequestLogs."Response Description" := ResponseText;
        TaxIDRequestLogs.Insert(true);
    end;

    procedure SetHideDialogBox(lHideDialogBox: Boolean)
    begin
        HideDialogBox := lHideDialogBox;
    end;

    procedure ResponseAction(ResponseCode: Code[20])
    var
        TaxIDRequestErrors: Record "TaxIDRequestErrors_EWO";
    begin
        TaxIDRequestSetup.GET('1');
        if (ResponseCode = TaxIDRequestSetup."Success Code") AND (TaxIDRequestSetup."Account Validation" = 0) then begin
            case
                gAccountType of
                gAccountType::pCustomer:
                    begin
                        Customer."VAT ID Check Date" := TODAY;
                        Customer."VAT ID Validation" := Customer."VAT ID Validation"::Validated;
                        Customer.Modify(true);
                    end;
                gAccountType::pVendor:
                    begin
                        Vendor."VAT ID Check Date" := TODAY;
                        Vendor.Modify(true);
                    end;
            end;
        end;
        if HideDialogBox = false then begin
            TaxIDRequestErrors.Get(ResponseCode);
            Message(TaxIDRequestErrors."Error Description");
        end;
    end;

    procedure ShowResponseLogs()
    begin
        TaxIDRequestLogs.Reset();
        TaxIDRequestLogs.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        Clear(TaxIDRequestLogList);
        TaxIDRequestLogList.SetTableView(TaxIDRequestLogs);
        TaxIDRequestLogList.Run();
    end;

    procedure ShowResponseLogs_AccountCard(VatID: Text[30])
    var
        VATIDRequestSetup: Record TaxIDRequestSetup_EWO;
        EntryFilter: Integer;
    begin
        VATIDRequestSetup.Get('1');
        TaxIDRequestLogs.Reset();
        TaxIDRequestLogs.SetRange("Requested Tax ID", VatID);
        TaxIDRequestLogs.SetRange("Requested Field", VATIDRequestSetup."XML Error Tag");
        IF TaxIDRequestLogs.FindLast() then begin
            EntryFilter := TaxIDRequestLogs."Entry No.";
            TaxIDRequestLogs.Reset();
            TaxIDRequestLogs.SetFilter("Entry No.", '>%1', EntryFilter);
            Clear(TaxIDRequestLogList);
            TaxIDRequestLogList.SetTableView(TaxIDRequestLogs);
            TaxIDRequestLogList.Run();
        end;
    end;

    var
        TaxIDRequestLogs: Record TaxIDRequestLogs_EWO;
        Customer: Record Customer;
        Vendor: Record Vendor;
        TaxIDRequestSetup: Record TaxIDRequestSetup_EWO;
        TempXMLBuffer: Record "XML Buffer" temporary;
        TaxIDRequestLogList: Page TaxIDRequestLogs_EWO;
        Response: HttpResponseMessage;
        ResponseText: Text;
        HideDialogBox: Boolean;
        gAccountType: Option pCustomer,pVendor;
        gAccountName: Text[50];
        gAccountCity: Text[30];
        gAccountPostCode: Text[20];
        gAccountStreet: Text[50];
        gAccountTaxID: Text[30];
        LastLogEntryNo: Integer;
}