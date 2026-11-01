
CREATE TABLE barberias (
    id          uuid         PRIMARY KEY DEFAULT uuidv7(),
    nombre      varchar(100) NOT NULL,
    slug        varchar(60)  NOT NULL,
    telefono    varchar(15),
    direccion   varchar(200),
    activo      boolean      NOT NULL DEFAULT true,
    creado_en   timestamptz  NOT NULL DEFAULT now(),

    CONSTRAINT uq_barberias_slug UNIQUE (slug),
    CONSTRAINT ck_barberias_slug CHECK (slug ~ '^[a-z0-9-]+$')
);


CREATE TABLE barberos (
    id                   uuid          PRIMARY KEY DEFAULT uuidv7(),
    barberia_id          uuid          NOT NULL,
    nombre               varchar(100)  NOT NULL,
    telefono             varchar(15),
    porcentaje_comision  numeric(5,2)  NOT NULL DEFAULT 0,
    activo               boolean       NOT NULL DEFAULT true,
    creado_en            timestamptz   NOT NULL DEFAULT now(),

    CONSTRAINT fk_barberos_barberia FOREIGN KEY (barberia_id) REFERENCES barberias (id),
    CONSTRAINT ck_barberos_comision CHECK (porcentaje_comision BETWEEN 0 AND 100)
);

CREATE INDEX ix_barberos_barberia ON barberos (barberia_id);

CREATE TABLE clientes (
    id           uuid          PRIMARY KEY DEFAULT uuidv7(),
    barberia_id  uuid          NOT NULL,
    nombre       varchar(100)  NOT NULL,
    telefono     varchar(15)   NOT NULL,
    creado_en    timestamptz   NOT NULL DEFAULT now(),

    CONSTRAINT fk_clientes_barberia FOREIGN KEY (barberia_id) REFERENCES barberias (id),
    CONSTRAINT uq_clientes_barberia_telefono UNIQUE (barberia_id, telefono)
);