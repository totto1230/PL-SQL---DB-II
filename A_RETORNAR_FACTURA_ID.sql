create or replace
FUNCTION A_RETORNAR_FACTURA_ID (vIDRESERVA IN NUMBER) RETURN NUMBER AS 
vFACTURAID NUMBER;
BEGIN
  SELECT IDFACTURA INTO vFACTURAID
  FROM tabla_RESERVAS.RESERVAS
  WHERE IDRESERVA=vIDRESERVA;
  
  RETURN vFACTURAID;
END A_RETORNAR_FACTURA_ID;