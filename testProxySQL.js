const mysql = require('mysql2/promise');

const config = {
  host: '127.0.0.1',
  port: 6033, // ProxySQL port
  user: 'appuser',
  password: 'apppass',
  database: 'test',
};

async function testProxySQL() {
  const connection = await mysql.createConnection(config);

  console.log('✅ Connected to ProxySQL');

  // Buat table jika belum ada
  await connection.query(`
    CREATE TABLE IF NOT EXISTS test_table (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Insert data
  const [insertResult] = await connection.query(`
    INSERT INTO test_table (name) VALUES ('Data from JS via ProxySQL');
  `);
  console.log(`📝 Inserted row with ID: ${insertResult.insertId}`);

  // Select data
  const [rows] = await connection.query(`
    SELECT * FROM test_table ORDER BY id DESC LIMIT 5;
  `);
  console.log('📦 Last 5 rows (should come from slave):');
  console.table(rows);

  await connection.end();
}

testProxySQL().catch(err => {
  console.error('❌ Error:', err);
});
