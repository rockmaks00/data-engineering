CREATE DATABASE IF NOT EXISTS pg_source
ENGINE = PostgreSQL(
    'postgres:5432',
    'main',
    'postgres',
    'postgres',
    'core'
);

CREATE DATABASE IF NOT EXISTS analytics;

CREATE VIEW IF NOT EXISTS analytics.v_objects AS
SELECT
    o.id AS id,
    o.uuid AS uuid,
    o.object_id AS object_id,
    o.price AS price,
    o.square AS square,
    o.lat AS lat,
    o.lon AS lon,
    o.load_date AS load_date,

    c.name AS complex_name,
    d.name AS developer_name,
    city.name AS city_name,
    w.name AS wall_type_name,
    ds.name AS data_source_name

FROM pg_source.objects AS o

LEFT JOIN pg_source.complexes AS c
    ON o.complex_id = c.id

LEFT JOIN pg_source.developers AS d
    ON o.developer_id = d.id

LEFT JOIN pg_source.cities AS city
    ON o.city_id = city.id

LEFT JOIN pg_source.wall_types AS w
    ON o.wall_type_id = w.id

LEFT JOIN pg_source.data_sources AS ds
    ON o.data_source_id = ds.id;