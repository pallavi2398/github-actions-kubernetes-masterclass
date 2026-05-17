#!/bin/bash

set -e

NAMESPACE="skillpulse"
DB_NAME="skillpulse"
DB_USER="skillpulse"
DB_PASSWORD="skillpulse123"
BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: ./scripts/restore-mysql.sh <backup-file>"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "Finding MySQL pod..."
MYSQL_POD=$(kubectl get pod -n $NAMESPACE -l app=mysql -o jsonpath="{.items[0].metadata.name}")

echo "Restoring backup file: $BACKUP_FILE"
kubectl exec -i -n $NAMESPACE $MYSQL_POD -- mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME < $BACKUP_FILE

echo "Restore completed."
