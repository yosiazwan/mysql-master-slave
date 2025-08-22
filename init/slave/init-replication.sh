#!/bin/bash
set -e

# Load env
REPL_USER=${REPL_USER:-repl_prod_1}
REPL_PASSWORD=${REPL_PASSWORD:-R3plC0mpl3x!2025}
ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-SuperRootPass!2025}

# Wait master ready
until mysql --connect-timeout=2 -h mysql-master -uroot -p"$ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null; do
  echo "[INFO] Waiting for master..."
  sleep 2
done

# Configure replication
mysql -uroot -p"$ROOT_PASSWORD" <<EOF
STOP REPLICA;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-master',
  SOURCE_USER='$REPL_USER',
  SOURCE_PASSWORD='$REPL_PASSWORD',
  SOURCE_AUTO_POSITION=1,
  GET_SOURCE_PUBLIC_KEY=1;
START REPLICA;
EOF

echo "[INFO] Replication started"
