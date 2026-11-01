
CREATE EXTENSION IF NOT EXISTS btree_gist;


ALTER TABLE barberos ADD CONSTRAINT uq_barberos_barberia_id UNIQUE (barberia_id, id);
ALTER TABLE clientes ADD CONSTRAINT uq_clientes_barberia_id UNIQUE (barberia_id, id);


CREATE TABLE servicios (
    id            uuid           PRIMARY KEY DEFAULT uuidv7(),
    barberia_id   uuid           NOT NULL,
    nombre        varchar(100)   NOT NULL,
    precio        numeric(10,2)  NOT NULL,
    duracion_min  integer        NOT NULL,
    activo        boolean        NOT NULL DEFAULT true,
    creado_en     timestamptz    NOT NULL DEFAULT now(),

    CONSTRAINT fk_servicios_barberia FOREIGN KEY (barberia_id) REFERENCES barberias (id),
    CONSTRAINT uq_servicios_barberia_nombre UNIQUE (barberia_id, nombre),
    CONSTRAINT uq_servicios_barberia_id UNIQUE (barberia_id, id),
    CONSTRAINT ck_servicios_precio CHECK (precio >= 0),
    CONSTRAINT ck_servicios_duracion CHECK (duracion_min BETWEEN 5 AND 480)
);


CREATE TABLE citas (
    id           uuid          PRIMARY KEY DEFAULT uuidv7(),
    barberia_id  uuid          NOT NULL,
    barbero_id   uuid          NOT NULL,
    cliente_id   uuid          NOT NULL,
    servicio_id  uuid          NOT NULL,
    inicio       timestamptz   NOT NULL,
    fin          timestamptz   NOT NULL,
    estado       varchar(20)   NOT NULL DEFAULT 'pendiente',
    notas        varchar(300),
    version      integer       NOT NULL DEFAULT 0,
    creado_en    timestamptz   NOT NULL DEFAULT now(),

    -- Cada referencia exige que el registro sea de la MISMA barberia
    CONSTRAINT fk_citas_barbero  FOREIGN KEY (barberia_id, barbero_id)  REFERENCES barberos  (barberia_id, id),
    CONSTRAINT fk_citas_cliente  FOREIGN KEY (barberia_id, cliente_id)  REFERENCES clientes  (barberia_id, id),
    CONSTRAINT fk_citas_servicio FOREIGN KEY (barberia_id, servicio_id) REFERENCES servicios (barberia_id, id),

    CONSTRAINT ck_citas_horario CHECK (fin > inicio),
    CONSTRAINT ck_citas_estado  CHECK (estado IN ('pendiente', 'confirmada', 'atendida', 'cancelada', 'no_asistio')),

    -- Un barbero no puede tener dos citas activas que se crucen
    CONSTRAINT ex_citas_barbero_sin_cruce EXCLUDE USING gist (
        barbero_id WITH =,
        tstzrange(inicio, fin, '[)') WITH &&
    ) WHERE (estado <> 'cancelada')
);

-- Agenda del dia de una barberia
CREATE INDEX ix_citas_barberia_inicio ON citas (barberia_id, inicio);
-- Historial de un cliente
CREATE INDEX ix_citas_cliente ON citas (barberia_id, cliente_id);