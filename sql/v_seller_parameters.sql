CREATE OR REPLACE FORCE VIEW v_seller_parameters AS
    SELECT
        f.nombre_usuario   username,
        f.def_cod_vendedor seller_code,
        s.name             seller_name,
        f.def_bodega       warehouse,
        f.def_inventario   batch
    FROM
             fac_parametros f
        INNER JOIN v_sellers s ON f.def_cod_vendedor = s.code;