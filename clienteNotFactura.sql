create or replace
function clienteNotFactura(idClienteP in number) return number as
  cliente number :=0;
  
  begin
    select count(*) into cliente
    from tabla_facturas.facturas
    where idcliente=idClienteP;
    
    return cliente;
  end;