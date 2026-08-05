# CatVet — 5-Day Outcomes Roadmap

A junior developer builds a vet-clinic records service incrementally. Each day is defined by **what works at the end of it**, expressed as a user story with acceptance criteria the developer can verify themselves.

**How to use this:** The story tells you *what* to build and *why*. The acceptance criteria are your "done" bar — if you can't tick every box, you're not finished. The *look into* list and official docs are research starting points, not instructions. Coding is by hand, configuration is yours to figure out, and tutorials/guides you find yourself. The docs are the source of truth to return to when guides disagree or go stale.

**Platform assumed:** Ubuntu 26.04, Docker, IntelliJ IDEA 2026, Git, JDK 21+.

**Daily rhythm (~3 hrs):** roughly 30 min orienting on the concepts, ~2 hrs building, ~30 min verifying against the acceptance criteria.

---

## Day 1 — Working skeleton

> **As a** developer joining the CatVet project,
> **I want** a running, version-controlled Spring Boot project skeleton,
> **so that** I have a clean, buildable foundation to grow the service on.

The service does almost nothing today — it just needs to *exist*, *build*, *run*, and *respond*. The point is owning the toolchain end to end before any real logic lands.

**Acceptance criteria**
- [x ] A Maven-based Spring Boot project (Java 21) is generated and opens in IntelliJ without errors.
- [x ] `mvn clean package` completes successfully and produces a runnable JAR.
- [x ] The application starts locally and stays up.
- [x ] A `GET /ping` (or similar) endpoint returns a hardcoded 200 response (e.g. `"pong"`).
- [x ] The project is a Git repository with an initial commit and a `.gitignore` that excludes build output and IDE files.
- [x ] You can articulate, in a sentence each, what `pom.xml` and `@SpringBootApplication` do.

**Look into:** what `start.spring.io` generates and why; the Maven build lifecycle (`validate`/`compile`/`test`/`package`); JAR vs running app; dependencies in `pom.xml`; `@SpringBootApplication`; Java 21 features (records, `var`, `Optional`, streams, text blocks); how the same project looks in Gradle.
- Maven build lifecycle: https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html
**Official docs**
- Java 21 — https://docs.oracle.com/en/java/javase/21/
- Spring Boot — https://docs.spring.io/spring-boot/reference/
- Spring Initializr — https://start.spring.io
- Maven — https://maven.apache.org/guides/
- Gradle (comparison) — https://docs.gradle.org/current/userguide/userguide.html
- Git — https://git-scm.com/doc

---

## Day 2 — Cat REST API in memory

``> **As a** vet clinic receptionist,
> **I want** to register cats and look them up, update them, and remove them,
> **so that** the clinic has an up-to-date list of the cats it treats.

