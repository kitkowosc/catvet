# CatVet Ops — 5-Day Outcomes Roadmap (Week 1)

A junior developer takes the CatVet service from "runs on my laptop" to "every push builds a versioned image and publishes it." Each day is defined by **what works at the end of it**.

**How to use this:** Same as the [Spring CatVet roadmap](catvet-week1.md) — the story tells you *what* to build and *why*. The acceptance criteria are your "done" bar: if you can't tick every box, you're not finished. The *look into* list and official docs are research starting points, not instructions. Dockerfiles, Compose files, and workflows are yours to write by hand; tutorials you find yourself. The docs are the source of truth when guides disagree or go stale.

**Platform assumed:** Ubuntu 26.04, Docker Engine, Git, Java 25 LTS, Maven, IntelliJ IDEA 2026, free Docker Hub and GitHub accounts.

**Daily rhythm (~3 hrs):** roughly 30 min orienting on concepts, ~2 hrs building, ~30 min verifying.

**Starting point:** the CatVet service from the [Spring Boot roadmap](catvet-week1.md) — needed from Day 2 onwards.

**Scope deliberately deferred:** Kubernetes and Helm are Week 2; ingress, secrets, observability, GitOps, and a real cloud cluster are Week 3+. Week 1 is only Docker, Compose, registries, and a first CI pipeline.

---

## Day 1 — Docker on your machine

> **As a** developer who keeps installing services directly on my laptop,
> **I want** to run Postgres, nginx, and similar tools inside Docker containers instead,
> **so that** my machine stays clean and I can throw away an environment by deleting a container.

Today is just about *using* Docker — running other people's images. No Dockerfile yet, no CatVet yet. You install Docker, learn the everyday CLI, and play with pre-built images until the model clicks.

**Acceptance criteria**
- [ ] Docker Engine is installed on Ubuntu and your user can run `docker` without `sudo`.
- [ ] `docker run hello-world` works.
- [ ] You can run a Postgres container with a chosen password and port, and connect to it from the host with `psql` if you have it, or a GUI client like IntelliJ's Database tools.
- [ ] You can run an nginx container that serves a file from a directory on your host (bind mount) and reach it in a browser.
- [ ] You're comfortable with `docker ps`, `ps -a`, `logs`, `exec -it`, `stop`, `rm`, `images`, `pull`, `rmi`.
- [ ] You can articulate, in a sentence each: image vs container; `-p` vs `EXPOSE`; what `-d`, `--rm`, and `--name` do.
- [ ] Given a `docker run` line copied off the internet, you can explain every flag before pasting it.

**Look into:** containers vs VMs at a high level; what an image is; the Docker Hub library; the basic CLI verbs above; port publishing vs container ports; bind mounts vs named volumes (just enough to choose between them); why `docker run` without `-d` blocks your terminal.

**Official docs**
- Install Docker Engine on Ubuntu — https://docs.docker.com/engine/install/ubuntu/
- Post-install: run as non-root — https://docs.docker.com/engine/install/linux-postinstall/
- `docker run` reference — https://docs.docker.com/reference/cli/docker/container/run/
- Postgres image — https://hub.docker.com/_/postgres
- nginx image — https://hub.docker.com/_/nginx

---

## Day 2 — CatVet in a container

> **As a** teammate cloning CatVet,
> **I want** to run it with a single `docker run`,
> **so that** I don't need Java or Maven installed to try the service.

Today you write your first Dockerfile, by hand, and get CatVet running from an image you built. Keep it simple — single stage, one base image, no optimization yet. Day 3 makes it good; today only needs to make it work.

**Acceptance criteria**
- [ ] A hand-written `Dockerfile` lives at the CatVet repo root.
- [ ] `docker build -t catvet:dev .` succeeds.
- [ ] `docker run -p 8080:8080 catvet:dev` runs the service; `/ping` responds from the host.
- [ ] The base image uses an explicit version tag (no `:latest`) and a justified JDK distribution (e.g. `eclipse-temurin:25-jdk`).
- [ ] A `.dockerignore` excludes `target/`, `.git/`, and IDE files.
- [ ] You can explain what each line of your Dockerfile does, in your own words.
- [ ] You can name which step of the build is slowest and why.

