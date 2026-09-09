-- CatVet SQL — Dzień 2: dane przykładowe
-- Load with:  psql -h localhost -U catvet -d catvet_sql -v ON_ERROR_STOP=1 -f src/main/resources/db/seed.sql
-- Wymaga wcześniejszego uruchomienia schema.sql.

TRUNCATE visit_medications, visits, cats, medications, owners RESTART IDENTITY CASCADE;

-- ── OWNERS (20) ─────────────────────────────────────────────────────────
-- kilku bez telefonu — Dzień 3 pyta o "owners with no phone number on file"
INSERT INTO owners (full_name, email, phone, city, address) VALUES
    ('Anna Kowalska',        'anna.kowalska@example.com',    '601234567', 'Kraków',   'ul. Długa 12/4'),
    ('Piotr Zieliński',      'p.zielinski@example.com',      '602345678', 'Warszawa', 'ul. Marszałkowska 8'),
    ('Maria Wójcik',         'maria.wojcik@example.com',     '603456789', 'Gdańsk',   'ul. Morska 44'),
    ('Tomasz Lewandowski',   't.lewandowski@example.com',    NULL,        'Kraków',   'ul. Krowoderska 3'),
    ('Katarzyna Nowak',      'k.nowak@example.com',          '605678901', 'Wrocław',  'ul. Świdnicka 21'),
    ('Michał Wiśniewski',    'm.wisniewski@example.com',     '606789012', 'Poznań',   'ul. Półwiejska 17'),
    ('Agnieszka Dąbrowska',  'a.dabrowska@example.com',      '607890123', 'Kraków',   'ul. Zwierzyniecka 9'),
    ('Paweł Kamiński',       'p.kaminski@example.com',       '608901234', 'Łódź',     'ul. Piotrkowska 102'),
    ('Magdalena Lis',        'm.lis@example.com',            NULL,        'Gdynia',   'ul. Świętojańska 55'),
    ('Rafał Szymański',      'r.szymanski@example.com',      '610123456', 'Katowice', 'ul. Mariacka 6'),
    ('Joanna Woźniak',       'j.wozniak@example.com',        '611234567', 'Kraków',   'ul. Karmelicka 30'),
    ('Grzegorz Kozłowski',   'g.kozlowski@example.com',      '612345678', 'Warszawa', 'ul. Puławska 140'),
    ('Ewa Jankowska',        'ewa.jankowska@example.com',    NULL,        'Szczecin', 'ul. Jagiellońska 4'),
    ('Marcin Mazur',         'm.mazur@example.com',          '614567890', 'Lublin',   'ul. Krakowskie Przedmieście 12'),
    ('Natalia Krawczyk',     'n.krawczyk@example.com',       '615678901', 'Kraków',   'ul. Starowiślna 62'),
    ('Łukasz Piotrowski',    'l.piotrowski@example.com',     '616789012', 'Bydgoszcz','ul. Gdańska 27'),
    ('Aleksandra Grabowska', 'a.grabowska@example.com',      NULL,        'Rzeszów',  'ul. 3 Maja 18'),
    ('Krzysztof Nowicki',    'k.nowicki@example.com',        '618901234', 'Kraków',   'ul. Wielicka 5'),
    ('Barbara Pawlak',       'b.pawlak@example.com',         '619012345', 'Toruń',    'ul. Szeroka 33'),
    ('Sebastian Michalski',  's.michalski@example.com',      '620123456', 'Olsztyn',  'ul. Warszawska 71');

-- ── MEDICATIONS (10) ────────────────────────────────────────────────────
INSERT INTO medications (name, form, active_substance) VALUES
    ('Milbemax',     'tabl',  'milbemycyny oksym + prazykwantel'),
    ('Purevax RCP',  'inj',   'szczepionka atenuowana FPV/FHV/FCV'),
    ('Metronidazol', 'tabl',  'metronidazol'),
    ('Amoksiklav',   'liq',   'amoksycylina + kwas klawulanowy'),
    ('Meloxidyl',    'liq',   'meloksykam'),
    ('Stronghold',   'drops', 'selamektyna'),
    ('Convenia',     'inj',   'cefowecyna'),
    ('Tobradex',     'drops', 'tobramycyna + deksametazon'),
    ('Ronaxan',      'tabl',  'doksycyklina'),
    ('Flixotide',    'inhl',  'propionian flutykazonu');

