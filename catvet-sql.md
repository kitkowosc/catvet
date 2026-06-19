# CatVet SQL — 5-Day Outcomes Roadmap

A junior developer learns SQL and databases as their own subject — not through an ORM, not through Spring Data, just the database and the language. The [Spring CatVet roadmap](catvet-week1.md) reaches persistence on Day 3 via Spring Data JPA, which generates SQL for you; this roadmap deliberately works *underneath* that, so when JPA shows up you understand what it's doing and when to bypass it. Each day is defined by **what works at the end of it**.

**How to use this:** Same as the [Spring CatVet roadmap](catvet-week1.md) — the story tells you *what* to build and *why*. The acceptance criteria are your "done" bar: if you can't tick every box, you're not finished. The *look into* list and official docs are research starting points, not instructions. Schemas and queries are yours to write by hand; tutorials you find yourself. The docs are the source of truth when guides disagree or go stale.

**Platform assumed:** Ubuntu 26.04, Docker Engine, `psql` installed locally (via the `postgresql-client` package), IntelliJ IDEA 2026 with the bundled Database tools (same engine as JetBrains DataGrip), Git. Postgres itself runs in a Docker container throughout — same muscle as the [Ops roadmap](catvet-ops-week1.md). `psql` and IntelliJ are the two clients you'll use to talk to it, deliberately side by side: the CLI for speed and reproducibility, the GUI for browsing and exploration.

**Daily rhythm (~3 hrs):** roughly 30 min orienting on concepts, ~2 hrs writing SQL, ~30 min verifying against the acceptance criteria.

**Starting point:** zero or near-zero SQL knowledge. Comfort with the shell and a text editor is enough.

**Scope deliberately deferred:** JPA/Hibernate (Spring roadmap), migrations with Flyway/Liquibase, roles and security, JSONB and arrays, full-text search, replication, stored procedures, advanced index types. See the Week 2 backlog at the end.

---

## Day 1 — Postgres in your terminal

> **As a** developer who has only seen databases through ORMs,
> **I want** to start Postgres and run my first SQL statements directly,
> **so that** I understand the database as a tool I can use without anything translating for me.

Today is about meeting Postgres on its own terms — get it running, connect to it from psql and from IntelliJ, and create your first table by hand. No CatVet schema yet, no relationships yet. The goal is the loop: write SQL, run it, see the result, iterate.

**Acceptance criteria**
- [ ] Postgres (current stable, e.g. `postgres:18`) runs in a Docker container with a **named volume** so data survives `docker stop`/`start`.
- [ ] `psql` is installed on the host (`sudo apt install postgresql-client`) and connects to the containerized Postgres directly — you also know how to fall back to `docker exec -it <container> psql ...`.
- [ ] IntelliJ IDEA's **Database** tool window is connected to the same database; you can run a query from IntelliJ and see results.
- [ ] You ran the same `SELECT` from both `psql` and IntelliJ, and can articulate when you'd reach for each client.
- [ ] You created a new database (not the default `postgres`), connected to it, and built a `cats` table with at least: `id` (auto-generated primary key), `name`, `birth_date`, `breed`.
- [ ] You inserted at least 5 cats and `SELECT *` returns them.
- [ ] You're comfortable with `\l`, `\c`, `\dt`, `\d <table>`, `\q`, `\?`, and `\!` (shell escape).
- [ ] You can articulate the difference between a Postgres **cluster**, **database**, **schema**, and **table** — and where your `cats` table actually lives.

