create or replace
procedure actualizarEstado(peticion in tabla_hoteles.peticiones%rowtype) as
BEGIN
      update tabla_hoteles.peticiones
      set estado = 1
      where idPeticion = peticion.idPeticion;
end;