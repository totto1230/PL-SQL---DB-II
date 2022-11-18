create or replace
procedure transaccionJG as
-- Cursor para recorrer las peticiones 
cursor cPeticiones is select idPeticion,
                             idCliente,
                             idTipoHabitacion,
                             cantidadPersonas,
                             fechaInicial,
                             fechaFinal,
                             estado
                        from tabla_hoteles.peticiones
                        where estado = 0
                        order by 1;

-- Cursor para traer los id de la habitaciones libres, por tipo y por fecha
cursor cHabitacionesLibres(vIdTipoHabitacion number,
                           vFechaInicio date, 
                           vFechaFinal date) is  
        select idTipoHabitacion, idHabitacion, cantidadPersonas
        from tabla_hoteles.habitaciones 
        where idHabitacion  in( select idHabitacion 
                                   from  tabla_hoteles.habitaciones 
                                   where idTipoHabitacion = vIdTipoHabitacion
                                   Minus
                                   select idHabitacion
                                   from tabla_reservas.reservas rv,
                                        tabla_reservas.reservasHabitaciones rh
                                   where rv.idReserva = rh.idReserva
                                     and ((TO_DATE(rv.fechaInicio,'DD/MM/YYYY') <= TO_DATE(vFechaInicio,'DD/MM/YYYY') and TO_DATE(rv.fechaFinal,'DD/MM/YYYY') >= TO_DATE(vFechaInicio,'DD/MM/YYYY'))
                                     or (TO_DATE(rv.fechaInicio,'DD/MM/YYYY') <=  TO_DATE(vFechaFinal,'DD/MM/YYYY') and  TO_DATE(rv.fechaFinal,'DD/MM/YYYY') >= TO_DATE(vFechaFinal,'DD/MM/YYYY'))
                                     or (TO_DATE(rv.fechaInicio,'DD/MM/YYYY') >= TO_DATE(vFechaInicio,'DD/MM/YYYY') and TO_DATE(rv.fechaFinal,'DD/MM/YYYY') <= TO_DATE(vFechaFinal,'DD/MM/YYYY'))
                                     or (TO_DATE(rv.fechaInicio,'DD/MM/YYYY') <= TO_DATE(vFechaInicio,'DD/MM/YYYY') and TO_DATE(rv.fechaFinal,'DD/MM/YYYY') >= TO_DATE(vFechaFinal,'DD/MM/YYYY'))))
        order by 2;    

-- El registro para recorrer cHabitacionesLibres
rCHabitacioneLibres cHabitacionesLibres%rowtype;

--SIRVE PARA VER SI EL # DE PERSONAS ES IGUAL O MAYOR AL DE LA PETICION
alcanceCantidadPersonas NUMBER;

--SIRVE PARA CONTAR EL NUMERO DE RESERVADORS
cantidadPersonasReservadas NUMBER;

--SIRVE PARA VER SI HAY RESERVA O NO
vExisteReserva NUMBER;

--SIRVE PARA GUARDAR EL ID DE LA RESERVA
RESERVAID NUMBER;

--SIRVE PARA GUARDAR EL ID DE LA FACTURA
IDFACTURA NUMBER;

--SIRVE PARA GUARDAR EL ID DE LA RESERVA de la habitacion
idreservahabitacion NUMBER;

