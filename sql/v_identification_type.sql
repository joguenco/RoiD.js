--------------------------------------------------------
--  DDL for View V_IDENTIFICATION_TYPE
--------------------------------------------------------

CREATE OR REPLACE FORCE VIEW v_identification_type ( code,
name ) AS
    SELECT
        cod_documento AS code,
        descripcion   AS name
    FROM
        gnr_tipo_documento
    WHERE
        descripcion <> 'CONSUMIDOR FINAL';