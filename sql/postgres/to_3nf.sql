BEGIN;

CREATE SCHEMA IF NOT EXISTS core;

-- Создание справочников
CREATE TABLE IF NOT EXISTS core.complexes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.developers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.cities (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.data_sources (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS core.wall_types (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Таблица объектов
CREATE TABLE IF NOT EXISTS core.objects (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE,
    object_id BIGINT,
    price NUMERIC(15, 2) NOT NULL,
    square NUMERIC(10, 2) NOT NULL,
    lat NUMERIC(16, 13),
    lon NUMERIC(16, 13),
    load_date TIMESTAMP NOT NULL,
    complex_id BIGINT REFERENCES core.complexes(id),
    developer_id BIGINT REFERENCES core.developers(id),
    wall_type_id BIGINT REFERENCES core.wall_types(id),
    city_id BIGINT NOT NULL REFERENCES core.cities(id),
    data_source_id BIGINT NOT NULL REFERENCES core.data_sources(id)
);

-- Заполнение справочников данными
INSERT INTO core.complexes (name)
SELECT DISTINCT TRIM(complex_name::TEXT)
FROM stage.test_dataset
WHERE NULLIF(TRIM(complex_name::TEXT), '') IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO core.developers (name)
SELECT DISTINCT TRIM(developer_name::TEXT)
FROM stage.test_dataset
WHERE NULLIF(TRIM(developer_name::TEXT), '') IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO core.cities (name)
SELECT DISTINCT TRIM(city::TEXT)
FROM stage.test_dataset
WHERE NULLIF(TRIM(city::TEXT), '') IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO core.data_sources (name)
SELECT DISTINCT TRIM(data_source::TEXT)
FROM stage.test_dataset
WHERE NULLIF(TRIM(data_source::TEXT), '') IS NOT NULL
ON CONFLICT (name) DO NOTHING;

INSERT INTO core.wall_types (name)
SELECT DISTINCT TRIM(wall_type::TEXT)
FROM stage.test_dataset
WHERE NULLIF(TRIM(wall_type::TEXT), '') IS NOT NULL
ON CONFLICT (name) DO NOTHING;

-- Заполнение объектов
INSERT INTO core.objects (
    uuid,
    object_id,
    complex_id,
    developer_id,
    price,
    square,
    lat,
    lon,
    wall_type_id,
    load_date,
    city_id,
    data_source_id
)
SELECT
    s.uuid::UUID,
    NULLIF(TRIM(s.object_id::TEXT), '')::BIGINT,
    c.id,
    d.id,
    s.price::NUMERIC(14, 2),
    s.square::NUMERIC(10, 2),
    NULLIF(
        REPLACE(TRIM(s.lat::TEXT), ',', '.'),
        ''
    )::NUMERIC(16, 13),
    NULLIF(
        REPLACE(TRIM(s.lon::TEXT), ',', '.'),
        ''
    )::NUMERIC(16, 13),
    w.id,
    s.load_date::TIMESTAMP,
    ci.id,
    ds.id
FROM stage.test_dataset AS s
LEFT JOIN core.complexes AS c
    ON c.name = NULLIF(TRIM(s.complex_name::TEXT), '')
LEFT JOIN core.developers AS d
    ON d.name = NULLIF(TRIM(s.developer_name::TEXT), '')
LEFT JOIN core.wall_types AS w
    ON w.name = NULLIF(TRIM(s.wall_type::TEXT), '')
LEFT JOIN core.cities AS ci
    ON ci.name = NULLIF(TRIM(s.city::TEXT), '')
LEFT JOIN core.data_sources AS ds
    ON ds.name = NULLIF(TRIM(s.data_source::TEXT), '');

-- Расстановка индексов для объектов;
-- Поскольку нет информации какие запросы примерно будут выполняться расставил только на ключи
CREATE INDEX IF NOT EXISTS idx_objects_object_id
    ON core.objects (object_id);

CREATE INDEX IF NOT EXISTS idx_objects_complex_id
    ON core.objects (complex_id);

CREATE INDEX IF NOT EXISTS idx_objects_developer_id
    ON core.objects (developer_id);

CREATE INDEX IF NOT EXISTS idx_objects_city_id
    ON core.objects (city_id);

CREATE INDEX IF NOT EXISTS idx_objects_data_source_id
    ON core.objects (data_source_id);

CREATE INDEX IF NOT EXISTS idx_objects_wall_type_id
    ON core.objects (wall_type_id);

COMMIT;