**Look into:** running Postgres in Docker (env vars `POSTGRES_USER`/`POSTGRES_PASSWORD`/`POSTGRES_DB`, port mapping, the data volume `/var/lib/postgresql/data`); installing the `postgresql-client` package on Ubuntu (gives you `psql` without a server); psql as a client vs Postgres as a server; psql meta-commands (`\` commands) vs SQL statements; the IntelliJ Database tool — adding a data source, console vs table editor, parameter prompts; when CLI beats GUI (scripting, repeatability, ssh) and when GUI beats CLI (browsing, joins-by-click, schema diagrams); basic data types (`INTEGER`, `TEXT` vs `VARCHAR(n)`, `DATE`, `TIMESTAMP`, `BOOLEAN`, `NUMERIC`); auto-generated keys (`SERIAL` vs `GENERATED ... AS IDENTITY`); the difference between `\d` and a SQL query against `information_schema`.

**Official docs**
- Postgres image — https://hub.docker.com/_/postgres
- psql reference — https://www.postgresql.org/docs/current/app-psql.html
- Data types — https://www.postgresql.org/docs/current/datatype.html
- `CREATE TABLE` — https://www.postgresql.org/docs/current/sql-createtable.html
- IntelliJ Database tool window — https://www.jetbrains.com/help/idea/database-tool-window.html

---

## Day 2 — The CatVet schema, designed by hand

> **As a** data steward for CatVet,
> **I want** a normalized schema with owners, cats, visits, and medications, and proper relationships between them,
> **so that** the data has integrity and the database refuses to store nonsense.

Today you design the full schema yourself, write it as a runnable SQL script, and seed it. The point is learning what constraints actually do — try to violate them and watch the database refuse.

**Acceptance criteria**
- [ ] A `schema.sql` script creates the full schema from a clean database: `owners`, `cats`, `visits`, `medications`, and a join table connecting visits to medications (with its own columns like `dosage`, `duration_days`).
- [ ] Foreign keys enforce the relationships. Attempting to insert a cat for a nonexistent owner fails; attempting to delete an owner who still has cats fails — unless you've chosen `ON DELETE CASCADE` and can justify it.
- [ ] At minimum these constraints exist somewhere in the schema: `PRIMARY KEY`, `NOT NULL` on required fields, `UNIQUE` on something that should be (e.g. owner email), and at least one `CHECK` constraint that catches real bad data (e.g. `birth_date <= CURRENT_DATE`).
- [ ] A `seed.sql` script inserts a meaningful sample: ~20 owners, ~30 cats, ~50 visits, ~10 medications, plus join rows. Real-ish names and dates, not `aaa`/`bbb`.
- [ ] Both scripts are **idempotent**: running them on a clean database works; running them twice produces a predictable outcome (your choice — usually `DROP TABLE ... CASCADE` at the top of `schema.sql`).
- [ ] Both scripts are committed to the git repo.
- [ ] You can explain, in plain words: primary key vs unique constraint; `ON DELETE CASCADE` vs `ON DELETE RESTRICT` vs `ON DELETE SET NULL`; why the visit-medication join table has its own primary key (composite or surrogate).

**Look into:** schema design and normalization (just to the level where you stop duplicating data — 3NF is plenty); primary keys (surrogate vs natural); foreign keys and referential actions; `NOT NULL`, `UNIQUE`, `CHECK` constraints; many-to-many via a join table; surrogate vs composite keys on join tables; reading and writing SQL scripts; loading a script with `psql -f` or IntelliJ's "Run script" action.

**Official docs**
- Data definition (overview) — https://www.postgresql.org/docs/current/ddl.html
- Constraints — https://www.postgresql.org/docs/current/ddl-constraints.html
- Foreign keys tutorial — https://www.postgresql.org/docs/current/tutorial-fk.html
- `INSERT` — https://www.postgresql.org/docs/current/sql-insert.html

---

## Day 3 — Reading data fluently

> **As a** vet flipping through clinic records,
> **I want** to answer everyday questions with a single SQL query,
> **so that** I can find what I need without scrolling through tables by hand.

Today is `SELECT` muscle. One table at a time (mostly) — you'll combine tables tomorrow. The aim is fluency with filtering, sorting, and the standard functions you reach for every day.

**Acceptance criteria**
- [ ] You can write queries answering at least: "cats born after 2020", "cats whose name contains 'mit' case-insensitively", "owners with no phone number on file", "the 10 most recently registered cats".
- [ ] You've used each of: `=`, `<>`, `<`, `>`, `BETWEEN`, `IN (...)`, `LIKE`, `ILIKE`, `IS NULL`.
- [ ] You used `DISTINCT` to deduplicate, multi-column `ORDER BY`, and `LIMIT`/`OFFSET` to paginate.
- [ ] You computed a cat's age in years from `birth_date` using date arithmetic, and chose between integer years or full interval display deliberately.
- [ ] You used a `CASE` expression in the `SELECT` list to bucket cats (e.g. `'kitten' | 'adult' | 'senior'`) based on age.
- [ ] You used `COALESCE` to substitute a default for a `NULL` value in the output.
- [ ] You can explain three-valued logic in your own words: why `WHERE phone <> 'unknown'` excludes rows where `phone IS NULL`, and how to write the predicate so it includes them.
- [ ] You saved at least 5 useful queries to a `.sql` file in the repo (your reference library).

**Look into:** the parts of a `SELECT` statement and the order they're written vs evaluated; the difference between `LIKE` and `ILIKE`; pattern wildcards (`%` and `_`); `IS NULL` vs `= NULL` (and why the latter never matches); date/time arithmetic and functions (`AGE`, `EXTRACT`, `CURRENT_DATE`, `NOW()`); string functions (`LOWER`, `UPPER`, `CONCAT`, `LENGTH`, `SUBSTRING`); numeric functions; `CASE` expressions; `COALESCE` and `NULLIF`.

**Official docs**
- `SELECT` — https://www.postgresql.org/docs/current/sql-select.html
- Functions and operators (overview) — https://www.postgresql.org/docs/current/functions.html
- Pattern matching (`LIKE`, `ILIKE`, regex) — https://www.postgresql.org/docs/current/functions-matching.html
- Date/time functions — https://www.postgresql.org/docs/current/functions-datetime.html
- Conditional expressions (`CASE`, `COALESCE`) — https://www.postgresql.org/docs/current/functions-conditional.html

---

## Day 4 — Joining and aggregating

> **As a** vet preparing the clinic's monthly report,
> **I want** to combine data across owners, cats, visits, and medications, and summarize it,
> **so that** I can produce a useful report without exporting anything to a spreadsheet.

Today the schema pays off. You'll join tables every direction, group, count, and write a few queries that genuinely answer business questions.

**Acceptance criteria**
- [ ] You wrote an `INNER JOIN` returning each cat's name alongside its owner's name.
- [ ] You wrote a `LEFT JOIN` listing every owner including those who have no cats yet (and the missing side shows as `NULL`).
- [ ] You used `GROUP BY` + `COUNT(*)` to produce "number of cats per owner", and `HAVING` to filter to owners with more than 2 cats.
- [ ] You produced "number of visits per month over the last 12 months" using date truncation and grouping.
- [ ] You used at least two of `SUM`, `AVG`, `MIN`, `MAX` in meaningful queries.
- [ ] You wrote one query as a subquery in `WHERE` (e.g. "cats who have had at least one vaccination") and rewrote it using `EXISTS`.
- [ ] You wrote at least one query using a `WITH` clause (CTE) and can explain why it was clearer than the nested-subquery equivalent.
- [ ] You can articulate, in your own words: the difference between `INNER` and `LEFT JOIN`; what a `NULL` on the right side of a `LEFT JOIN` means; when `GROUP BY` is required (and the rule about non-aggregated columns in `SELECT`).

**Look into:** join types (inner, left, right, full outer, cross, self-join); join syntax (`ON ...` vs `USING (...)`); aliasing tables (`FROM cats c JOIN owners o ON ...`); aggregate functions and `GROUP BY`; the difference between `WHERE` and `HAVING`; subqueries (scalar, in `WHERE`, in `FROM` — "derived tables"); `EXISTS` / `NOT EXISTS` vs `IN` / `NOT IN` (and the NULL gotcha); Common Table Expressions (`WITH`).

**Official docs**
- Joins and table expressions — https://www.postgresql.org/docs/current/queries-table-expressions.html
- Aggregate functions — https://www.postgresql.org/docs/current/functions-aggregate.html
- Subquery expressions — https://www.postgresql.org/docs/current/functions-subquery.html
- `WITH` queries (CTEs) — https://www.postgresql.org/docs/current/queries-with.html

---

## Day 5 — Changing data safely, and knowing it's fast

> **As a** developer about to write application code that modifies the database,
> **I want** to change data without losing it and confirm my queries will perform,
> **so that** I don't ship a bug that destroys a row and don't ship a query that times out.

Today closes the loop. You'll mutate data (carefully), wrap changes in transactions, add your first index, and read your first `EXPLAIN` plan. This is a dense day — the heaviest of the roadmap — and it's intentional.

**Acceptance criteria**
- [ ] You've used `INSERT ... RETURNING` to fetch a generated `id` in the same round-trip.
- [ ] You ran an `UPDATE` with no `WHERE` clause inside a transaction, observed how many rows changed, and `ROLLBACK`'d it. You now reflexively check the `WHERE` before any `COMMIT`.
- [ ] You wrapped a multi-statement change (e.g. transferring a cat to a new owner and logging it as a visit) in `BEGIN ... COMMIT` and confirmed all-or-nothing behavior by deliberately failing the second statement.
- [ ] You can describe Postgres's default transaction isolation level and at least one anomaly that `SERIALIZABLE` prevents (in plain language).
- [ ] You created an index on a column you actually query by (e.g. `visits.cat_id`) and used `EXPLAIN` to confirm the planner uses it.
- [ ] You ran `EXPLAIN ANALYZE` on at least one query and identified the most expensive node in the plan.
- [ ] You can articulate that indexes are not free (write cost, storage cost), and name at least two columns in the CatVet schema where you'd **not** add an index.
- [ ] You can articulate the practical difference between `DELETE FROM t` and `TRUNCATE t`.

**Look into:** `INSERT`, `UPDATE`, `DELETE` syntax and `RETURNING`; transactions (`BEGIN`, `COMMIT`, `ROLLBACK`, savepoints); ACID properties at a working level; isolation levels (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`) and which anomalies each prevents; B-tree indexes (the default kind) and what they're good at; when an index does **not** help (small tables, columns with low selectivity, `LIKE '%foo%'` patterns); `EXPLAIN` vs `EXPLAIN ANALYZE`; reading a plan (Seq Scan vs Index Scan vs Index Only Scan, cost vs actual time, rows estimated vs actual).