**Look into:** Dockerfile instructions (`FROM`, `COPY`, `RUN`, `WORKDIR`, `ENTRYPOINT`, `CMD`, `EXPOSE`); choosing a Java base image (Temurin vs Corretto vs others); build context and why `.dockerignore` matters; the difference between `CMD` and `ENTRYPOINT`; how Spring Boot's fat JAR is structured.

**Official docs**
- Dockerfile reference — https://docs.docker.com/reference/dockerfile/
- `docker build` — https://docs.docker.com/reference/cli/docker/buildx/build/
- Eclipse Temurin images — https://hub.docker.com/_/eclipse-temurin
- Spring Boot container images guide — https://docs.spring.io/spring-boot/reference/packaging/container-images/index.html

---

## Day 3 — A good image, not just an image

> **As a** developer preparing to publish CatVet's image,
> **I want** it small, fast to rebuild, and free of obvious vulnerabilities,
> **so that** pushing it, pulling it, and trusting it are all cheap.

Today you refine the Day 2 image. The single-stage build wastes space and is slow to rebuild — multi-stage fixes the first, layer ordering fixes the second.

**Acceptance criteria**
- [ ] The Dockerfile uses a **multi-stage** build (Maven build stage → JRE runtime stage).
- [ ] The final image does not contain Maven or the JDK.
- [ ] The final image is meaningfully smaller than Day 2's single-stage image — confirm with `docker images`.
- [ ] Rebuilding after a Java-only change is noticeably faster than rebuilding after a `pom.xml` change — and you can explain the cache reason.
- [ ] You've run an image scan (`docker scout cves` or `trivy image`) against your image and noted at least one finding plus what would fix it.
- [ ] You can articulate why a JRE base is preferred over a JDK at runtime and what "distroless" is (without necessarily using it).

**Look into:** multi-stage build pattern (named stages, `COPY --from=`); the layer cache and how instruction order affects cache hits; JDK vs JRE images; "distroless" and why teams pick it; container image scanning and CVE severity; image size as a real cost (push/pull time, attack surface).

**Official docs**
- Multi-stage builds — https://docs.docker.com/build/building/multi-stage/
- Build cache best practices — https://docs.docker.com/build/cache/
- Docker Scout — https://docs.docker.com/scout/
- Trivy — https://trivy.dev/latest/docs/

---

## Day 4 — App + database in one command

> **As a** teammate trying CatVet for the first time,
> **I want** the app and its Postgres database to start with one command,
> **so that** I don't have to remember container flags or run two terminals.

The Postgres profile already exists in CatVet (from [catvet-week1.md](catvet-week1.md) Day 3). Today you wire app + database together with Docker Compose. The H2 profile stays — it's still your zero-dependency local mode.

**Acceptance criteria**
- [ ] A `compose.yml` at the repo root defines two services: `app` and `db`.
- [ ] `docker compose up` brings both to a healthy state; `docker compose down` cleans up.
- [ ] The app reaches Postgres by **service name**, not `localhost`, and you can explain why that works.
- [ ] DB credentials and the app's datasource URL come from environment variables, not hardcoded values.
- [ ] A `.env` file holds credentials, is gitignored, and an `.env.example` shows the keys.
- [ ] A **named volume** persists Postgres data across `down`/`up` cycles — write a cat, restart the stack, read it back.
- [ ] The app handles Postgres not being ready yet (Spring retry, or healthcheck-based `depends_on` — your choice, justify it).
- [ ] `docker compose logs -f app` shows Spring Boot's startup logs.

**Look into:** the Compose v2 file format (no `version:` field at the top); user-defined networks and container DNS; bind mounts vs named volumes; environment injection via `environment:` and `env_file:`; healthchecks (`pg_isready`, Spring Boot Actuator `/health`); `depends_on` with `condition: service_healthy`; override files (`compose.override.yml`).

**Official docs**
- Docker Compose overview — https://docs.docker.com/compose/
- Compose file reference — https://docs.docker.com/reference/compose-file/
- Networking in Compose — https://docs.docker.com/compose/how-tos/networking/
- Postgres image (env vars, volumes) — https://hub.docker.com/_/postgres
- Spring profiles & external config — https://docs.spring.io/spring-boot/reference/features/external-config.html

