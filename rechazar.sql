create or replace
procedure rechazar(peticion in tabla_hoteles.peticiones%rowtype, razon varchar, personasRestantes number) as 
-- Insertar el registro de rechazo
  begin
    insert into tabla_hoteles.rechazado values( peticion.idpeticion, peticion.idCliente, peticion.idTipoHabitacion, peticion.cantidadPersonas
    , peticion.fechaInicial, peticion.fechaFinal, razon, personasRestantes);
    commit;
  end;