# SkillPulse — GitHub Actions & Kubernetes Masterclass

A small, real application with a real CI/CD pipeline. The app — SkillPulse — lets you track skills you're learning and the hours you put in. The point isn't the app. The point is everything around it: how a single `git push` becomes a running update on a server in under two minutes, with no human pressing any button.

This repo is the working demo for the **TrainWithShubham GitHub Actions & Kubernetes Masterclass**.

> **New here? Two beginner-friendly companion guides:**
>
> - [`docs/skillpulse-cicd-guide.pdf`](docs/skillpulse-cicd-guide.pdf) — chapter one. 29 pages on the GitHub Actions pipeline: DevOps foundations, CI/CD, containers, deploying to a real EC2, plus resume + interview prep.
> - [`docs/skillpulse-kubernetes-guide.pdf`](docs/skillpulse-kubernetes-guide.pdf) — chapter two. 32 pages on running this app on a local `kind` cluster: Kubernetes primitives, manifest walkthrough, the dev loop, real failures we hit (arch mismatches, port collisions), interview prep.

---

## Hackathon Enhancements

This fork improves the original three-tier SkillPulse project with beginner-friendly DevOps automation, CI/CD optimization, DevSecOps checks, Docker image optimization, Kubernetes reliability improvements, and Infrastructure as Code.

The goal was to reduce manual work, improve deployment confidence, and make the project easier to operate in both local Kubernetes and EC2-based deployment flows.

### What was added

| Area | Improvement | Why it matters |
| --- | --- | --- |
| CI/CD optimization | Added Docker build cache, backend Go checks, and workflow concurrency in `.github/workflows/ci.yml` | Reuses unchanged Docker layers, catches backend issues earlier, and cancels outdated runs |
| DevSecOps | Added reusable workflows for Docker linting, secrets scanning, code quality, and image scanning | Blocks image build and deployment if security checks fail |
| Docker optimization | Optimized backend Dockerfile with dependency caching and a distroless runtime image | Reduced backend image size and improved runtime security |
| Kubernetes reliability | Added 2 replicas, rolling update strategy, backend security context, and separate readiness probe | Improves availability and safer rollouts |
| Observability | Added `/health` and `/ready` endpoints | Helps Kubernetes distinguish between "alive" and "ready for traffic" |
| Local automation | Added scripts for local deploy, health checks, log analysis, backup, and restore | Reduces repeated manual commands during local testing |
| IaC | Added Terraform for EC2 provisioning | Makes the deployment server repeatable |
| Configuration automation | Added Ansible to install Docker, Docker Compose, and Git on EC2 | Prepares the EC2 server automatically for deployment |

### DevSecOps workflows

The DevSecOps pipeline is split into small reusable workflows:

```text
.github/workflows/code-quality.yml        -> Go test and Go vet
.github/workflows/docker-lint.yml         -> Hadolint for Dockerfiles
.github/workflows/secrets-scan.yml        -> Gitleaks secret scanning
.github/workflows/image-scan.yml          -> Trivy image vulnerability scanning
.github/workflows/devsecops-pipeline.yml  -> Runs all checks together
```

On every push to `main`, the DevSecOps pipeline runs the full flow in one graph: code quality, secret scanning, Dockerfile linting, Trivy image scanning, CI image build/push, and CD deployment. CI starts only after `image-scan` succeeds. CD starts only after CI succeeds.

Gitleaks handles secret detection, so Trivy is configured to focus on image vulnerability scanning.

### Local Kubernetes automation

The `scripts/` folder contains simple operational scripts:

```text
scripts/deploy-local.sh     -> builds images, loads them into kind, applies manifests, and waits for rollouts
scripts/health-check.sh     -> checks pods, services, endpoints, /health, and /ready
scripts/log-analyzer.sh     -> shows events/logs and searches for common failure words
scripts/backup-mysql.sh     -> creates a MySQL backup from the Kubernetes pod
scripts/restore-mysql.sh    -> restores a MySQL backup into the Kubernetes pod
```

Run from the project root:

```bash
./scripts/deploy-local.sh
./scripts/health-check.sh
./scripts/log-analyzer.sh
./scripts/backup-mysql.sh
./scripts/restore-mysql.sh backups/<backup-file>.sql
```

### Infrastructure automation