**Official docs**
- Data manipulation (`INSERT`/`UPDATE`/`DELETE`) — https://www.postgresql.org/docs/current/dml.html
- Transactions tutorial — https://www.postgresql.org/docs/current/tutorial-transactions.html
- Transaction isolation — https://www.postgresql.org/docs/current/transaction-iso.html
- Indexes (overview) — https://www.postgresql.org/docs/current/indexes.html
- Using `EXPLAIN` — https://www.postgresql.org/docs/current/using-explain.html

---

## Week 2 backlog (overflow / next steps)

- **Migrations with Flyway or Liquibase** — version-controlled schema change, the natural bridge to the [Spring CatVet roadmap](catvet-week1.md) Day 3 work. https://flywaydb.org/documentation/ , https://docs.liquibase.com/
- **Window functions in depth** — `ROW_NUMBER`, `RANK`, `LAG`/`LEAD`, partitioned aggregates. https://www.postgresql.org/docs/current/tutorial-window.html
- **Roles, privileges, security** — `CREATE ROLE`, `GRANT`, row-level security. https://www.postgresql.org/docs/current/user-manag.html
- **JSONB and arrays** — Postgres's semi-structured features when a column doesn't deserve its own table. https://www.postgresql.org/docs/current/datatype-json.html
- **Full-text search** — `tsvector`, `tsquery`, GIN indexes for search. https://www.postgresql.org/docs/current/textsearch.html
- **Advanced index types** — partial, expression, covering, GIN, GiST, BRIN; composite-column ordering. https://www.postgresql.org/docs/current/indexes-types.html
- **Backups** — logical (`pg_dump` / `pg_restore`) vs physical, and what each protects you against. https://www.postgresql.org/docs/current/backup.html
- **PL/pgSQL, triggers, stored procedures** — when (and when not) to put logic in the database. https://www.postgresql.org/docs/current/plpgsql.html
- **Connection pooling** — PgBouncer, why a Java app needs one in production. https://www.pgbouncer.org/
- **Bridging to JPA** — once SQL is solid, contrast it with Spring Data JPA's generated queries (`spring.jpa.show-sql=true`). The link back to [catvet-week1.md](catvet-week1.md) Day 3.

---

*Note: as with the other roadmaps, some deep-linked doc URLs (Postgres chapter pages especially) get reorganized between major versions. If one 404s, start from https://www.postgresql.org/docs/current/ and navigate down.*
