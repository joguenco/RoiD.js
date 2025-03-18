CREATE OR REPLACE FORCE VIEW v_customers AS
    SELECT
        a.cod_cliente      AS code,
        b.cod_documento    AS identification_type,
        b.documento        AS identification,
        b.nombres          AS firstname,
        b.apellidos        AS lastname,
        b.razon_social     AS legal_name,
        b.nombre_comercial AS trade_name,
        b.mail             AS email,
        b.direccion        AS address,
        b.direccion2       AS address_alternative,
        b.telefono         AS phone,
        a.cod_vendedor     AS seller_code,
        a.observaciones    AS observation
    FROM
        cxc_cliente  a,
        gnr_persona  b,
        gnr_persona  c,
        fac_vendedor d
    WHERE
            a.cod_persona = b.cod_persona
        AND a.cod_vendedor = d.cod_vendedor
        AND c.cod_persona = d.cod_persona;
--------------------------------------------------------
--  DDL for Trigger v_customers
--------------------------------------------------------

CREATE OR REPLACE TRIGGER tgr_customers INSTEAD OF
    DELETE OR INSERT OR UPDATE ON v_customers
    REFERENCING
            NEW AS new
            OLD AS old
    FOR EACH ROW
DECLARE
    v_codigo_persona NUMBER;
BEGIN
    IF inserting THEN
        v_codigo_persona := s_gnr_persona.nextval;
        INSERT INTO gnr_persona (
            cod_persona,
            tipo_persona,
            documento,
            apellidos,
            cod_documento,
            nombres,
            razon_social,
            nombre_comercial,
            direccion,
            direccion2,
            telefono,
            mail
        ) VALUES (
            v_codigo_persona,
            fun_is_natural_juridico(:new.identification),
            :new.identification,
            :new.lastname,
            :new.identification_type,
            :new.firstname,
            :new.legal_name,
            :new.trade_name,
            :new.address,
            :new.address_alternative,
            :new.phone,
            :new.email
        );

        INSERT INTO cxc_cliente (
            cod_catalogo,
            cod_grupo,
            cod_persona,
            cod_tipo,
            cod_vendedor,
            cod_cliente,
            cod_zona,
            cod_sector,
            fecha_creacion,
            limite_factura,
            indicador,
            paga_iva,
            estado,
            fecha_estado,
            observaciones
        ) VALUES (
            '01',
            '01',
            v_codigo_persona,
            '01',
            :new.seller_code,
            s_cxc_cliente.NEXTVAL,
            '02',
            '90',
            sysdate,
            0,
            'A',
            'S',
            'A',
            sysdate,
            :new.observation
        );

    ELSIF updating THEN
        SELECT
            cod_persona
        INTO v_codigo_persona
        FROM
            cxc_cliente
        WHERE
            cod_cliente = :old.code;

        UPDATE gnr_persona
        SET
            tipo_persona = fun_is_natural_juridico(:new.identification),
            documento = :new.identification,
            apellidos = :new.lastname,
            cod_documento = :new.identification_type,
            nombres = :new.firstname,
            razon_social = :new.legal_name,
            nombre_comercial = :new.trade_name,
            direccion = :new.address,
            direccion2 = :new.address_alternative,
            telefono = :new.phone,
            mail = :new.email
        WHERE
            cod_persona = v_codigo_persona;

        UPDATE cxc_cliente
        SET
            fecha_estado = sysdate,
            observaciones = :new.observation
        WHERE
            cod_cliente = :old.code;

    ELSIF deleting THEN
        SELECT
            cod_persona
        INTO v_codigo_persona
        FROM
            cxc_cliente
        WHERE
            cod_cliente = :old.code;

        DELETE FROM cxc_saldo_cliente
        WHERE
            cod_cliente = :old.code;

        DELETE FROM cxc_cliente
        WHERE
            cod_cliente = :old.code;

        DELETE FROM gnr_persona
        WHERE
            cod_persona = v_codigo_persona;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
        RAISE;
END tgr_customers;
/

ALTER TRIGGER tgr_customers ENABLE;