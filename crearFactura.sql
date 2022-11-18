create or replace
procedure crearFactura(vIdCliente in number,  vIdFactura out number) as 
begin
        select nvl(max(idFactura),0) + 1 into vIdFactura
        from tabla_facturas.facturas;  
        insert into tabla_facturas.facturas values(vIdFactura, (sysdate), 0, vIdCliente);
        commit;
end;