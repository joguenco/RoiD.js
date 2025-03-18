DROP TYPE t_product_tab;

DROP TYPE t_product_row;

CREATE TYPE t_product_row AS OBJECT (
        id    NUMBER,
        code  NUMBER,
        name  VARCHAR2(300),
        stock NUMBER,
        unit_main  VARCHAR2(9),
        unit  VARCHAR2(9),
        price NUMBER,
        tax_percentage NUMBER
);
/

CREATE TYPE t_product_tab IS
    TABLE OF t_product_row;
/