-- proxysql-init.sql

-- Tambah MySQL server
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (10, 'mysql-master', 3306);
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (20, 'mysql-slave', 3306);

-- Aturan query SELECT
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply)
VALUES (1, 1, '^SELECT.*', 20, 1);

-- Tambah user
INSERT INTO mysql_users (username, password, default_hostgroup)
VALUES ('appuser', 'apppass', 10);

-- Apply konfigurasi
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;
