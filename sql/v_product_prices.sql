CREATE OR REPLACE VIEW v_product_prices AS
    SELECT
        p.cod_articulo    code,
        p.codigo_barras   barcode,
        p.nombre_articulo name,
        price.aux_precio  price,
        price.cod_unidad  uom
    FROM
        inv_articulo          p
        LEFT JOIN fac_catalogo_precio_d price ON p.cod_articulo = price.cod_articulo;