Terraform and Ansible live under `infra/`:

```text
infra/terraform/  -> creates the EC2 deployment server
infra/ansible/    -> configures the EC2 server with Docker, Docker Compose, and Git
```

Provision EC2:

```bash
cd infra/terraform
ssh-keygen -t ed25519 -f terra-automate-key -C "skillpulse-ec2"
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Configure EC2:

```bash
cd ../ansible
cp inventory.example.ini inventory.ini
ansible-playbook -i inventory.ini setup-server.yml
```

The real `terraform.tfvars`, Ansible `inventory.ini`, Terraform state, and private SSH key are ignored by Git.

### GitHub Actions secrets

The EC2 deployment workflow needs these GitHub Actions secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
EC2_HOST
EC2_USER
EC2_SSH_KEY
```

It also needs this repository variable:

```text
DEPLOY_ENABLED=true
```

The EC2 server also needs a local `.env` file in `~/github-actions-kubernetes-masterclass`:

```env
DOCKERHUB_USERNAME=<your-dockerhub-username>
MYSQL_ROOT_PASSWORD=rootpassword123
DB_NAME=skillpulse
DB_USER=skillpulse
DB_PASSWORD=skillpulse123
```

This `.env` file is not committed because it contains runtime configuration.

### Verified results

Local verification completed successfully:

```text
Docker build: backend and frontend images built successfully
Kubernetes: backend, frontend, and MySQL pods running
Health checks: /health returned healthy and /ready returned ready
Backup/restore: MySQL backup and restore completed successfully
Go checks: go test ./... and go vet ./... passed
Terraform: terraform validate passed
Ansible: EC2 setup completed with failed=0
GitHub Actions: CI/CD pipeline completed green and app deployed to EC2
```

Backend image size improved from:

```text
34.6MB -> 18.3MB
```

### Proof screenshots to capture

Take these screenshots for the hackathon submission:

1. GitHub Actions page showing green DevSecOps pipeline with `image-scan -> CI -> CD`.
2. CI job logs showing backend and frontend images built and pushed.
3. GitHub Actions CD job showing successful EC2 deployment.
4. Browser showing the app running on EC2: `http://<EC2_PUBLIC_IP>`.
5. Docker image size output showing backend image size around `18.3MB`.
6. Local Kubernetes pods running:

```bash
kubectl get pods -n skillpulse
```

7. Health check script output:

```bash
./scripts/health-check.sh
```

8. Backup and restore script output:

```bash
./scripts/backup-mysql.sh
./scripts/restore-mysql.sh backups/<backup-file>.sql
```

9. Terraform output showing EC2 public IP:

```bash
terraform output
```

10. Ansible recap showing `failed=0`:

```bash
ansible-playbook -i inventory.ini setup-server.yml
```

11. EC2 server containers running:

```bash
ssh -i infra/terraform/terra-automate-key ubuntu@<EC2_PUBLIC_IP>
cd ~/github-actions-kubernetes-masterclass
docker compose ps
```

### How to compare time reduction

Use GitHub Actions run duration to compare before and after optimization:

1. Open GitHub repository.
2. Go to `Actions`.
3. Open an older CI run before the optimization.
4. Note the total run time and job time.
5. Open the latest CI run after the optimization.
6. Compare the total run time and the Docker build step duration.

The important improvements to look for:

```text
Docker layer cache is reused in later builds
unchanged Docker layers show as cached
old workflow runs are cancelled when newer commits are pushed
backend code is tested before images are built
backend image size is smaller, reducing push/pull work
```

Useful commands for local proof:

```bash
docker images | grep skillpulse
time ./scripts/deploy-local.sh
```

The first optimized run may still take time because dependencies and cache layers are created. The next runs should be faster because Docker and GitHub Actions can reuse cache.

---

## Why DevOps matters

For most of software's history, the people who *wrote* software and the people who *ran* it were two different teams with two different goals.

- Developers wanted to ship features.
- Operations wanted stability.

The fastest way for ops to be stable was to slow developers down. The fastest way for developers to ship was to throw code over the wall. Both teams were right. Both teams were also miserable. And the customer paid the price — releases happened once a quarter, every release was scary, and bugs took weeks to fix.

