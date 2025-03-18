CREATE OR REPLACE VIEW v_users AS
    SELECT
        lower(nombre_usuario)                            username,
        clave                                     password,
        nvl(tipo_usuario, 'NORMAL')               type,
        decode(estado, 'A', 'Active', 'Inactive') status
    FROM
        gnr_usuarios;