Build the full set of cat operations over HTTP, holding data in memory (no database yet — that's deliberate, to isolate the web layer). A cat has at least: an id, a name, a species/breed, a date of birth, and an owner name.

**Acceptance criteria**
- [x ] `POST /cats` creates a cat and returns `201 Created` with the created resource (including a generated id).
- [x ] `GET /cats` returns all cats; `GET /cats/{id}` returns one.
- [x ] `GET /cats/{id}` for an unknown id returns `404 Not Found` (not a 500, not an empty 200).
- [x ] `PUT /cats/{id}` updates an existing cat; `DELETE /cats/{id}` removes it and returns `204 No Content`.
- [x ] Posting an invalid cat (e.g. blank name, missing required field) returns `400 Bad Request`, not a saved record.
- [x ] The code is layered: a controller handles HTTP, a service holds logic, a repository holds the in-memory store — and you can explain why.
- [x ] Every endpoint is demonstrably working via `curl` (keep the commands; you'll reuse them).

**Look into:** dependency injection and the problem it solves; Spring beans and the application context; why split controller/service/repository; `@RestController` and the mapping annotations; HTTP status codes and when to return each; DTOs vs internal objects; Bean Validation (`@Valid`, `@NotNull`, `@Size`); JSON ↔ Java via Jackson.

**Official docs**
- Spring core (DI, beans) — https://docs.spring.io/spring-framework/reference/core/beans.html
- Spring web / REST — https://docs.spring.io/spring-framework/reference/web/webmvc.html
- Bean Validation — https://docs.spring.io/spring-framework/reference/core/validation/beanvalidation.html

---``

## Day 3 — Real persistence (H2 → Postnd gres)

> **As a** vet,
> **I want** each cat's checkups and vaccinations recorded and kept permanently,
> **so that** I can review a cat's medical history on any future visit.

Introduce a real persistence layer. A cat now *has many* medical records (a checkup or a vaccination, each with a date and notes). The same code must run against H2 for local development and against a Dockerized PostgreSQL for "real" — switched by configuration alone.

**Acceptance criteria**
- [x ] Cats and their medical records are stored via Spring Data JPA repositories (no hand-written SQL for basic CRUD).
- [x ] The cat → records relationship is modeled (one cat, many records).
- [x ] `POST /cats/{id}/records` adds a medical record to a cat; `GET /cats/{id}/records` lists that cat's history.
- [x ] With the dev profile active, the app uses H2 and starts with no external dependencies.
- [x ] With the Postgres profile active, the app connects to a PostgreSQL instance running in a Docker container — **no code changes**, only configuration.
- [x ] Data written to Postgres survives an application restart (prove it: write, restart, read it back).
- [x ] You can explain what `ddl-auto` is set to and why that setting is risky in production.

**Look into:** what an ORM is, and what JPA vs Hibernate each refer to; `@Entity`, `@Id`, `@GeneratedValue`; how Spring Data derives queries from method names; relationships (`@OneToMany`/`@ManyToOne`, owning side, the N+1 problem); Spring profiles and `application.yml`/`application-*.yml`; why H2 for dev and Postgres for real; running Postgres in Docker (ports, env vars, volumes); `ddl-auto`.

**Official docs**
- Spring Data JPA — https://docs.spring.io/spring-data/jpa/reference/
- Hibernate ORM — https://hibernate.org/orm/documentatio n/
- Spring Boot SQL data — https://docs.spring.io/spring-boot/reference/data/sql.html
- H2 — https://www.h2database.com/html/main.html
- PostgreSQL — https://www.postgresql.org/docs/current/
- Docker — https://docs.docker.com/get-started/
- Postgres Docker image — https://hub.docker.com/_/postgres

---

## Day 4 — Tested

> **As a** developer maintaining CatVet,
> **I want** automated tests around the cat and records logic,
> **so that** I can change the code later and trust that I haven't broken existing behavior.

No new features today — instead, lock in what exists with tests at two levels. The goal is confidence, not coverage numbers.

**Acceptance criteria**
- [x ] At least one **unit test** on a service class, with its dependencies mocked (the test does not touch a real database).
- [x ] At least one **integration test** that exercises a real endpoint against H2 (e.g. POST a cat, then GET it back).
- [x ] A test proves a negative path (e.g. fetching an unknown cat yields 404).
- [x ] `mvn test` runs the whole suite and all tests pass.
- [x ] You can explain the difference between your unit test and your integration test, and what mocking bought you in the unit test.

**Look into:** unit vs integration tests and why have both; what mocking is for (Mockito `when`/`thenReturn`, `verify`); JUnit 5 basics (`@Test`, assertions, `@BeforeEach`); what `@SpringBootTest` spins up vs `@WebMvcTest`; "test behavior, not implementation"; Arrange-Act-Assert; testing the web layer with MockMvc.

**Official docs**
- JUnit 5 — https://docs.junit.org/current/user-guide/
- Mockito — https://site.mockito.org
- Spring Boot testing — https://docs.spring.io/spring-boot/reference/testing/

---

## Day 5 — Real-world polish (then Kafka if time allows)

> **As a** developer preparing CatVet for others to run and use,
> **I want** consistent error handling, useful logs, a health check, and clear run instructions,
> **so that** a teammate can clone, run, and trust the service without asking me how.

This is the unglamorous layer tutorials skip but real work demands. If you arrive here ahead of schedule, take the optional Kafka stretch; if not, Kafka moves to Week 2 with no penalty.

**Acceptance criteria (core)**
- [ ] Errors return a consistent, structured response (e.g. a 404 and a 400 both return a clean JSON error body, not a stack trace).
- [ ] The application logs meaningful events at appropriate levels (not via `System.out.println`).
- [ ] A health endpoint reports the service is up.
- [ ] A `README` exists that lets someone clone the repo and run the service (both profiles) without prior knowledge.

**Acceptance criteria (optional Kafka stretch)**
- [ ] Recording a vaccination publishes an event to a Kafka topic (Kafka running in Docker).
- [ ] A consumer receives that event and reacts visibly (e.g. logs "schedule reminder for cat X").
- [ ] You can explain, in plain words, why you'd decouple this with a queue instead of doing it inline.

**Look into:** `@ControllerAdvice`/`@ExceptionHandler` and why centralize errors; good error responses (Problem Detail / RFC 7807); SLF4J vs Logback and log levels; Spring Boot Actuator health. *Kafka:* what a message queue is and why decouple; producer → topic → consumer; partitions and consumer groups; running Kafka in Docker via Compose; Spring Kafka (`KafkaTemplate`, `@KafkaListener`).

**Official docs**
- Spring Boot Actuator — https://docs.spring.io/spring-boot/reference/actuator/
- Spring error handling — https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-controller/ann-exceptionhandler.html
- SLF4J — https://www.slf4j.org/manual.html
- Apache Kafka — https://kafka.apache.org/documentation/
- Spring for Apache Kafka — https://docs.spring.io/spring-kafka/reference/

---

## Week 2 backlog (overflow / next steps)

- Kafka & queues, if deferred from Day 5.
- Security / authentication — https://docs.spring.io/spring-security/reference/
- Docker Compose for the whole stack (app + Postgres + Kafka) — https://docs.docker.com/compose/
- Continuous integration (run the test suite automatically on push).

---

*Note: a few deep-linked doc URLs (Spring Framework chapter pages especially) get reorganized between versions. If one 404s, start from that project's documentation home and navigate down.*
