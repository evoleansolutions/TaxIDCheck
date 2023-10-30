
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
        ValidateOption: Option " ",Validated,NotValidated;
    begin
        gAccountType := AccountType;
        VATIDCheckSetup.Get('');
        ControlDate := CalcDate('-' + Format(VATIDCheckSetup."Control Period"), Today);
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    Customer.Get(AccountNo);
                    MakeRequest;

                    /*                     if Customer."VAT ID Check Date" = 0D then
                                            MakeRequest()
                                        else begin
                                            if Customer."VAT ID Check Date" > ControlDate then
                                                ResponseAction(ValidateOption::Validated)
                                            else
                                                MakeRequest();
                                        end; */

                end;
            AccountType::pVendor:
                begin
                    Vendor.Get(AccountNo);
                    if Vendor."VAT ID Check Date" = 0D then
                        MakeRequest()
                    else begin
                        if Vendor."VAT ID Check Date" > ControlDate then
                            ResponseAction(ValidateOption::Validated)
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
        if VATIDCheckLogs.FindLast() then
            LastLogEntryNo := VATIDCheckLogs."Entry No."
        else
            LastLogEntryNo := 0;
        RequestURI := StrSubstNo(VATIDCheckSetup.API_URL, CompanyInformation."VAT Registration No.", gAccountVATID, gAccountName, gAccountCity, gAccountPostCode, gAccountStreet);
        IsSuccessful := Client.Get(RequestURI, Response);
        if not IsSuccessful then begin
            VATIDCheckErrors.Get(VATIDCheckSetup."Request Error Code");
            InsertUpdateRequestLog('', VATIDCheckSetup."Request Error Code", VATIDCheckErrors."Error Description", '');
            //ResponseAction('');
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
        TagName: array[5] of Text;
        AccountValue: array[5] of Text[100];
    begin
        VATIDCheckSetup.Get('');
        Response.Content().ReadAs(ResponseText);
        TempXMLBuffer.LoadFromText(ResponseText);
        for i := 1 to ArrayLen(TagName) do begin
            case i of
                1:
                    begin
                        TagName[i] := VATIDCheckSetup."XML Error Tag";
                        AccountValue[i] := gAccountVATID;
                    end;
                2:
                    begin
                        TagName[i] := VATIDCheckSetup."Name Check Tag";
                        AccountValue[i] := gAccountName;
                    end;
                3:
                    begin
                        TagName[i] := VATIDCheckSetup."City Check Tag";
                        AccountValue[i] := gAccountCity;
                    end;
                4:
                    begin
                        TagName[i] := VATIDCheckSetup."Post Code Check Tag";
                        AccountValue[i] := gAccountPostCode;
                    end;
                5:
                    begin
                        TagName[i] := VATIDCheckSetup."Street Check Tag";
                        AccountValue[i] := gAccountStreet;
                    end;
            end;
        end;
        for i := 1 to ArrayLen(TagName) do
            FindValues(TagName[i], AccountValue[i]);

        ProcessResponseLogs(gAccountVATID);
        ShowResponseLogs;
    end;

    procedure FindValues(TagName: Text; AccountValue: Text)
    var
        VATIDCheckErrors: Record "VATIDCheckErrors_EWO";
        EntryNo: Integer;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Value, TagName);
        if TempXMLBuffer.FindFirst() then begin
            EntryNo := TempXMLBuffer."Entry No.";
            TempXMLBuffer.Reset();
            TempXMLBuffer.SetFilter("Entry No.", '>%1', EntryNo);
            TempXMLBuffer.SetFilter(Value, '<>%1', '');
            if TempXMLBuffer.FindFirst() then begin
                if VATIDCheckErrors.Get(TempXMLBuffer.Value) then
                    InsertUpdateRequestLog(TagName, VATIDCheckErrors."Error Code", VATIDCheckErrors."Error Description", AccountValue)
                else
                    InsertUpdateRequestLog(TagName, TempXMLBuffer.Value, '', AccountValue);
            end else
                InsertUpdateRequestLog(TagName, '', '', AccountValue);
        end else
            InsertUpdateRequestLog(TagName, '', '', AccountValue);
    end;

    procedure InsertUpdateRequestLog(RequestedField: Text[30]; ResponseCode: Text[30]; ResponseText: Text[250]; AccountValue: Text[100])
    begin
        Clear(VATIDCheckLogs);
        VATIDCheckLogs."Request DateTime" := CreateDateTime(Today, Time);
        VATIDCheckLogs."Requested VAT ID" := gAccountVATID;
        VATIDCheckLogs."Requested Field" := RequestedField;
        VATIDCheckLogs."Response Code" := ResponseCode;
        VATIDCheckLogs."Response Description" := ResponseText;
        VATIDCheckLogs."Account Value" := AccountValue;
        VATIDCheckLogs.Insert(true);
    end;

    procedure SetHideDialogBox(lHideDialogBox: Boolean)
    begin
        HideDialogBox := lHideDialogBox;
    end;

    procedure ResponseAction(ResponseCode: Option " ",Validated,notValidated)
    var
        VATIDCheckErrors: Record "VATIDCheckErrors_EWO";
    begin
        VATIDCheckSetup.Get('');
        case
            gAccountType of
            gAccountType::pCustomer:
                begin
                    Customer."VAT ID Validation" := ResponseCode;
                    if ResponseCode = ResponseCode::Validated then
                        Customer."VAT ID Check Date" := TODAY;
                    Customer.Modify(true);
                end;
            gAccountType::pVendor:
                begin
                    Vendor."VAT ID Validation" := ResponseCode;
                    if ResponseCode = ResponseCode::Validated then
                        Vendor."VAT ID Check Date" := TODAY;
                    Vendor.Modify(true);
                end;
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
        if VATIDCheckLogs.FindLast() then begin
            EntryFilter := VATIDCheckLogs."Entry No.";
            VATIDCheckLogs.Reset();
            VATIDCheckLogs.SetFilter("Entry No.", '>=%1', EntryFilter);
            Clear(VATIDCheckLogList);
            VATIDCheckLogList.SetTableView(VATIDCheckLogs);
            VATIDCheckLogList.Run();
        end;
    end;

    procedure ProcessResponseLogs(VatID: Text[30])
    var
        VATIDCheckSetup: Record VATIDCheckSetup_EWO;
        EntryFilter: Integer;
        ResponseCode: Option " ",Validated,notValidated;
        Success: Boolean;
    begin
        VATIDCheckSetup.Get('');
        VATIDCheckSetup.TestField("Account Validation");
        VATIDCheckLogs.Reset();
        VATIDCheckLogs.SetRange("Requested VAT ID", VatID);
        VATIDCheckLogs.SetRange("Requested Field", VATIDCheckSetup."XML Error Tag");
        if VATIDCheckLogs.FindLast() then begin
            if VATIDCheckLogs."Response Code" <> VATIDCheckSetup."Success Code" then begin
                ResponseAction(ResponseCode::notValidated);
                exit;
            end else begin
                Success := true;
                EntryFilter := VATIDCheckLogs."Entry No.";
                VATIDCheckLogs.Reset();
                VATIDCheckLogs.SetFilter("Entry No.", '>=%1', EntryFilter);
                IF VATIDCheckLogs.FindSet() then begin
                    repeat
                        case VATIDCheckSetup."Account Validation" of
                            VATIDCheckSetup."Account Validation"::"VAT ID+Account Name":
                                begin
                                    if (VATIDCheckLogs."Requested Field" = VATIDCheckSetup."Name Check Tag") then begin
                                        if (VATIDCheckLogs."Response Code" IN ['A', 'D'] = false) then
                                            Success := false;
                                    end;
                                end;
                            VATIDCheckSetup."Account Validation"::"VAT ID+Account Name+Account Address":
                                begin
                                    if (VATIDCheckLogs."Requested Field" = VATIDCheckSetup."Name Check Tag") then begin
                                        if (VATIDCheckLogs."Response Code" IN ['A', 'D'] = false) then
                                            Success := false;
                                    end;
                                    if (VATIDCheckLogs."Requested Field" = VATIDCheckSetup."Street Check Tag") then begin
                                        if (VATIDCheckLogs."Response Code" IN ['A', 'D'] = false) then
                                            Success := false;
                                    end;
                                    if (VATIDCheckLogs."Requested Field" = VATIDCheckSetup."City Check Tag") then begin
                                        if (VATIDCheckLogs."Response Code" IN ['A', 'D'] = false) then
                                            Success := false;
                                    end;
                                    if (VATIDCheckLogs."Requested Field" = VATIDCheckSetup."Post Code Check Tag") then begin
                                        if (VATIDCheckLogs."Response Code" IN ['A', 'D'] = false) then
                                            Success := false;
                                    end;
                                end;
                        end;
                    until VATIDCheckLogs.Next = 0;
                end else
                    Success := false;
                if Success then
                    ResponseAction(ResponseCode::Validated)
                else
                    ResponseAction(ResponseCode::notValidated);
            end;
        end else
            ResponseAction(ResponseCode::notValidated);
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