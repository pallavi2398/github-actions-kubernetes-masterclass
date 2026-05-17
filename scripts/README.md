# Automation Scripts

This folder contains simple scripts that make local Kubernetes operations easier.

## Scripts

- `deploy-local.sh` - build images, load them into kind, apply Kubernetes manifests, and wait for pods.
- `health-check.sh` - check pods, services, endpoints, and application health.
- `log-analyzer.sh` - scan recent Kubernetes logs for common error patterns.
- `backup-mysql.sh` - create a local backup of the MySQL database running in Kubernetes.
- `restore-mysql.sh` - restore a saved MySQL backup into the Kubernetes database pod.

These scripts are intentionally beginner-friendly so each automation is easy to run, understand, and explain during the hackathon submission.

## How to run

Run these commands from the project root.

Deploy the application locally:

```bash
./scripts/deploy-local.sh
```

Check application health:

```bash
./scripts/health-check.sh
```

Analyze recent Kubernetes logs:

```bash
./scripts/log-analyzer.sh
```

Back up the MySQL database:

```bash
./scripts/backup-mysql.sh
```

Restore a MySQL backup:

```bash
./scripts/restore-mysql.sh backups/<backup-file>.sql
```

## Notes

- The local app is available at `http://localhost:8888` when the kind cluster is running.
- Database backups are saved in the `backups/` folder.
- Restore needs a backup file path, for example `backups/skillpulse-backup-20260517-103000.sql`.
- The `backups/` folder and `.sql` files should stay ignored by Git because database backups can contain sensitive data.