-- ── CATS (30) ───────────────────────────────────────────────────────────
-- owner_id 18/19/20 celowo bez kotów — Dzień 4 potrzebuje LEFT JOIN
-- 'Mitek' i 'Dymitr' — Dzień 3 pyta o imiona zawierające 'mit'
INSERT INTO cats (owner_id, name, breed, sex, neutered, birth_date, weight_kg) VALUES
    ( 1, 'Mruczek',  'dachowiec',                'male',   TRUE,  '2019-04-11', 4.80),
    ( 1, 'Filemon',  'brytyjski krótkowłosy',    'male',   TRUE,  '2021-08-02', 5.60),
    ( 1, 'Kicia',    'maine coon',               'female', TRUE,  '2023-01-19', 6.20),
    ( 2, 'Puszek',   'perski',                   'male',   TRUE,  '2016-11-30', 4.10),
    ( 2, 'Bonifacy', 'dachowiec',                'male',   FALSE, '2022-06-07', 5.30),
    ( 2, 'Luna',     'ragdoll',                  'female', TRUE,  '2020-03-15', 4.70),
    ( 3, 'Mitek',    'dachowiec',                'male',   TRUE,  '2018-09-23', 5.10),
    ( 3, 'Dymitr',   'syjamski',                 'male',   FALSE, '2024-02-11', 3.90),
    ( 3, 'Tofik',    'dachowiec',                'male',   TRUE,  '2015-05-30', 4.40),
    ( 3, 'Zuzia',    'brytyjski krótkowłosy',    'female', TRUE,  '2021-12-01', 4.20),
    ( 4, 'Bazyl',    'norweski leśny',           'male',   TRUE,  '2017-07-19', 6.80),
    ( 4, 'Fasola',   'dachowiec',                'female', TRUE,  '2023-04-28', 3.60),
    ( 5, 'Kajtek',   'dachowiec',                'male',   TRUE,  '2020-10-05', 5.00),
    ( 5, 'Mgiełka',  'rosyjski niebieski',       'female', TRUE,  '2022-01-14', 3.80),
    ( 6, 'Gustaw',   'maine coon',               'male',   FALSE, '2024-06-20', 5.90),
    ( 7, 'Pusia',    'dachowiec',                'female', TRUE,  '2013-08-08', 3.40),
    ( 8, 'Rudy',     'dachowiec',                'male',   TRUE,  '2019-02-17', 5.50),
    ( 8, 'Sonia',    'bengalski',                'female', TRUE,  '2021-05-09', 4.00),
    ( 9, 'Kleks',    'dachowiec',                'male',   FALSE, '2025-03-22', 2.90),
    (10, 'Bella',    'sfinks',                   'female', TRUE,  '2018-11-11', 3.70),
    (11, 'Kokos',    'dachowiec',                'male',   TRUE,  '2016-04-02', 6.10),
    (11, 'Amelka',   'brytyjski krótkowłosy',    'female', TRUE,  '2022-09-27', 4.30),
    (12, 'Tygrys',   'dachowiec',                'male',   TRUE,  '2014-06-13', 5.70),
    (13, 'Nemo',     'syjamski',                 'male',   TRUE,  '2023-07-04', 4.10),
    (14, 'Miś',      'dachowiec',                'male',   FALSE, '2025-01-30', 3.20),
    (15, 'Perła',    'perski',                   'female', TRUE,  '2019-10-18', 3.90),
    (15, 'Cezar',    'maine coon',               'male',   TRUE,  '2020-12-24', 7.20),
    (16, 'Bibi',     'dachowiec',                'female', TRUE,  '2021-03-06', 4.00),
    (17, 'Szymek',   'dachowiec',                'male',   TRUE,  '2017-01-25', 5.40),
    (17, 'Fiona',    'ragdoll',                  'female', TRUE,  '2024-11-08', 4.60);

