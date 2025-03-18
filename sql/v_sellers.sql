--------------------------------------------------------
--  DDL for View V_SELLERS
--------------------------------------------------------

CREATE OR REPLACE FORCE VIEW v_sellers AS
    SELECT
        cod_vendedor code,
        trim(apellidos
        || ' '
        || nombres)   AS name
    FROM
        v_vendedores;