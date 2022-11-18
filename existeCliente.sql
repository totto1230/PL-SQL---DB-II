create or replace
function existeCliente(idClienteP in number) return number as
  cliente number :=0;
  
  begin
    select count(*) into cliente
    from tabla_facturas.clientes
    where idcliente=idClienteP;
    
    return cliente;
  end;