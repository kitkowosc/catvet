-- CatVet SQL — week 2, Day 1
-- Load with:  psql -h localhost -p 5432 -U catvet -d catvet_sql -f src/main/resources/db/schema.sql

DROP TABLE IF EXISTS cats CASCADE;

CREATE TABLE cats (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT NOT NULL,
    birth_date DATE,
    breed      TEXT,
    CONSTRAINT birth_date_not_future CHECK (birth_date <= CURRENT_DATE)
);

INSERT INTO cats (name, birth_date, breed) VALUES
    ('Mruczek',  '2019-04-11', 'dachowiec'),
    ('Filemon',  '2021-08-02', 'brytyjski'),
    ('Kicia',    '2023-01-19', 'maine coon'),
    ('Puszek',   '2016-11-30', 'perski'),
    ('Bonifacy', '2022-06-07', 'dachowiec');