DevOps is the cultural and technical answer to that: *the same team owns the change all the way to production, and tooling makes that safe.* It's not a job title. It's a way of working that says small, frequent, automated, and reversible beats big, rare, manual, and irreversible — every time.

When DevOps is working you can tell because:

- **Deploys are boring.** Friday afternoon, Monday morning, doesn't matter.
- **Rollbacks are cheap.** A bad deploy is a 30-second fix, not an incident.
- **Feedback is fast.** A broken commit fails CI in minutes, not "after QA next sprint."
- **Ownership is clear.** The person who wrote the code is the person who watches it ship.

You get there by automating the path from a developer's laptop to production. That automation is called a **pipeline**.

---

## Why CI/CD is the heart of DevOps

CI/CD is two ideas wearing one acronym.

- **Continuous Integration** — every change, from every developer, gets built and tested automatically the moment it lands. You catch breakage in minutes, not days. Merge conflicts shrink because nobody's branch lives for two weeks.
- **Continuous Delivery / Deployment** — every change that passes CI is automatically packaged and shipped — to staging, or all the way to production. There is no "deploy day." Every commit is a candidate release.

The reason this matters: the cost of fixing a bug grows with the time between writing it and finding it. CI/CD shortens that gap to minutes. The reason it's hard: the only way to make it work is to *automate everything*. Build, test, package, deploy, verify. No "just run this script on my laptop" steps. If a human has to remember it, it will eventually be forgotten — and then it will fail at 2 a.m.

---

## Why GitHub Actions

A pipeline needs a runner — something that watches your repo, executes your build/test/deploy steps, and reports back. Historically that meant standing up a Jenkins server, paying for CircleCI, or wiring something custom. All of those still work; none of them are the lowest-friction option in 2026.

GitHub Actions wins on three things:

1. **It lives where the code lives.** No separate server, no separate auth, no separate UI. Your `.github/workflows/*.yml` files are part of the repo — they evolve with the code, get reviewed in the same PRs, and survive every clone.
2. **It's free for public repos and generous for private ones.** A complete CI/CD pipeline costs zero rupees to start.
3. **The Marketplace is enormous.** Need to SSH into a server? `appleboy/ssh-action`. Need to log in to Docker Hub? `docker/login-action`. You compose pre-built blocks instead of writing bash from scratch.

The trade-off is GitHub lock-in. For most teams, that's a fair price for the integration.

---

## What this project demonstrates

A real pipeline, end to end, in roughly 50 lines of YAML.

```
┌─────────────┐     git push        ┌──────────────────┐
│  Developer  ├────────────────────▶│  GitHub Repo     │
└─────────────┘                     └────────┬─────────┘
                                             │ on: push (main)
                                             ▼
                                    ┌──────────────────┐
                                    │ DevSecOps checks │
                                    │  - code quality  │
                                    │  - secrets scan  │
                                    │  - docker lint   │
                                    │  - image scan    │
                                    └────────┬─────────┘
                                             │ needs: image-scan
                                             ▼
                                    ┌──────────────────┐
                                    │  CI Workflow     │
                                    │  - build images  │
                                    │  - tag :sha      │
                                    │  - tag :latest   │
                                    │  - push to Hub   │
                                    └────────┬─────────┘
                                             │ needs: ci
                                             ▼
                                    ┌──────────────────┐
                                    │  CD Workflow     │
                                    │  - SSH to EC2    │
                                    │  - git pull      │
                                    │  - compose pull  │
                                    │  - compose up -d │
                                    └────────┬─────────┘
                                             │
                                             ▼
                                    ┌──────────────────┐
                                    │  EC2: live app   │
                                    │  http://<host>   │
                                    └──────────────────┘
```

### CI — `.github/workflows/ci.yml`

Called by the DevSecOps pipeline after the security checks pass. It does four things:

1. **Checks out the code.** A fresh clone in a clean Ubuntu runner — no laptop state to leak.
2. **Builds two Docker images.** A Go backend and an Nginx-served frontend. Both are multi-stage so the final images are small.
3. **Tags each image twice.** With the commit SHA (`:abc1234…`) and with `:latest`. The SHA tag is your rollback handle — you can always pin a deploy to an exact commit. The `:latest` tag is what production pulls.
4. **Pushes both to Docker Hub.** Authenticated with secrets (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`) — never plaintext credentials in the repo.

The non-obvious lesson: **CI doesn't just test your code. It produces an artifact.** That artifact — the image — is what production runs. If the artifact is built consistently in CI, it's the same in dev, staging, and prod. "Works on my machine" stops being a possibility.

### CD — `.github/workflows/cd.yml`

Called by the DevSecOps pipeline after CI completes successfully. Skipped if CI failed — you cannot deploy a broken build.

It SSHes into an EC2 instance and runs:

```bash
if [ ! -d ~/skillpulse ]; then
  git clone <this repo> ~/skillpulse
fi
cd ~/skillpulse
git pull origin main
[ -f .env ] || { echo "ERROR: .env missing"; exit 1; }
docker compose pull
docker compose up -d
docker image prune -f
```

Every line earns its place:

- The `if [ ! -d ... ]` makes the script **idempotent** — the same script runs whether it's the first deploy or the hundredth.
- The `.env` check fails *loudly* with a useful message instead of letting `docker compose` produce a cryptic error about missing variables.
- `docker compose pull` brings in the image you just built. `up -d` only recreates containers whose image actually changed — backend and DB don't get bounced if you only edited frontend HTML.
- `docker image prune -f` keeps the EC2 disk from filling up with old image layers over weeks of deploys.

### Secrets used

| Secret | What it is |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub account name |
| `DOCKERHUB_TOKEN` | A Docker Hub Personal Access Token with read+write scope |
| `EC2_HOST` | Public IP or DNS of the deploy target |
| `EC2_USER` | Linux user on the EC2 (typically `ubuntu`) |
| `EC2_SSH_KEY` | Private key contents — paste the entire `.pem` file as the secret value |

Set them at `Settings → Secrets and variables → Actions` on your fork.

---

## The application itself

A three-tier app — kept tiny on purpose so the pipeline is the star.

| Tier | Tech | What it does |
|---|---|---|
| Frontend | HTML + CSS + vanilla JS, served by Nginx | UI for adding skills and logging hours |
| Backend | Go 1.26 + Gin | REST API at `/api/...` |
| Database | MySQL 8.4 | Stores skills and learning logs |

Nginx in the frontend image also reverse-proxies `/api/` and `/health` to the backend, so the public surface is a single port (`80`).

API surface:

```
GET    /api/skills              list skills + total hours
POST   /api/skills              create skill
GET    /api/skills/:id          one skill + its logs
DELETE /api/skills/:id          delete skill (cascades logs)
POST   /api/skills/:id/log      log a study session
GET    /api/dashboard           summary counters
GET    /health                  DB ping for healthchecks
```

---

## Run it locally

```bash
cp .env.example .env             # fill in DOCKERHUB_USERNAME (anything works for local)
docker compose up -d --build
```

Open http://localhost. Backend port 8080 is intentionally not exposed — all traffic goes through Nginx, exactly like production.

To tear down:

```bash
docker compose down -v           # -v also drops the MySQL volume
```

---

## Run on Kubernetes (kind)

Same app, same images, same external port — but now every primitive a student would see in production: namespace, deployment, service, statefulset, configmap, secret, pvc.

**Prerequisites:** Docker Desktop running, plus `brew install kind kubectl`.

```bash
make up                          # creates the kind cluster + applies manifests
# visit http://localhost:8888
make down                        # deletes the cluster (and the MySQL data with it)
```

What `make up` actually runs, in order:

```bash
docker build -t trainwithshubham/skillpulse-backend:latest  ./backend
docker build -t trainwithshubham/skillpulse-frontend:latest ./frontend
kind create cluster --config k8s/kind-config.yaml --name skillpulse
kind load docker-image trainwithshubham/skillpulse-backend:latest  --name skillpulse
kind load docker-image trainwithshubham/skillpulse-frontend:latest --name skillpulse
kubectl apply -f k8s/00-namespace.yaml \
              -f k8s/10-mysql.yaml \
              -f k8s/20-backend.yaml \
              -f k8s/30-frontend.yaml
kubectl rollout status statefulset/mysql   -n skillpulse --timeout=180s
kubectl rollout status deployment/backend  -n skillpulse --timeout=120s
kubectl rollout status deployment/frontend -n skillpulse --timeout=60s
```

Notes on this flow:

- **`docker build` runs on your laptop**, producing images for your host's architecture (Apple Silicon → arm64; Intel/Linux → amd64). The cluster never has to deal with multi-arch.
- **`kind load docker-image`** copies each image into the kind node's containerd. `imagePullPolicy: IfNotPresent` on the Deployments means k8s reuses the loaded image and never tries to pull from Docker Hub.
- **`kind-config.yaml`** lives alongside the manifests for proximity, but it's a `kind` config — not a Kubernetes resource — so it's fed to `kind create cluster`, not `kubectl apply`.

Inner-loop after editing code: `make restart` rebuilds the images, reloads them into the cluster, and rolls the Deployments.

### How traffic flows

The cluster has **three nodes**: one control-plane and two workers (`skillpulse-worker`, `skillpulse-worker2`). Workloads schedule onto the workers — the control-plane is tainted `NoSchedule` by default, so it stays focused on the API server, scheduler, and controller-manager.

```
host browser            kind cluster (1 control-plane + 2 workers)
http://localhost:8888
        │
        ▼ (kind extraPortMappings on control-plane: hostPort 8888 → nodePort 30080)
   Service frontend (NodePort 30080)  — reachable on every node, kube-proxy routes
        │
        ▼
   Deployment frontend (nginx + static)  — runs on whichever worker the scheduler picks
        │ proxy_pass http://backend:8080  (same hostname as docker-compose)
        ▼
   Service backend (ClusterIP 8080)
        │
        ▼
   Deployment backend (Go + Gin)
        │ DB_HOST=mysql
        ▼
   Service mysql (Headless 3306)
        │
        ▼
   StatefulSet mysql + 1Gi PVC + ConfigMap-mounted init.sql
```

### Manifest layout

```
k8s/
  kind-config.yaml      cluster shape: 1 control-plane + 2 workers, host 8888 → node 30080
  00-namespace.yaml     namespace: skillpulse
  10-mysql.yaml         Secret + ConfigMap (init.sql) + headless Service + StatefulSet + 1Gi PVC
  20-backend.yaml       Deployment + ClusterIP Service, env from Secret, /health probes
  30-frontend.yaml      Deployment + NodePort Service (30080), / probes
```

### Useful commands

| Command | What it does |
|---|---|
| `make status` | One-screen view of pods, services, endpoints |
| `make logs` | Tail all three workloads at once |
| `make mysql` | Open a `mysql` shell in the StatefulSet pod |
| `make restart` | Roll backend + frontend (e.g. after pushing a new image) |

### Smoke test

```bash
curl http://localhost:8888/health                 # → {"status":"healthy"}
curl http://localhost:8888/api/dashboard          # → seed-data counters
curl -s http://localhost:8888/ | grep '<title>'   # → HTML title containing "SkillPulse"
```

### Gotchas worth knowing

- **Docker Desktop must be running.** `docker build`, `kind`, and `kubectl` all talk to the Docker daemon on your machine.
- **First boot is slow.** The local-path provisioner has to materialise the PVC before MySQL starts. Expect 10–30s of `Pending` on `make up`'s first run.
- **Host port collision.** If something else owns 8888 on the host, the cluster comes up but `curl localhost:8888` fails. Free the port — or change `hostPort` in `k8s/kind-config.yaml` and re-run `make down && make up`.
- **No Docker Hub round-trip in this chapter.** Images are built locally and pushed into the kind node via `kind load`. Useful when you're iterating on code: `make restart` rebuilds + reloads + rolls without ever touching Docker Hub. (Production EKS/GKE clusters do pull from a registry — that's the next chapter.)

### What's next

This is the **kind chapter** — same app, real Kubernetes primitives, but limited to one local node and `NodePort` access. The next chapter graduates the same workload to:

- An **Ingress** controller (nginx-ingress) so traffic enters via `Ingress` rules instead of NodePort.
- **Helm or Kustomize** so the manifests stop being copy-pasted between environments.
- A real **cloud cluster** (EKS / GKE / AKS) and CD that runs `kubectl apply` from the pipeline instead of `appleboy/ssh-action`.

---

## Continuous deployment to the kind cluster

The new CD path doesn't `kubectl apply` from GitHub Actions — your kind cluster lives on your laptop, GitHub can't reach it. Instead, the pipeline takes the GitOps shape: **the repo is the source of truth, your cluster is one `git pull && make apply` away**.

```
git push to main
    ↓
DevSecOps: security checks → CI image build/push → CD to EC2
    ↓
cd-k8s.yml: after DevSecOps succeeds, pin k8s image tags to the successful commit
            commit "deploy: pin backend+frontend to <short-sha>" as github-actions[bot]
    ↓
(you, locally):
    git pull && make apply
    ↓
kind nodes pull the new :<sha> from Docker Hub → rolling update
```

### How to wire it up on your fork

1. **Fork this repo + clone locally.** `make up` should work after that (see the [Run on Kubernetes (kind)](#run-on-kubernetes-kind) section).
2. **Add two secrets** to your fork (`Settings → Secrets and variables → Actions`):

   | Secret | Value |
   |---|---|
   | `DOCKERHUB_USERNAME` | your Docker Hub account name |
   | `DOCKERHUB_TOKEN` | a Docker Hub Personal Access Token with Read & Write scope |

3. **Set the repo variable** `DEPLOY_ENABLED = "true"` (`Settings → Variables → Actions`). Until this is `true`, CI builds without pushing and CD skips cleanly — the "dry run" state.
4. **Push any code change** (not a `.md`, not under `k8s/` or `docs/` — those are deliberately ignored). Watch the Actions tab:
   - **DevSecOps** runs code quality, secrets scan, Docker lint, and image scan.
   - **CI** builds + pushes both images to Docker Hub after `image-scan` succeeds.
   - **CD** deploys to EC2 after CI succeeds.
5. **Pull and deploy**, on the laptop with the kind cluster:
   ```bash
   git pull
   make apply
   kubectl get pods -n skillpulse -o wide
   ```
   You'll see new pods with the bumped image rolling out. mysql untouched.

### What about the EC2 path?

The EC2 path is now part of the main DevSecOps graph. The `cd.yml` workflow SSHes into EC2 and runs `docker compose up`. It is gated on the same `DEPLOY_ENABLED` variable plus three EC2 secrets (`EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`).

### Break it on purpose to learn

- **Push a commit that fails security or build checks** → CI/CD jobs are skipped or stopped before deployment.
- **Rotate the Docker Hub token** → next CI fails at the login step. You'll learn what an expired credential looks like in logs.
- **Edit `k8s/20-backend.yaml`'s image tag by hand and push** → the main DevSecOps flow is skipped because `k8s/` changes are ignored. That's the loop-protection working.

---

## Project layout

```
backend/                Go service
  Dockerfile            multi-stage: golang:1.26-alpine → alpine:3.23
  main.go               wires routes, reads PORT env
  database/db.go        connects to MySQL with retry-loop
  handlers/             skills, logs, dashboard endpoints
  models/               request/response structs

frontend/               static UI + Nginx config
  Dockerfile            FROM nginx:alpine, copies html/css/js + nginx.conf
  index.html, css/, js/ vanilla — no build step
  nginx.conf            serves the site, proxies /api/ to backend:8080

mysql/init.sql          schema + seed data, mounted into the MySQL container

docker-compose.yml      three services: db, backend, frontend
.env.example            copy to .env

.github/workflows/
  devsecops-pipeline.yml  orchestrates security -> CI -> CD
  ci.yml                  reusable build + push workflow
  cd.yml                  reusable SSH deploy workflow
```

---

## Where this goes next

This is the **GitHub Actions** half of the masterclass. The pipeline currently deploys to a single EC2 via SSH + docker compose — a fine starting point, and the most common "first real pipeline" in the industry.

The Kubernetes half of the course evolves this same app onto a cluster:

- Replace `docker compose` with manifests (Deployment, Service, Ingress).
- Replace SSH-driven deploys with `kubectl apply` from CI, then with GitOps (Argo CD / Flux).
- Add health checks, autoscaling, rolling updates with no downtime, secrets via Kubernetes Secrets or external managers.
- Run the cluster on EKS / GKE / AKS or local (kind / minikube).

Same app. Same pipeline shape. Different runtime — and a lot more power.

---

## Credits

Built for the [TrainWithShubham](https://www.youtube.com/@TrainWithShubham) community. If this repo helped you understand a real CI/CD pipeline end to end, share it forward — that's how the community grows.
