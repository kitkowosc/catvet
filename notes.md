day2.
1. new funcionality can be add. f.e. owner which has lot of animals(patients)
2. also doctor can have access to data about specific pacient
3.

## Day 2 curl commands:

GET all patients:
curl -i localhost:8080/patients

GET unknown id -> 404:
curl -i localhost:8080/patients/999

POST valid cat -> 201:
curl -i -X POST localhost:8080/patients -H 'Content-Type: application/json' -d '{"name":"TestCat","breed":"tabby"}'

POST invalid cat (blank name) -> 400:
curl -i -X POST localhost:8080/patients -H 'Content-Type: application/json' -d '{"name":"","breed":""}'

PUT update existing patient:
curl -i -X PUT localhost:8080/patients/1 -H 'Content-Type: application/json' -d '{"name":"RyszardUpdated","breed":"cat"}'

DELETE patient -> 204:
curl -i -X DELETE localhost:8080/patients/1

## Day 3 curl commands:

addVisit for patient:
curl -s -X POST http://localhost:8080/patients/1/records 
-H 'Content-Type: application/json' 
-d '{"date":"2026-07-09","type":"0","notes":"gruby brzuszeczek"}


DOCKER RUN ->>
docker run -d --name catvet-postgres -e POSTGRES_USER=catvet -e POSTGRES_PASSWORD=catvet
-e POSTGRES_DB=catvet -p 5432:5432 -v catvet-pgdata:/var/lib/postgresql/data postgres:16

## Seed 20 kotow + 40 wizyt (baza catvet)

Wszystko przez REST API apki, nie przez INSERT - dane przechodza walidacje
@NotBlank i dostaja id z sekwencji Hibernate. Apka musi chodzic (port 8080)
i kontener musi byc up.

KROK 0 - warunki wstepne:
docker start catvet-postgres
./mvnw spring-boot:run
curl -s localhost:8080/actuator/health

KROK 1 - skrypt seedujacy (zapisany jako seed_api.sh, uruchomiony: bash seed_api.sh):

#!/usr/bin/env bash
set -euo pipefail
API=localhost:8080

names=(Mruczek Filemon Bonifacy Puszek Rudy Cyrus Luna Bella Zuzia Kajtek \
       Tofik Gizmo Salem Mila Borys Kicia Oskar Nela Feliks Szafran)
breeds=("dachowiec" "brytyjski krotkowlosy" "maine coon" "syjamski" "perski" \
        "ragdoll" "sfinks" "bengalski" "norweski lesny" "rosyjski niebieski" \
        "szkocki zwislouchy" "abisynski" "birmanski" "kartuski" "somalijski" \
        "devon rex" "syberyjski" "orientalny" "tonkijski" "munchkin")

ids=()
for i in "${!names[@]}"; do
  id=$(curl -s -X POST "$API/patients" -H 'Content-Type: application/json' \
       -d "{\"name\":\"${names[$i]}\",\"breed\":\"${breeds[$i]}\"}" | jq -r '.id')
  ids+=("$id")
done
printf 'utworzono %d pacjentow: %s\n' "${#ids[@]}" "${ids[*]}"

types=(NEW_EVENT TREATMENT_CONTINUATION VACCINATION)
complaints=("kontrola ogolna" "szczepienie przeciw wsciekliznie" "kulawizna tylnej lapy" \
            "brak apetytu" "odrobaczanie" "kontrola po zabiegu" "zapalenie ucha" \
            "czyszczenie zebow" "rana po bojce" "szczepienie kompleksowe" \
            "biegunka" "kontrola wagi" "swiad skory" "kaszel" "przeglad roczny" \
            "usuniecie kleszcza" "zapalenie spojowek" "kontrola po antybiotyku" \
            "problem z oddawaniem moczu" "badanie krwi")

n=0
for round in 0 1; do
  for i in "${!ids[@]}"; do
    pid="${ids[$i]}"
    t="${types[$(( (i + round) % 3 ))]}"
    c="${complaints[$(( (i * 2 + round) % 20 ))]}"
    d=$(date -d "-$(( (i * 11 + round * 37) % 300 + 1 )) days" +%F)
    code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$API/patients/$pid/records" \
      -H 'Content-Type: application/json' \
      -d "{\"date\":\"$d\",\"type\":\"$t\",\"notes\":\"$c\"}")
    [ "$code" = "201" ] || { echo "BLAD wizyty dla pacjenta $pid -> HTTP $code"; exit 1; }
    n=$((n+1))
  done
