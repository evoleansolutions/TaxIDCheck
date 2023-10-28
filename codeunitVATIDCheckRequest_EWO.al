
codeunit 50000 "VATIDCheckRequest_EWO"
{
    trigger OnRun()
    begin
        MakeRequest();
    end;

    procedure ValidateRequest(AccountType: Option pCustomer,pVendor; AccountNo: Code[20])
    var
        VATIDCheckSetup: Record "VATIDCheckSetup_EWO";
        ControlDate: Date;
    begin
        gAccountType := AccountType;
        VATIDCheckSetup.Get(1);
        ControlDate := CalcDate('-' + Format(VATIDCheckSetup."Control Period"), Today);
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    Customer.get(AccountNo);
                    if Customer."VAT ID Check Date" = 0D then
                        MakeRequest()
                    else begin
                        if Customer."VAT ID Check Date" > ControlDate then
                            ResponseAction(VATIDCheckSetup."Success Code")
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
                            ResponseAction(VATIDCheckSetup."Success Code")
                        else
                            MakeRequest();
                    end;
                end;
        end;
    end;

    procedure MakeRequest()
    var
        VATIDCheckErrors: Record "VATIDCheckErrors_EWO";
        VATIDCheckSetup: Record "VATIDCheckSetup_EWO";
        CompanyInformation: Record "Company Information";
        Client: HttpClient;
        RequestURI: Text;
        IsSuccessful: Boolean;
    begin
        VATIDCheckSetup.Get('');
        CompanyInformation.Get();
        FillKeyValues;
        VATIDCheckLogs.FindLast();
        LastLogEntryNo := VATIDCheckLogs."Entry No.";
        RequestURI := StrSubstNo(VATIDCheckSetup.API_URL, CompanyInformation."VAT Registration No.", gAccountVATID, gAccountName, gAccountCity, gAccountPostCode, gAccountStreet);
        IsSuccessful := Client.Get(RequestURI, Response);
        if not IsSuccessful then begin
            VATIDCheckErrors.GET(VATIDCheckSetup."Request Error Code");
            InsertUpdateRequestLog('', VATIDCheckSetup."Request Error Code", VATIDCheckErrors."Error Description");
            ResponseAction(VATIDCheckErrors."Error Code");
        end else
            ParseResponse();
    end;

    procedure FillKeyValues()
    begin
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    gAccountVATID := Customer."VAT Registration No.";
                    gAccountName := Customer.Name;
                    gAccountCity := Customer.City;
                    gAccountPostCode := Customer."Post Code";
                    gAccountStreet := Customer.Address;
                end;
            gAccountType::pVendor:
                begin
                    gAccountVATID := Vendor."VAT Registration No.";
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
        VATIDCheckSetup.GET('');
        Response.Content().ReadAs(ResponseText);
        TempXMLBuffer.LoadFromText(ResponseText);
        for i := 1 to 5 do begin
            case i OF
                1:
                    FindValues(VATIDCheckSetup."XML Error Tag");
                2:
                    FindValues(VATIDCheckSetup."Name Check Tag");
                3:
                    FindValues(VATIDCheckSetup."City Check Tag");
                4:
                    FindValues(VATIDCheckSetup."Post Code Check Tag");
                5:
                    FindValues(VATIDCheckSetup."Street Check Tag");
            end;
        end;
        ShowResponseLogs;
    end;

    procedure FindValues(TagName: Text)
    var
        VATIDCheckErrors: Record "VATIDCheckErrors_EWO";
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
                IF VATIDCheckErrors.GET(TempXMLBuffer.Value) then
                    InsertUpdateRequestLog(TagName, VATIDCheckErrors."Error Code", VATIDCheckErrors."Error Description")
                else
                    InsertUpdateRequestLog(TagName, TempXMLBuffer.Value, '');
            end else
                InsertUpdateRequestLog(TagName, '', '');
        end else
            InsertUpdateRequestLog(TagName, '', '');
    end;

    procedure InsertRequestLog(VATID: Text[30])
    begin
        Clear(VATIDCheckLogs);
        VATIDCheckLogs."Request DateTime" := CreateDateTime(Today, Time);
        VATIDCheckLogs."Requested VAT ID" := VATID;
        VATIDCheckLogs.Insert(true);
    end;

    procedure InsertUpdateRequestLog(RequestedField: Text[30]; ResponseCode: Text[30]; ResponseText: Text[250])
    begin
        Clear(VATIDCheckLogs);
        VATIDCheckLogs."Request DateTime" := CreateDateTime(Today, Time);
        VATIDCheckLogs."Requested VAT ID" := gAccountVATID;
        VATIDCheckLogs."Requested Field" := RequestedField;
        VATIDCheckLogs."Response Code" := ResponseCode;
        VATIDCheckLogs."Response Description" := ResponseText;
        VATIDCheckLogs.Insert(true);
    end;

    procedure SetHideDialogBox(lHideDialogBox: Boolean)
    begin
        HideDialogBox := lHideDialogBox;
    end;

    procedure ResponseAction(ResponseCode: Code[20])
    var
        VATIDCheckErrors: Record "VATIDCheckErrors_EWO";
    begin
        VATIDCheckSetup.GET('');
        if (ResponseCode = VATIDCheckSetup."Success Code") AND (VATIDCheckSetup."Account Validation" = 0) then begin
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
            VATIDCheckErrors.Get(ResponseCode);
            Message(VATIDCheckErrors."Error Description");
        end;
    end;

    procedure ShowResponseLogs()
    begin
        VATIDCheckLogs.Reset();
        VATIDCheckLogs.SetFilter("Entry No.", '>%1', LastLogEntryNo);
        Clear(VATIDCheckLogList);
        VATIDCheckLogList.SetTableView(VATIDCheckLogs);
        VATIDCheckLogList.Run();
    end;

    procedure ShowResponseLogs_AccountCard(VatID: Text[30])
    var
        VATIDCheckSetup: Record VATIDCheckSetup_EWO;
        EntryFilter: Integer;
    begin
        VATIDCheckSetup.Get('');
        VATIDCheckLogs.Reset();
        VATIDCheckLogs.SetRange("Requested VAT ID", VatID);
        VATIDCheckLogs.SetRange("Requested Field", VATIDCheckSetup."XML Error Tag");
        IF VATIDCheckLogs.FindLast() then begin
            EntryFilter := VATIDCheckLogs."Entry No.";
            VATIDCheckLogs.Reset();
            VATIDCheckLogs.SetFilter("Entry No.", '>=%1', EntryFilter);
            Clear(VATIDCheckLogList);
            VATIDCheckLogList.SetTableView(VATIDCheckLogs);
            VATIDCheckLogList.Run();
        end;
    end;

    var
        VATIDCheckLogs: Record VATIDCheckLogs_EWO;
        Customer: Record Customer;
        Vendor: Record Vendor;
        VATIDCheckSetup: Record VATIDCheckSetup_EWO;
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATIDCheckLogList: Page VATIDCheckLogs_EWO;
        Response: HttpResponseMessage;
        ResponseText: Text;
        HideDialogBox: Boolean;
        gAccountType: Option pCustomer,pVendor;
        gAccountName: Text[50];
        gAccountCity: Text[30];
        gAccountPostCode: Text[20];
        gAccountStreet: Text[50];
        gAccountVATID: Text[30];
        LastLogEntryNo: Integer;
}