-- ── VISITS (50) ─────────────────────────────────────────────────────────
-- rozłożone na ostatnie 12 miesięcy — Dzień 4 grupuje po miesiącach
-- koty 20, 25 i 30 celowo bez żadnej wizyty
INSERT INTO visits (cat_id, visit_date, weight_kg, temperature_c, complaint, diagnosis, notes) VALUES
    ( 1, '2025-09-15', 4.70, 38.6, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              'kolejne szczepienie za 12 miesięcy'),
    ( 2, '2025-09-22', 5.50, 38.9, 'kulawizna prawej przedniej',  'stłuczenie',                        'kontrola za tydzień'),
    ( 3, '2025-10-02', 6.00, 38.4, 'kontrola po sterylizacji',    'gojenie prawidłowe',                NULL),
    ( 5, '2025-10-09', 5.20, 39.4, 'apatia, brak apetytu',        'infekcja górnych dróg oddechowych', 'antybiotyk 7 dni'),
    ( 7, '2025-10-14', 5.00, 38.5, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 9, '2025-10-21', 4.30, 38.7, 'odrobaczanie',                'profilaktyka',                      NULL),
    (11, '2025-10-28', 6.70, 38.8, 'świąd, drapanie uszu',        'świerzbowiec uszny',                'krople do uszu'),
    ( 4, '2025-11-04', 4.00, 38.3, 'kontrola geriatryczna',       'przewlekła choroba nerek, st. 2',   'dieta nerkowa'),
    (13, '2025-11-12', 4.90, 38.6, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 6, '2025-11-18', 4.60, 39.1, 'wymioty od 2 dni',            'nieżyt żołądka',                    NULL),
    (15, '2025-11-25', 5.70, 38.5, 'pierwsze szczepienie',        'zdrowy, zaszczepiony',              'dawka przypominająca za 3 tyg'),
    ( 8, '2025-12-02', 3.80, 38.9, 'biegunka',                    'giardioza',                         'metronidazol 5 dni'),
    (17, '2025-12-09', 5.40, 38.4, 'kontrola stomatologiczna',    'kamień nazębny',                    'zabieg do zaplanowania'),
    (10, '2025-12-16', 4.10, 38.6, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    (12, '2026-01-08', 3.50, 38.7, 'kastracja — wizyta kontrolna','gojenie prawidłowe',                NULL),
    ( 1, '2026-01-13', 4.80, 38.5, 'kaszel',                      'astma kotów, podejrzenie',          'RTG klatki piersiowej'),
    (19, '2026-01-20', 3.00, 38.8, 'pierwsze szczepienie',        'zdrowy, zaszczepiony',              NULL),
    (21, '2026-01-27', 6.00, 38.2, 'kontrola geriatryczna',       'nadczynność tarczycy',              'badanie T4 za miesiąc'),
    (14, '2026-02-03', 3.70, 38.6, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 3, '2026-02-10', 6.10, 39.6, 'gorączka, osowiałość',        'infekcja bakteryjna',               'antybiotyk'),
    (22, '2026-02-17', 4.20, 38.4, 'odrobaczanie',                'profilaktyka',                      NULL),
    (16, '2026-02-24', 3.30, 38.9, 'utrata masy ciała',           'przewlekła choroba nerek, st. 3',   NULL),
    (23, '2026-03-03', 5.60, 38.5, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 2, '2026-03-10', 5.60, 38.6, 'kontrola po urazie',          'wyleczony',                         NULL),
    (24, '2026-03-17', 4.00, 39.2, 'zapalenie spojówek',          'zapalenie spojówek',                'krople oczne 7 dni'),
    (26, '2026-03-24', 3.80, 38.4, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 5, '2026-03-31', 5.30, 38.7, 'świąd skóry',                 'alergia pokarmowa, podejrzenie',    'dieta eliminacyjna'),
    (27, '2026-04-07', 7.10, 38.3, 'kontrola masy ciała',         'nadwaga',                           'dieta redukcyjna'),
    ( 7, '2026-04-14', 5.10, 38.6, 'odrobaczanie',                'profilaktyka',                      NULL),
    (18, '2026-04-21', 3.90, 38.8, 'kichanie',                    'infekcja górnych dróg oddechowych', NULL),
    (28, '2026-04-28', 4.00, 38.5, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 9, '2026-05-05', 4.40, 38.6, 'kontrola geriatryczna',       'zdrowy jak na wiek',                NULL),
    (29, '2026-05-12', 5.30, 39.3, 'ropień na łapie',             'ropień pogryzieniowy',              'antybiotyk 7 dni'),
    (11, '2026-05-19', 6.80, 38.4, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    ( 1, '2026-05-26', 4.75, 38.5, 'kontrola astmy',              'astma kotów',                       'inhalator'),
    (13, '2026-06-02', 5.00, 38.6, 'zranienie ucha',              'rana szarpana',                     'szycie'),
    ( 4, '2026-06-09', 3.95, 38.4, 'kontrola nerek',              'przewlekła choroba nerek, st. 2',   NULL),
    ( 6, '2026-06-16', 4.70, 38.7, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    (15, '2026-06-23', 5.90, 38.5, 'odrobaczanie',                'profilaktyka',                      NULL),
    ( 8, '2026-06-30', 3.90, 38.8, 'nawracająca biegunka',        'giardioza, nawrót',                 NULL),
    (21, '2026-07-07', 5.90, 38.6, 'kontrola tarczycy',           'nadczynność tarczycy, wyrównana',   NULL),
    (17, '2026-07-14', 5.50, 38.4, 'zabieg usunięcia kamienia',   'stan po sanacji jamy ustnej',       NULL),
    (22, '2026-07-21', 4.30, 38.5, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL),
    (12, '2026-07-28', 3.60, 38.6, 'kontrola',                    'zdrowy',                            NULL),
    ( 3, '2026-08-04', 6.20, 38.5, 'odrobaczanie',                'profilaktyka',                      NULL),
    (19, '2026-08-11', 3.10, 38.7, 'dawka przypominająca',        'zdrowy, zaszczepiony',              NULL),
    (24, '2026-08-18', 4.10, 38.4, 'kontrola oczu',               'wyleczony',                         NULL),
    (16, '2026-08-25', 3.20, 38.9, 'pogorszenie apetytu',         'przewlekła choroba nerek, st. 3',   'płynoterapia'),
    (26, '2026-09-01', 3.90, 38.5, 'kontrola',                    'zdrowy',                            NULL),
    ( 2, '2026-09-05', 5.65, 38.6, 'szczepienie coroczne',        'zdrowy, zaszczepiony',              NULL);

-- ── VISIT_MEDICATIONS (37) ──────────────────────────────────────────────
-- wizyty 12, 20 i 33 mają po dwa leki — klucz złożony na to pozwala,
-- bo pary (visit_id, medication_id) są różne
INSERT INTO visit_medications (visit_id, medication_id, dosage, duration_days) VALUES
    ( 1,  2, '1 ml s.c. jednorazowo',      1),
    ( 2,  5, '0,05 ml/kg raz dziennie',    3),
    ( 4,  4, '0,5 ml 2× dziennie',         7),
    ( 5,  2, '1 ml s.c. jednorazowo',      1),
    ( 6,  1, '1 tabl. jednorazowo',        1),
    ( 7,  6, '1 pipeta jednorazowo',       1),
    ( 9,  2, '1 ml s.c. jednorazowo',      1),
    (10,  3, '250 mg 2× dziennie',         5),
    (11,  2, '1 ml s.c. jednorazowo',      1),
    (12,  3, '250 mg 2× dziennie',         5),
    (12,  1, '1 tabl. jednorazowo',        1),
    (14,  2, '1 ml s.c. jednorazowo',      1),
    (16, 10, '1 inhalacja 2× dziennie',   30),
    (17,  2, '0,5 ml s.c. jednorazowo',    1),
    (19,  2, '1 ml s.c. jednorazowo',      1),
    (20,  7, '8 mg/kg s.c. jednorazowo',  14),
    (20,  5, '0,05 ml/kg raz dziennie',    3),
    (21,  1, '1 tabl. jednorazowo',        1),
    (23,  2, '1 ml s.c. jednorazowo',      1),
    (25,  8, '1 kropla 3× dziennie',       7),
    (26,  2, '1 ml s.c. jednorazowo',      1),
    (27,  5, '0,05 ml/kg raz dziennie',    5),
    (29,  1, '1 tabl. jednorazowo',        1),
    (30,  9, '5 mg/kg raz dziennie',      10),
    (31,  2, '1 ml s.c. jednorazowo',      1),
    (33,  7, '8 mg/kg s.c. jednorazowo',  14),
    (33,  5, '0,05 ml/kg raz dziennie',    3),
    (34,  2, '1 ml s.c. jednorazowo',      1),
    (35, 10, '1 inhalacja 2× dziennie',   30),
    (36,  4, '0,5 ml 2× dziennie',         7),
    (38,  2, '1 ml s.c. jednorazowo',      1),
    (39,  1, '1 tabl. jednorazowo',        1),
    (40,  3, '250 mg 2× dziennie',         7),
    (43,  2, '1 ml s.c. jednorazowo',      1),
    (45,  1, '1 tabl. jednorazowo',        1),
    (46,  2, '0,5 ml s.c. jednorazowo',    1),
    (50,  2, '1 ml s.c. jednorazowo',      1);

-- ── ROZŁOŻENIE DAT REJESTRACJI ──────────────────────────────────────────
-- DEFAULT NOW() dałoby wszystkim identyczny created_at, a Dzień 3 pyta
-- o "10 ostatnio zarejestrowanych kotów" — bez zróżnicowania nie ma sortowania
UPDATE owners SET created_at = NOW() - (id * INTERVAL '23 days');
UPDATE cats   SET created_at = NOW() - (id * INTERVAL '17 days');
UPDATE visits SET created_at = visit_date + TIME '09:00';

-- ── KONTROLA ────────────────────────────────────────────────────────────
SELECT 'owners' AS tabela, COUNT(*) FROM owners
UNION ALL SELECT 'medications',       COUNT(*) FROM medications
UNION ALL SELECT 'cats',              COUNT(*) FROM cats
UNION ALL SELECT 'visits',            COUNT(*) FROM visits
UNION ALL SELECT 'visit_medications', COUNT(*) FROM visit_medications;