done
echo "utworzono $n wizyt"

Efekt: 20 pacjentow (id 704-723) + 40 wizyt, po 2 na kota.

KROK 2 - poprawka dat.
UWAGA: przy pierwszym uruchomieniu linijka z 'date' miala blad skladni
(zle nawiasy w $(( )) ), wiec wszystkie 40 wizyt dostalo te sama date.
Powyzszy skrypt jest juz poprawiony. Naprawa poszla bezposrednio w SQL,
bo apka nie ma endpointu do edycji wpisu medycznego:

docker exec catvet-postgres psql -U catvet -d catvet -c "UPDATE medical_record SET date = CURRENT_DATE - ((((id * 37) % 300) + 1)::int) WHERE date = DATE '2026-09-26';"

Rzutowanie ::int jest konieczne - bez niego Postgres rzuca
"operator does not exist: date - bigint".

KROK 3 - weryfikacja:

docker exec catvet-postgres psql -U catvet -d catvet -c "SELECT count(*) FROM patient;" -c "SELECT count(*) FROM medical_record;"

docker exec catvet-postgres psql -U catvet -d catvet -c "SELECT type, count(*) FROM medical_record GROUP BY type ORDER BY 2 DESC;"

docker exec catvet-postgres psql -U catvet -d catvet -c "SELECT p.id, p.name, p.breed, count(m.id) AS wizyt FROM patient p JOIN medical_record m ON m.patient_id = p.id GROUP BY p.id, p.name, p.breed ORDER BY p.id;"

curl -s localhost:8080/patients/704/records | jq

Stan koncowy: patient 30 -> 50, medical_record 1 -> 41.
Id skacza (704, a nie 31), bo Hibernate rezerwuje bloki po 50 wartosci
z sekwencji patient_seq przy kazdym starcie apki.

## Seed: po 1 wizycie dla KAZDEGO pacjenta (baza catvet)

Cel: zeby zaden pacjent nie zwracal pustej listy na /patients/{id}/records.
Znowu przez REST API, apka musi chodzic na 8080.

Skrypt (zapisany jako one_visit_each.sh, uruchomiony: bash one_visit_each.sh):

#!/usr/bin/env bash
set -euo pipefail
API=localhost:8080

types=(NEW_EVENT TREATMENT_CONTINUATION VACCINATION)
notes=("przeglad roczny" "kontrola stomatologiczna" "szczepienie przypominajace" \
       "odrobaczanie profilaktyczne" "kontrola wagi" "badanie moczu" \
       "obciecie pazurow" "kontrola po leczeniu" "szczepienie na koci katar" \
       "przeglad przed zabiegiem")

mapfile -t ids < <(curl -s "$API/patients" | jq -r '.[].id')
ok=0; fail=0
for i in "${!ids[@]}"; do
  pid="${ids[$i]}"
  t="${types[$(( i % 3 ))]}"
  n="${notes[$(( i % 10 ))]}"
  d=$(date -d "-$(( (i * 7) % 180 + 1 )) days" +%F)
  code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$API/patients/$pid/records" \
    -H 'Content-Type: application/json' \
    -d "{\"date\":\"$d\",\"type\":\"$t\",\"notes\":\"$n\"}")
  if [ "$code" = "201" ]; then ok=$((ok+1)); else fail=$((fail+1)); echo "BLAD pacjent $pid -> $code"; fi
done
echo "dodano: $ok, bledow: $fail, pacjentow: ${#ids[@]}"

Wynik: dodano 50, bledow 0.
medical_record 41 -> 91. Pacjentow bez wizyt: 29 -> 0.
Wizyt na pacjenta: min 1, max 3.

Weryfikacja - czy ktos zostal bez wizyty (wzorzec "znajdz sieroty"):

docker exec catvet-postgres psql -U catvet -d catvet -c "SELECT count(*) FROM patient p WHERE NOT EXISTS (SELECT 1 FROM medical_record m WHERE m.patient_id = p.id);"

