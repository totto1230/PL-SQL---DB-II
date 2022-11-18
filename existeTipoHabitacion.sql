create or replace
function existeTipoHabitacion(idtipohabitacionP in number) return number as
  tipoHabitacion number :=0;
  
  begin
    select count(*) into tipoHabitacion
    from tabla_hoteles.tipohabitacion
    where idtipohabitacion=idtipohabitacionP;
    
    return tipoHabitacion;
  end;