SELECT
    id,
    code,
    name,
    stock,
    unit,
    price
FROM
    TABLE ( pkg_quotation.fun_product_list('%MOTOREX L', '01', '01') )
ORDER BY
    name;
