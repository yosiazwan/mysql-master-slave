const mysql = require('mysql2/promise');

const config = {
  host: '127.0.0.1',
  port: 6033, // ProxySQL port
  user: 'appuser',
  password: 'apppass',
  database: 'test',
};

class MySQLTester {
  constructor(config) {
    this.config = config;
  }

  async testSelect() {
    const connection = await mysql.createConnection(this.config);

    console.log('✅ Connected to ProxySQL');

    const [currentTimeRows] = await connection.query('SELECT NOW() AS time');
    const currentTime = currentTimeRows[0].time;

    const [rows] = await connection.query(
      `SELECT *, ? AS currentTime FROM test_table ORDER BY id DESC LIMIT 5;`,
      [currentTime]
    );

    console.table(rows);

    await connection.end();
  }
}



(async () => {
  for (let i = 0; i < 5; i++) {
    try {
      const tester = new MySQLTester(config);
      tester.testSelect();
    } catch (err) {
      console.error('❌ Error:', err);
    }
  }
})();
