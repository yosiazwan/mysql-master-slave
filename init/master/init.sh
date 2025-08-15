#!/bin/bash
set -e

# Tunggu MySQL siap
until mysqladmin ping -h "localhost" --silent; do
  echo "[INFO] Menunggu MySQL siap..."
  sleep 2
done

echo "[INFO] Membuat user replikasi dan app user..."

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
-- Replication user
CREATE USER IF NOT EXISTS '${REPL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${REPL_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

echo "[INFO] User selesai dibuat."
