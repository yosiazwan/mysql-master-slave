#!/bin/bash

# Tunggu sampai MySQL master bisa diakses
until mysql --connect-timeout=2 --silent -h mysql-master -uroot -prootpass -e "SELECT 1;" &>/dev/null; do
  echo "[INFO] Menunggu master..."
  sleep 2
done

# Ambil posisi binlog dari master
echo "[INFO] Ambil MASTER STATUS"
read -r BINLOG_FILE BINLOG_POS <<< $(mysql -h mysql-master -uroot -prootpass -Nse "SHOW MASTER STATUS" | awk '{print $1, $2}')

# Cek apakah nilai berhasil diambil
if [ -z "$BINLOG_FILE" ] || [ -z "$BINLOG_POS" ]; then
  echo "[ERROR] Gagal mendapatkan informasi MASTER STATUS."
  exit 1
fi

echo "[INFO] Setting replication dari $BINLOG_FILE:$BINLOG_POS"

# Konfigurasi replikasi dan mulai slave
mysql -uroot -prootpass <<EOF
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-master',
  SOURCE_USER='repl',
  SOURCE_PASSWORD='replpass',
  SOURCE_LOG_FILE='$BINLOG_FILE',
  SOURCE_LOG_POS=$BINLOG_POS;

START REPLICA;

GRANT SELECT ON *.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

-- (Opsional tapi direkomendasikan) Jadikan slave read-only sepenuhnya
SET GLOBAL super_read_only = ON;
EOF
