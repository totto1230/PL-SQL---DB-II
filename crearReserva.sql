create or replace
procedure crearReserva(vIDFACTURA IN NUMBER ,FECHAINICIAL IN DATE  ,FECHAFINAL IN DATE , vRESERVAID out number ) as

  begin
    -- Busca el número de factura si existiera
   /*select IDRESERVA into vRESERVAID  
    from tabla_RESERVAS.RESERVAS  
    where IDFACTURA = vIDFACTURA;
    
    exception
      when NO_DATA_FOUND then
        NULL;

    if SQL%NOTFOUND then*/
        select nvl(max(IDRESERVA),0) + 1 into vRESERVAID
        from tabla_RESERVAS.RESERVAS;   
        insert into tabla_reservas.reservas values (vRESERVAID, TO_DATE(FECHAINICIAL,'DD/MM/YYYY'), TO_DATE(FECHAFINAL,'DD/MM/YYYY'), vidFactura);
        COMMIT;
    --END IF;    
end;