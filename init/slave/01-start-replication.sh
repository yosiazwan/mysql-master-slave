#!/bin/bash
set -e

# Ambil environment
REPL_USER=${REPL_USER:-repluser}
REPL_PASSWORD=${REPL_PASSWORD:-replpass}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-rootpass}
MYSQL_USER=${MYSQL_USER:-appuser}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-apppass}

# Tunggu master siap
until mysql --connect-timeout=2 --silent -h mysql-master -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null; do
  echo "[INFO] Menunggu master..."
  sleep 2
done

echo "[INFO] Master siap, mulai konfigurasi replication..."

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
-- Hybrid replication menggunakan GTID
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-master',
  SOURCE_USER='$REPL_USER',
  SOURCE_PASSWORD='$REPL_PASSWORD',
  MASTER_AUTO_POSITION=1;

START REPLICA;

-- Slave read-only
SET GLOBAL super_read_only = ON;

-- Buat appuser untuk query read
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT SELECT ON *.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

echo "[INFO] Slave replication sudah berjalan."
