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
# catvet
