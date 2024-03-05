codeunit 50100 EventTest_AL
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', true, true)]
    local procedure OnBeforePostSalesDoc()
    var
        SalesHeader: Record "Sales Header";
        PostingDate: Date;
    begin
        Error(SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterDeleteEvent, '', true, true)]
    local procedure OnAfterDeleteEvent()
    var
        SalesLine: Record "Sales Line";
    begin
        Error(SalesLine."Document No.");
    end;
}