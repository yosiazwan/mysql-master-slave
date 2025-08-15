#!/bin/bash
set -e

# Generate init.sql dari template
envsubst < /init/proxysql/init.sql.template > /init/proxysql/init.sql

# Start ProxySQL
/usr/bin/proxysql --initial &

# Tunggu ProxySQL siap
for i in {1..10}; do
  echo "⌛ Menunggu ProxySQL..."
  sleep 3
  mysql -u admin -padmin -h 127.0.0.1 -P6032 -e "SELECT 1" && break
done

echo "🚀 Menjalankan init.sql"
mysql -u admin -padmin -h 127.0.0.1 -P6032 < /init/proxysql/init.sql || true

# Keep container alive
tail -f /dev/null