docker exec catvet-postgres psql -U catvet -d catvet -c "SELECT count(*) AS pacjentow, min(w), max(w) FROM (SELECT p.id, count(m.id) AS w FROM patient p LEFT JOIN medical_record m ON m.patient_id = p.id GROUP BY p.id) t;"

UWAGA: skrypt nie jest idempotentny. Kazde uruchomienie dodaje kolejna wizyte
kazdemu pacjentowi (POST zawsze tworzy nowy zasob).

## Przydatne zapytania z tej sesji (baza catvet)

Kot + jego wizyty, filtr po fragmencie notatki:
SELECT p.name, p.breed, m.date, m.notes, m.type, p.id FROM patient p JOIN medical_record m ON m.patient_id = p.id WHERE m.notes ILIKE '%rana%';

- ILIKE = LIKE ignorujacy wielkosc liter, % = dowolny ciag znakow
- ON m.patient_id = p.id - samo "id" daje ERROR: column reference "id" is ambiguous,
  bo obie tabele maja kolumne id
- alias (p, m) zyje tylko w obrebie jednego zapytania, po sredniku znika
- po "FROM patient p" nie da sie juz pisac "patient.name", tylko "p.name"

Pary kotow tego samego wlasciciela - self join (baza catvet_sql):
SELECT o.full_name, c1.name, c2.name FROM cats c1 JOIN cats c2 ON c2.owner_id = c1.owner_id AND c1.id < c2.id JOIN owners o ON o.id = c1.owner_id ORDER BY o.full_name;

- ta sama tabela dwa razy, pod dwoma aliasami
- warunek c1.id < c2.id: bez niego 66 wierszy (kot sam ze soba + pary lustrzane),
  z c1.id <> c2.id 36, z c1.id < c2.id 18 (kazda para raz)

## Podsumowanie tygodnia 2 (SQL) - 2026-09-29

### INNER JOIN vs LEFT JOIN

Jedna zmienna, ktora je rozroznia: czy wiersz musi miec pare, zeby trafic do wyniku.
- INNER JOIN: wiersz bez pary jest wyrzucany.
- LEFT JOIN: kazdy wiersz z LEWEJ tabeli (tej po FROM) zostaje, a kolumny z prawej
  dostaja NULL.
- LEFT JOIN jest asymetryczny: wiersz z PRAWEJ tabeli bez pary znika.

SELECT o.full_name, c.name FROM owners o LEFT JOIN cats c ON c.owner_id = o.id WHERE c.id IS NULL;

- wzorzec "znajdz sieroty" (wlasciciele bez kotow), drugi sposob obok NOT EXISTS

### NULL i logika trojwartosciowa

- NULL = brak wartosci. To nie jest pusty napis '' ani 0.
- porownanie zwraca true, false albo unknown (NULL)
- kazde porownanie z NULL daje unknown, nawet NULL = NULL
- WHERE przepuszcza TYLKO true. Wiersze z false i unknown odpadaja.
- o NULL pytamy tylko przez IS NULL / IS NOT NULL, nigdy przez = NULL

SELECT NULL <> 'unknown', NULL = NULL;   -- oba wyniki: NULL (w psql puste pole)

WHERE phone <> 'unknown'                  -- gubi wlascicieli z phone = NULL
WHERE phone <> 'unknown' OR phone IS NULL -- zachowuje ich

- przy kazdym <> na kolumnie, ktora moze byc NULL: czy NULL-e maja zostac w wyniku?
  Jesli tak, dopisz OR kolumna IS NULL.

PROTIP: \pset null '∅' w psql, wtedy NULL widac jako ∅, a nie puste pole.

### Self join na pary: <> vs <

<> znaczy "rozne od" (jak != w Javie).

Przyklad: Mruczek (id=1), Filemon (id=2), ta sama wlascicielka.
- bez warunku:      (M,M) (M,F) (F,M) (F,F)  -> 4
- c1.id <> c2.id:   (M,F) (F,M)              -> 2  (bez kota w parze z samym soba)
- c1.id < c2.id:    (M,F)                    -> 1  (bez lustrzanych duplikatow)

Stad 66 -> 36 -> 18 w bazie catvet_sql:
- 66 = wszystkie kombinacje, z parami "kot + on sam"
- 36 = 66 - 30 (30 kotow, kazdy raz sam ze soba)
- 18 = 36 / 2 (kazda para byla dwa razy, raz w kazda strone)
