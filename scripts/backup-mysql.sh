#!/bin/bash

set -e

NAMESPACE="skillpulse"
DB_NAME="skillpulse"
DB_USER="skillpulse"
DB_PASSWORD="skillpulse123"
BACKUP_DIR="backups"
BACKUP_FILE="$BACKUP_DIR/skillpulse-backup-$(date +%Y%m%d-%H%M%S).sql"

echo "Creating backup folder..."
mkdir -p $BACKUP_DIR

echo "Finding MySQL pod..."
MYSQL_POD=$(kubectl get pod -n $NAMESPACE -l app=mysql -o jsonpath="{.items[0].metadata.name}")

echo "Taking MySQL backup from pod: $MYSQL_POD"
kubectl exec -n $NAMESPACE $MYSQL_POD -- mysqldump --no-tablespaces -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

echo "Backup completed."
echo "Backup saved at: $BACKUP_FILE"