BEGIN 
    -- Revisar cada peticion
    for cadaPeticion in cPeticiones loop
      --Imprime las peticiones
      --dbms_output.put_line  (cadaPeticion.idPeticion || '-' ||cadaPeticion.idCliente || '-' ); 
        -- si existe el cliente(peticion                          
        if existeCliente(cadaPeticion.idCliente)= 1  then
          /*IMPRESION PARA VER SI EL IF ENCUENTRA EL CLIENTE QUE NO EXISTE
          --dbms_output.put_line  (cadaPeticion.idPeticion || 'EXISTE' );*/
		  --Si el cliente no tiene una factura, la crea
          if clientenotfactura(cadaPeticion.idCliente) = 0 then
			--Se verifica si el tipo de habitacion existe
            if existeTipoHabitacion(cadaPeticion.idTipoHabitacion) = 1 then
			  --Se evita que cree una factura duplicada
              if cadaPeticion.idCliente != 1 then
                crearFactura(cadaPeticion.idCliente, IDFACTURA);
              end if;
              /*dbms_output.put_line  (cadaPeticion.idCliente || 'no tiene factura' );
              Se revisa si el tipo de habitacion existe*/
                  --Se inicializan las variables en 0
                          -- Abre el cursor y se le pasan todas el tipo de habitacion y las fechas para ver si esta disponible
                   open cHabitacionesLibres(cadaPeticion.idTipoHabitacion,
                                            cadaPeticion.fechaInicial,
                                            cadaPeticion.fechaFinal);
                  alcanceCantidadPersonas:=0;
                  cantidadPersonasReservadas:=0;
                  vExisteReserva:=0;
                  --Se crea un loop para que guarde cada registro en la variable tipo rowtype y hacer las respectivas reservas
                  loop
                      --Guarda cada habitacion disponible en el registro
                      fetch cHabitacionesLibres into rCHabitacioneLibres;
                      --Se sale del fetch cuando no hay más libres
                      exit when cHabitacionesLibres%notFound;
                      
                      --dbms_output.put_line(IDFACTURA || '---' || vExisteReserva || '---' || reservaID);
					  --Se verifica que no exista la reserva y que el id de la factura se diferente de 1 para no hacer una variable duplicada
                      if  vExisteReserva=0 and IDFACTURA != 1
                      then
						--Se crea la reserva con la informacion de la peticion actual
                        crearReserva(IDFACTURA, cadaPeticion.fechaInicial, cadaPeticion.fechaFinal, reservaID);
                        vExisteReserva:=1;
                      end if;
					  --Se crea la reserva de la habitacion
                      CREARRESERVAHABITACIONES(rCHabitacioneLibres.idHabitacion, reservaID, idreservahabitacion);
                      cantidadPersonasReservadas:= cantidadPersonasReservadas+ rCHabitacioneLibres.cantidadPersonas;
                      
                      if cadaPeticion.cantidadPersonas <= cantidadPersonasReservadas
                      then
                        alcanceCantidadPersonas:=1;
                      exit;
                      end if;
                    
                  end loop;
                  
                  if alcanceCantidadPersonas=0
                  then
                    rechazar(cadaPeticion, 'No se cumplio con el numero de personas', (cadapeticion.cantidadPersonas - cantidadPersonasReservadas));
                  end if;
    
                 close cHabitacionesLibres;     
              else
                /*Se rechaza porque no existe el tipo habitacion
                dbms_output.put_line  (cadaPeticion.idCliente || 'no existe habitacion ' || cadaPeticion.idTipoHabitacion);*/
                rechazar(cadaPeticion, 'No existe tipo habitacion', cadapeticion.cantidadPersonas);
              end if;
--***************************EL CLIENTE TIENE FACTURA*******************************************
         else
           if existeTipoHabitacion(cadaPeticion.idTipoHabitacion) = 1 then  
                -- Abre el cursor y se le pasan todas el tipo de habitacion y las fechas para ver si esta disponible
                --dbms_output.put_line( cadapeticion.IDPETICION || '<-PETICION- RCHABITACIONES TIPO -> ' || rCHabitacioneLibres.idTipoHabitacion || 'ANTES');
                retornarFacturaID(cadapeticion.idcliente,IDFACTURA);
                        -- Abre el cursor y se le pasan todas el tipo de habitacion y las fechas para ver si esta disponible
                        
               open cHabitacionesLibres(cadaPeticion.idTipoHabitacion,
                                        cadaPeticion.fechaInicial,
                                        cadaPeticion.fechaFinal);
                alcanceCantidadPersonas:=0;
                cantidadPersonasReservadas:=0;
                vExisteReserva:=0;
                --Se crea un loop para que guarde cada registro en la variable tipo rowtype
                loop
                    fetch cHabitacionesLibres into rCHabitacioneLibres;   
                    exit when cHabitacionesLibres%notFound;
                    dbms_output.put_line( cadapeticion.IDPETICION || '<-PETICION- RCHABITACIONES TIPO -> ' || rCHabitacioneLibres.idTipoHabitacion || 'id habitacion -> ' ||rCHabitacioneLibres.idHabitacion );

                    if  vExisteReserva=0 and IDFACTURA != 1
                    then
                      crearReserva(IDFACTURA, cadaPeticion.fechaInicial, cadaPeticion.fechaFinal, reservaID);
                      
                      vExisteReserva:=1;
                    end if;

                    CREARRESERVAHABITACIONES(rCHabitacioneLibres.idHabitacion, reservaID, idreservahabitacion);
                    cantidadPersonasReservadas:= cantidadPersonasReservadas+ rCHabitacioneLibres.cantidadPersonas;
                    
                    if cadaPeticion.cantidadPersonas <= cantidadPersonasReservadas
                    then
                      alcanceCantidadPersonas:=1;
                    exit;
                    end if;

                end loop;
            
                if alcanceCantidadPersonas=0
                then
                  rechazar(cadaPeticion, 'No se cumplio con el numero de personas', (cadapeticion.cantidadPersonas - cantidadPersonasReservadas));
                end if;

               close cHabitacionesLibres;    
            else
               --Se rechaza porque no existe el tipo habitacion
              --dbms_output.put_line  (cadaPeticion.idCliente || 'no existe habitacion ' || cadaPeticion.idTipoHabitacion);
              rechazar(cadaPeticion, 'No existe tipo habitacion', cadapeticion.cantidadpersonas);
            end if;
          end if;
        
          --*********EL CLIENTE TIENE FACTURA**************
        else
         /*IMPRESION PARA VER SI EL IF ENCUENTRA EL CLIENTE QUE NO EXISTE
           dbms_output.put_line  (cadaPeticion.idPeticion || 'NO EXISTE' );
          --se rechaza el cliente debido a que no existe*/
          rechazar(cadaPeticion,'Cliente no existe', cadapeticion.cantidadpersonas);
        end if;
        actualizarEstado(cadaPeticion);
    END LOOP;    
END transaccionJG;