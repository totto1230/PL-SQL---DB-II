create or replace
PROCEDURE CREARRESERVAHABITACIONES(idHabitacion number, idReserva number, vidreservahabitacion out number ) AS 
BEGIN
    select nvl(max(idreservahabitacion),0) + 1 into vidreservahabitacion
    from tabla_RESERVAS.RESERVAShabitaciones;   
    insert into tabla_RESERVAS.RESERVAShabitaciones values (vidreservahabitacion, idReserva, idHabitacion );
    COMMIT;
END;