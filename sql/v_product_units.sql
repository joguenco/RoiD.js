CREATE OR REPLACE FORCE VIEW v_product_units AS
    SELECT
        cod_articulo code,
        cod_unidad   um,
        factor,
        operador     operator
    FROM
        inv_unidad_alternativa
    WHERE
        estado = 'A';