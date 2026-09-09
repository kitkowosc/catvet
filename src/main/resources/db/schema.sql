-- CatVet SQL — week 2, Day 1 -- Load with:  psql -h localhost -p 5432 -U catvet -d catvet_sql -f src/main/resources/db/schema.sql
DROP TABLE IF EXISTS visit_medications CASCADE;
DROP TABLE IF EXISTS visits CASCADE;
DROP TABLE IF EXISTS cats CASCADE;
DROP TABLE IF EXISTS medications CASCADE;
DROP TABLE IF EXISTS owners CASCADE;

CREATE TABLE owners (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name TEXT NOT NULL,
    CONSTRAINT owners_full_name CHECK (full_name ~'^\S+\s+\S+'),
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    city TEXT,
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE medications (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    form TEXT NOT NULL,
    CONSTRAINT medications_form CHECK (form IN ('tabl', 'liq', 'inj', 'inhl', 'drops', 'inta-vag', 'rectal-adm', 'nasal')),
    active_substance TEXT NOT NULL
);

CREATE TABLE cats (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id    BIGINT NOT NULL REFERENCES owners(id) ON DELETE RESTRICT,
    name        TEXT NOT NULL,
    breed       TEXT NOT NULL,
    sex         TEXT NOT NULL DEFAULT 'unknown',
    neutered    BOOL,
    birth_date  DATE,
    weight_kg   NUMERIC (5,2),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT cats_birth_not_future CHECK (birth_date <= CURRENT_DATE),
    CONSTRAINT cats_sex_allowed      CHECK (sex IN ('male', 'female', 'unknown'))
);

CREATE TABLE visits (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cat_id BIGINT NOT NULL REFERENCES cats(id) ON DELETE RESTRICT,
    visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
    weight_kg NUMERIC (5,2),
    temperature_c NUMERIC (3,1),
    complaint TEXT,
    diagnosis TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT visits_not_fututre CHECK (visit_date <= CURRENT_DATE)
);

CREATE TABLE visit_medications (
    visit_id      BIGINT NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    medication_id BIGINT NOT NULL REFERENCES medications(id) ON DELETE RESTRICT,
    dosage        TEXT NOT NULL,
    duration_days INTEGER NOT NULL,
    PRIMARY KEY (visit_id, medication_id)
);