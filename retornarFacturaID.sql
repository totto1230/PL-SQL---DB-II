create or replace
procedure retornarFacturaID(idClienteP in number, facturaID out number) as
  begin
    select idfactura into facturaID
    from tabla_facturas.facturas
    where idcliente=idClienteP;
  end;