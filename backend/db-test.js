const { Pool } = require('pg');
require('dotenv').config();

// Use explicit connection parameters to debug
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'av_converter',
  password: 'root', // Replace with your actual password
  port: 5432,
});

async function testConnection() {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    console.log('Connection successful! Current time from DB:', result.rows[0]);
    client.release();
  } catch (err) {
    console.error('Database connection error:', err);
  } finally {
    pool.end();
  }
}

testConnection();