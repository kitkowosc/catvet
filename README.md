# CatVet — A Junior Developer Roadmap

A self-paced training program that takes a junior developer from "I can write Java" to "I can ship a Spring Boot service that runs in containers, connects to a real database, and deploys from a CI pipeline." Three roadmaps, one fictional vet clinic.

## The roadmaps

Each roadmap is 5 days × ~3 hours. Each day is defined by **what works at the end of it** — a user story plus acceptance criteria the developer verifies themselves. The pedagogy is deliberate: figure things out from the official docs, not from step-by-step tutorials.

- **[catvet-week1.md](catvet-week1.md)** — Spring Boot. Builds the CatVet REST service from a skeleton to a tested, persistent API. Covers Maven, dependency injection, REST + validation, JPA with H2 and Postgres profiles, JUnit + Mockito, error handling, logging, Actuator. Optional Kafka stretch on Day 5.
- **[catvet-ops-week1.md](catvet-ops-week1.md)** — Containers and CI. Takes the same service from laptop to "every push publishes a versioned image." Covers Docker, multi-stage builds, Compose, registries (Docker Hub), and a first GitHub Actions pipeline. Kubernetes and Helm are deferred to a Week 2 roadmap.
- **[catvet-sql.md](catvet-sql.md)** — SQL and Postgres, on their own terms. Postgres in Docker + `psql` + IntelliJ Database tools. Designs the CatVet schema by hand, builds query fluency, then mutations, transactions, indexes, and `EXPLAIN`. Sits *underneath* the Spring roadmap's Day 3 JPA — same concepts from the other direction.

## Suggested order

1. **`catvet-week1.md`** — first, always. The other two extend it.
2. **`catvet-sql.md`** or **`catvet-ops-week1.md`** — interchangeable. Take SQL first if the trainee wants to deeply understand the database before automating delivery; take Ops first if they want to feel a complete build-and-ship loop quickly.

Each roadmap has a *Week 2 backlog* at its end — the next horizon once the core week is done.

## Platform assumed

- Ubuntu 26.04
- Java 25 LTS, Maven
- Docker Engine
- IntelliJ IDEA 2026 (Database tools come bundled)
- `psql` via the `postgresql-client` package (for the SQL roadmap)
- Git
- Free accounts on Docker Hub and GitHub (for the Ops roadmap)

## How to use the roadmaps

Open the roadmap for the week you're on. Read the day. Build until you can tick every acceptance-criteria box. The *look into* lists and *official docs* are research starting points; tutorials and guides you find yourself. The docs are the source of truth when guides disagree or go stale.

## What this isn't

- Not a Spring tutorial — it assumes you can already write basic Java.
- Not a reference manual — it's outcome-driven; the "done" bar is whether the acceptance criteria pass, not whether you've memorized syntax.
- Not a video course — text only, by design, so the trainee builds the habit of reading documentation.

---

# Running the CatVet service

The service itself lives in `src/`. It is a Spring Boot 4 REST API for a vet clinic: patients (cats) and their medical records.

## Prerequisites

- JDK 21 or newer (`java -version`)
- Docker — only for the `prod` profile
- No Maven install needed; the repo ships the Maven wrapper (`./mvnw`)

## Two profiles

| Profile | Database | Needs Docker? | Data survives restart? |
|---------|----------|---------------|------------------------|
| `dev`   | H2, in memory | no | no |
| `prod`  | PostgreSQL in a container | yes | yes |

`src/main/resources/application.properties` sets `spring.profiles.active=prod` as the default, so **pass the profile explicitly** if you want `dev`.

### Run with the dev profile (H2, nothing else required)

```bash
git clone <this-repo> && cd Jun17Catvet
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

The H2 console is available at <http://localhost:8080/h2-console> (JDBC URL `jdbc:h2:mem:catvet`, user `sa`, no password).

### Run with the prod profile (PostgreSQL in Docker)

Start the database once — the named volume keeps the data between restarts:

```bash
docker run -d --name catvet-postgres \
  -e POSTGRES_USER=catvet -e POSTGRES_PASSWORD=catvet -e POSTGRES_DB=catvet \
  -p 5432:5432 -v catvet-pgdata:/var/lib/postgresql/data postgres:16
```

Then start the app (`prod` is the default, so no flag is needed):

```bash
./mvnw spring-boot:run
```

Later runs only need `docker start catvet-postgres`.

### Run the packaged JAR

```bash
./mvnw clean package
java -jar target/catvet-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

### Run the tests

```bash
./mvnw test
```

Tests always run against their own in-memory H2 database (`src/test/resources/application.properties`), never against Postgres.

## Health check

```bash
curl -s localhost:8080/actuator/health
# {"status":"UP"}
```

## Endpoints

| Method   | Path                     | Does                                       |
|----------|--------------------------|--------------------------------------------|
| `GET`    | `/patients`              | list all patients                          |
| `POST`   | `/patients`              | register a patient → `201 Created`         |
| `GET`    | `/patients/{id}`         | one patient → `404` if unknown             |
| `PUT`    | `/patients/{id}`         | update a patient                           |
| `DELETE` | `/patients/{id}`         | remove a patient → `204 No Content`        |
| `GET`    | `/patients/{id}/records` | that patient's medical history             |
| `POST`   | `/patients/{id}/records` | add a checkup/vaccination → `201 Created`  |
| `GET`    | `/actuator/health`       | health check                               |

A medical record's `type` is one of `NEW_EVENT`, `TREATMENT_CONTINUATION`, `VACCINATION`.

```bash
# register a patient
curl -i -X POST localhost:8080/patients \
  -H 'Content-Type: application/json' \
  -d '{"name":"Ryszard","breed":"cat"}'

# add a vaccination for patient 1
curl -i -X POST localhost:8080/patients/1/records \
  -H 'Content-Type: application/json' \
  -d '{"date":"2026-07-09","type":"VACCINATION","notes":"annual shot"}'
```

## Errors

Failures come back as RFC 7807 problem details (`application/problem+json`), never as a stack trace:

```bash
curl -s localhost:8080/patients/999
# {"detail":"Could not find patient 999","instance":"/patients/999",
#  "status":404,"title":"Patient not found"}

curl -s -X POST localhost:8080/patients -H 'Content-Type: application/json' -d '{"name":"","breed":""}'
# {"detail":"One or more fields are invalid","instance":"/patients","status":400,
#  "title":"Validation failed","errors":{"name":"must not be blank","breed":"must not be blank"}}
```