---

## Day 5 — Published from a pipeline

> **As a** developer shipping CatVet changes,
> **I want** every push to `main` to build and publish a new image automatically under a meaningful tag,
> **so that** the latest tested build is always available without me running anything by hand.

Today closes the Week 1 loop. You publish your image to Docker Hub manually first, then move the same steps into a GitHub Actions workflow. No deployment yet — that arrives in Week 2 with Kubernetes.

**Acceptance criteria**
- [ ] A free Docker Hub account exists; you've logged in via `docker login` using an **access token**, not your password.
- [ ] You've manually pushed CatVet to `docker.io/<your-user>/catvet` under **two tags**: a git-sha tag (e.g. `sha-abc1234`) and a semver tag (e.g. `0.1.0`).
- [ ] On a clean machine (or after `docker image prune -a`), `docker run` against the registry tag starts CatVet without rebuilding.
- [ ] A GitHub Actions workflow at `.github/workflows/build.yml` runs on push to `main` and: checks out the code, sets up Java 25, runs `mvn verify`, builds the Docker image tagged with the git SHA (semver tags are applied manually at release time, not in this workflow), and pushes it to Docker Hub.
- [ ] Docker Hub credentials are stored as GitHub **Actions secrets** — no credentials in committed files.
- [ ] A green workflow run is visible in the GitHub UI; the new tag appears in the Docker Hub web UI.
- [ ] You can articulate why `latest` is a trap once a pipeline exists and what tag a deploy step would actually reference.

**Look into:** registries (Docker Hub vs GHCR vs private); image manifests, digests (`sha256:…`), and why digests are stronger than tags; tagging strategies (semver, git sha, `latest`); access tokens vs passwords; GitHub Actions building blocks (workflow, job, step, runner); the actions you'll use today (`actions/checkout`, `actions/setup-java`, `docker/login-action`, `docker/build-push-action`); GitHub repository secrets.

**Official docs**
- Docker Hub — https://docs.docker.com/docker-hub/
- `docker push` / `docker tag` — https://docs.docker.com/reference/cli/docker/image/push/
- GitHub Actions — https://docs.github.com/en/actions
- `setup-java` — https://github.com/actions/setup-java
- `docker/login-action` — https://github.com/docker/login-action
- `docker/build-push-action` — https://github.com/docker/build-push-action
- Encrypted secrets in Actions — https://docs.github.com/en/actions/security-guides/encrypted-secrets

---

## Week 2 — Kubernetes & Helm (next roadmap)

Sketched, not detailed yet — Week 1 has to land first. Expected outcomes, one per day:

- **Day 1** — Kubernetes concepts and a local Minikube cluster running.
- **Day 2** — CatVet running on Minikube from hand-written `Deployment` and `Service` manifests.
- **Day 3** — Configuration via `ConfigMap` and `Secret`; Postgres in-cluster with a `PersistentVolumeClaim`.
- **Day 4** — Same deployment expressed as a Helm chart; `install`, `upgrade`, `rollback` working.
- **Day 5** — The Week 1 GitHub Actions pipeline extended to run `helm upgrade --install` against a reachable cluster.

## Week 3+ backlog

- Real ingress with TLS — `ingress-nginx` + `cert-manager`. https://kubernetes.github.io/ingress-nginx/ , https://cert-manager.io/docs/
- Proper secrets — Sealed Secrets, External Secrets, or SOPS. https://external-secrets.io/
- Observability in K8s — Prometheus, Grafana, Loki. https://prometheus.io/docs/ , https://grafana.com/docs/
- Multi-environment Helm values (dev/staging/prod) and per-environment release pipelines.
- GitOps — ArgoCD or Flux pulling from Git instead of CI pushing to the cluster. https://argo-cd.readthedocs.io/
- A real cloud cluster (DigitalOcean, GKE Autopilot, EKS) to feel the differences from Minikube.
- Build pipeline polish — caching Maven deps in Actions, image scanning as a CI step, conditional tagging on git refs.

---

*Note: as with the other roadmaps, some deep-linked doc URLs (Docker and GitHub Actions especially) get reorganized between versions. If one 404s, start from that project's documentation home and navigate down.*
