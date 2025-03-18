CREATE OR REPLACE PACKAGE pkg_quotation AS
    TYPE t_facto_operator IS RECORD (
            factor   NUMBER,
            operator VARCHAR2(1)
    );
    FUNCTION fun_factor_operator (
        p_product_code NUMBER,
        p_unit         VARCHAR2
    ) RETURN t_facto_operator;

    FUNCTION fun_get_price (
        p_product IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fun_product_list (
        p_product_name IN VARCHAR2,
        p_warehouse    IN VARCHAR2,
        p_batch        IN VARCHAR2
    ) RETURN t_product_tab;

    FUNCTION fun_product_json (
        p_product_name IN VARCHAR2,
        p_warehouse    IN VARCHAR2,
        p_batch        IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION fun_price_json (
        p_product_code NUMBER,
        p_unit         VARCHAR2
    ) RETURN CLOB;

    FUNCTION fun_get_tax_percentage (
        p_product_code NUMBER
    ) RETURN NUMBER;

    FUNCTION fun_save_quotation (
        p_clob  CLOB
    ) RETURN CLOB;

    FUNCTION fun_get_inventry_number (
        p_user IN VARCHAR2,
        p_error_message OUT VARCHAR2
    ) RETURN NUMBER;

END pkg_quotation;

/


CREATE OR REPLACE PACKAGE BODY pkg_quotation AS

    FUNCTION fun_factor_operator (
        p_product_code NUMBER,
        p_unit         VARCHAR2
    ) RETURN t_facto_operator AS
        rec_result t_facto_operator;
    BEGIN
        SELECT
            b.factor,
            b.operador
        INTO
            rec_result.factor,
            rec_result.operator
        FROM
            inv_unidad_medida      a,
            inv_unidad_alternativa b
        WHERE
                a.cod_unidad = b.cod_unidad
            AND a.cod_unidad = p_unit
            AND b.cod_articulo = p_product_code;

        RETURN rec_result;
    EXCEPTION
        WHEN no_data_found THEN
            rec_result.factor := 1;
            rec_result.operator := '*';
            RETURN rec_result;
    END;

    FUNCTION fun_product_list (
        p_product_name IN VARCHAR2,
        p_warehouse    IN VARCHAR2,
        p_batch        IN VARCHAR2
    ) RETURN t_product_tab AS

        l_tab            t_product_tab := t_product_tab();
        CURSOR cur_products IS
        SELECT
            a.cod_articulo    AS code,
            a.nombre_articulo AS name,
            SUM(b.existencia) AS stock,
            a.cod_unidad      AS unit_main,
            a.unidad_con      AS unit
        FROM
            inv_articulo   a,
            inv_bodega_art b
        WHERE
                a.cod_articulo = b.cod_articulo
            AND a.estado = 'A'
            AND upper(a.nombre_articulo) LIKE '%'
                                              || upper(p_product_name)
                                              || '%'
            AND b.cod_bodega = p_warehouse
            AND b.cod_inventario = p_batch
        GROUP BY
            a.cod_articulo,
            a.nombre_articulo,
            a.cod_unidad,
            a.unidad_con
        ORDER BY
            a.nombre_articulo;

        i                NUMBER := 0;
        v_result         t_facto_operator;
        v_price          NUMBER;
        v_price_of_unit  NUMBER;
        v_stock          NUMBER;
        v_tax_percentage NUMBER;
    BEGIN
        FOR p IN cur_products LOOP
            i := i + 1;
            l_tab.extend;
            v_price := fun_get_price(p.code);
            v_result := fun_factor_operator(p.code, p.unit);
            v_price_of_unit := inventarios.fn_trans_precio(v_price, v_result.factor, v_result.operator);
            v_stock := inventarios.fn_transformar(p.stock, v_result.factor, v_result.operator);

            v_tax_percentage := fun_get_tax_percentage(p.code);
            l_tab(l_tab.last) := t_product_row(i, p.code, p.name, v_stock, p.unit_main,
                                               p.unit, v_price_of_unit, v_tax_percentage);

        END LOOP;

        RETURN l_tab;
    END;

    FUNCTION fun_product_json (
        p_product_name IN VARCHAR2,
        p_warehouse    IN VARCHAR2,
        p_batch        IN VARCHAR2
    ) RETURN CLOB AS
        l_cursor SYS_REFCURSOR;
        l_clob   CLOB;
    BEGIN
        OPEN l_cursor FOR SELECT
                                                t.id             AS "id",
                                                t.code           AS "code",
                                                t.name           AS "name",
                                                t.stock          AS "stock",
                                                t.unit_main      AS "unitMain",
                                                t.unit           AS "unit",
                                                t.price          AS "price",
                                                t.tax_percentage AS "taxPercentage",
                                                CURSOR (
                                                    SELECT
                                                        u.um     AS "unit",
                                                        u.factor AS "factor"
                                                    FROM
                                                        v_product_units u
                                                    WHERE
                                                        u.code = t.code
                                                )                AS "units"
                                            FROM
                                                TABLE ( fun_product_list(p_product_name, p_warehouse, p_batch) ) t
                          ORDER BY
                              t.name;

        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('data', l_cursor);
        apex_json.close_object;
        RETURN apex_json.get_clob_output(p_free => TRUE);
    END fun_product_json;

    FUNCTION fun_price_json (
        p_product_code NUMBER,
        p_unit         VARCHAR2
    ) RETURN CLOB AS
        l_cursor   SYS_REFCURSOR;
        v_price    NUMBER;
        v_factor   NUMBER;
        v_operator VARCHAR2(1);
    BEGIN
        BEGIN
            SELECT
                factor,
                operator
            INTO
                v_factor,
                v_operator
            FROM
                v_product_units
            WHERE
                    code = p_product_code
                AND um = p_unit;

        EXCEPTION
            WHEN OTHERS THEN
                apex_json.initialize_clob_output;
                apex_json.open_object;
                apex_json.write('price', -1);
                apex_json.close_object;
                RETURN apex_json.get_clob_output(p_free => TRUE);
        END;

        v_price := inventarios.fn_trans_precio(
            fun_get_price(p_product_code),
            v_factor,
            v_operator
        );
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('price', v_price);
        apex_json.close_object;
        RETURN apex_json.get_clob_output(p_free => TRUE);
    END fun_price_json;

    FUNCTION fun_get_tax_percentage (
        p_product_code NUMBER
    ) RETURN NUMBER AS
        v_value NUMBER;
    BEGIN
        SELECT
            b.valor
        INTO v_value
        FROM
            inv_articulo a,
            inv_iva      b
        WHERE
                a.cod_articulo = p_product_code
            AND a.cod_iva = b.cod_iva;

        RETURN v_value;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END fun_get_tax_percentage;

    FUNCTION fun_get_price (
        p_product IN NUMBER
    ) RETURN NUMBER AS
        result NUMBER;
    BEGIN
        SELECT
            aux_precio
        INTO result
        FROM
            fac_catalogo_precio_d
        WHERE
                cod_catalogo = '01'
            AND cod_articulo = p_product;

        RETURN result;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END fun_get_price;

    FUNCTION fun_save_quotation (
        p_clob CLOB
    ) RETURN CLOB AS

        v_customer_code     NUMBER;
        v_seller_code       NUMBER;
        v_user              VARCHAR2(99);
        v_error             VARCHAR2(9000) := NULL;
        v_inventry_number   NUMBER;
        v_message           VARCHAR2(32767) := '';
        v_paths             apex_t_varchar2;
        v_date              DATE := sysdate;
        v_unit_cost         NUMBER;
        v_product_code      NUMBER;
        v_warehouse_code    VARCHAR2(9);
        v_batch_code        VARCHAR2(9);
        v_unit              VARCHAR2(2);
        v_quantity          NUMBER;
        v_quantity_auxiliar NUMBER;
    BEGIN
        apex_json.parse(p_clob);
        v_customer_code := apex_json.get_number(p_path => 'customerCode');
        v_seller_code := apex_json.get_number(p_path => 'sellerCode');
        v_user := upper(apex_json.get_varchar2(p_path => 'user'));
        v_inventry_number := fun_get_inventry_number(v_user, v_error);
        IF v_error IS NOT NULL THEN
            v_message := '{ "success": false, "message": "Number inventry - '
                         || v_error
                         || '"}';
            RETURN v_message;
        END IF;

        INSERT INTO fac_tmp_fact_c (
            egreso_inv,
            ei,
            nombre_usuario,
            cod_documento,
            cont_cred,
            cod_vendedor,
            cod_cliente,
            porc_comision,
            cod_divisa,
            razon_social,
            valor_divisa,
            fecha_factura,
            descuentos,
            otr_descuentos,
            iva,
            recargos,
            total_sin_iva,
            estado,
            total_con_iva,
            fecha_estado
        ) VALUES ( v_inventry_number,
                   'SAI',
                   v_user,
                   'FAC',
                   '0',
                   v_seller_code,
                   v_customer_code,
                   0,
                   '01',
                   '',
                   1,
                   v_date,
                   0,
                   0,
                   0,
                   0,
                   0,
                   'E',
                   0,
                   v_date );

        inventarios.cabecera('SAI',
                             v_inventry_number,
                             NULL,
                             v_customer_code,
                             NULL,
                             v_date,
                             '01',
                             'FAC',
                             inventarios.fn_cod_movimiento('VENTAS'),
                             'Quotation',
                             v_user,
                             'G',
                             0,
                             0,
                             0,
                             v_date,
                             0,
                             0,
                             0,
                             0,
                             0,
                             NULL,
                             '0',
                             0,
                             NULL,
                             0);

        v_paths := apex_json.find_paths_like(p_return_path => 'details[%]');
        FOR i IN 1..v_paths.count LOOP
            v_product_code := apex_json.get_number(p_path => v_paths(i)
                                                             || '.productCode');

            v_warehouse_code := apex_json.get_varchar2(p_path => v_paths(i)
                                                                 || '.warehouserCode');

            v_batch_code := apex_json.get_varchar2(p_path => v_paths(i)
                                                             || '.batch');

            v_unit := apex_json.get_varchar2(p_path => v_paths(i)
                                                       || '.unit');

            v_quantity := apex_json.get_number(p_path => v_paths(i)
                                                         || '.quantity');

            v_quantity_auxiliar := apex_json.get_number(p_path => v_paths(i)
                                                                  || '.quantity_auxiliar');

            INSERT INTO fac_tmp_fact_d (
                ei,
                egreso_inv,
                cod_articulo,
                cantidad,
                auxiliar,
                cod_unidad,
                cod_bodega,
                cod_inventario,
                factor,
                operador,
                precio_unitario,
                aux_cantidad,
                porcentaje_iva,
                porc_desc_vol,
                cantidad_devuelta,
                porc_desc_pago,
                porc_desc_prom,
                entregado,
                porcentaje_ice,
                valor_ice
            ) VALUES ( 'SAI',
                       v_inventry_number,
                       v_product_code,
                       v_quantity,
                       i,
                       v_unit,
                       v_warehouse_code,
                       v_batch_code,
                       apex_json.get_number(p_path => v_paths(i)
                                                      || '.factor'),
                       apex_json.get_varchar2(p_path => v_paths(i)
                                                        || '.operator'),
                       apex_json.get_number(p_path => v_paths(i)
                                                      || '.price'),
                       v_quantity_auxiliar,
                       apex_json.get_number(p_path => v_paths(i)
                                                      || '.taxPercentage'),
                       0,
                       0,
                       0,
                       0,
                       'E',
                       0,
                       0 );

            v_unit_cost := inventarios.fn_costo_unitario(v_product_code);
            inventarios.detalle('SAI',
                                v_inventry_number,
                                i,
                                v_product_code,
                                v_warehouse_code,
                                v_unit,
                                v_batch_code,
                                v_quantity,
                                NULL,
                                v_unit_cost * v_quantity,
                                v_unit_cost,
                                apex_json.get_number(p_path => v_paths(i)
                                                               || '.price'),
                                'G',
                                0,
                                v_date,
                                0,
                                0,
                                apex_json.get_number(p_path => v_paths(i)
                                                               || '.taxPercentage'),
                                0,
                                0,
                                v_quantity_auxiliar);

        END LOOP;

        COMMIT;
        v_message := '{ "success": true, "message": "Created quotation", "quotation": '
                     || v_inventry_number
                     || '}';
        RETURN v_message;
    END fun_save_quotation;

    FUNCTION fun_get_inventry_number (
        p_user          IN VARCHAR2,
        p_error_message OUT VARCHAR2
    ) RETURN NUMBER AS
        v_inventry_number NUMBER;
        v_final_number    NUMBER;
        v_count           NUMBER;
    BEGIN
        SELECT
            b.numero_actual,
            b.numero_final,
            a.num_contador
        INTO
            v_inventry_number,
            v_final_number,
            v_count
        FROM
            gnr_usua_cont    a,
            gnr_contador_doc b
        WHERE
                a.nombre_usuario = p_user
            AND a.cod_modulo = b.cod_modulo
            AND a.cod_documento = b.cod_documento
            AND a.num_contador = b.num_contador
            AND a.cod_modulo = '03'
            AND a.cod_documento = 'SAI';

        IF v_count <> '99' THEN
            IF v_inventry_number > v_final_number THEN
                p_error_message := 'Final number is less';
                RETURN 0;
            END IF;
            UPDATE gnr_contador_doc
            SET
                numero_actual = numero_actual + 1
            WHERE
                    cod_modulo = '03'
                AND cod_documento = 'SAI'
                AND num_contador = (
                    SELECT
                        num_contador
                    FROM
                        gnr_usua_cont
                    WHERE
                            nombre_usuario = p_user
                        AND cod_modulo = '03'
                        AND cod_documento = 'SAI'
                );

            COMMIT;
        ELSE
            p_error_message := 'Error to update count';
            RETURN 0;
        END IF;

        p_error_message := NULL;
        RETURN v_inventry_number;
    EXCEPTION
        WHEN OTHERS THEN
            p_error_message := sqlerrm
                               || ' '
                               || sqlcode;
            RETURN 0;
    END fun_get_inventry_number;

END pkg_quotation;
/
