codeunit 50500 EventTest_AL
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', true, true)]
    local procedure OnBeforePostSalesDoc()
    var
        SalesHeader: Record "Sales Header";
        PostingDate: Date;
    begin
        Error(SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterDeleteSalesLines, '', true, true)]
    local procedure OnAfterDeleteSalesLines()
    var
        SalesLine: Record "Sales Line";
    begin
        Error(SalesLine."Document No.");
    end;
}