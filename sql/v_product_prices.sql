CREATE OR REPLACE VIEW v_product_prices AS
SELECT
    p.cod_articulo    code,
    p.codigo_barras   barcode,
    p.nombre_articulo name,
    round(price.aux_precio + (price.aux_precio * tax.valor / 100), 2) price,
    price.cod_unidad  uom
FROM
    inv_articulo          p
    LEFT JOIN fac_catalogo_precio_d price ON p.cod_articulo = price.cod_articulo
    JOIN inv_iva tax ON p.cod_iva = tax.cod_iva;