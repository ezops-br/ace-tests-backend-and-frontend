require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ace_tests',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Database initialization function
async function initializeDatabase() {
  try {
    console.log('Initializing database...');
    
    // Create database if it doesn't exist
    await pool.execute(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'ace_tests'}`);
    console.log(`Database ${process.env.DB_NAME || 'ace_tests'} is ready`);
    
    // Create messages table if it doesn't exist
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Messages table is ready');
    
    console.log('Database initialization completed successfully');
  } catch (error) {
    console.error('Database initialization failed:', error);
    // Don't exit the process, let the app continue
    // The health check will catch database issues
  }
}

// POST /messages - record a message
app.post('/messages', async (req, res) => {
  const { content } = req.body;
  if (!content) return res.status(400).json({ error: 'content is required' });
  try {
    const [result] = await pool.query('INSERT INTO messages (content) VALUES (?)', [content]);
    const insertedId = result.insertId;
    const [rows] = await pool.query('SELECT * FROM messages WHERE id = ?', [insertedId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'database error' });
  }
});

// GET /messages - get all messages
app.get('/messages', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM messages ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'database error' });
  }
});

// GET /messages/:id - get message by id
app.get('/messages/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (!id) return res.status(400).json({ error: 'invalid id' });
  try {
    const [rows] = await pool.query('SELECT * FROM messages WHERE id = ?', [id]);
    if (rows.length === 0) return res.status(404).json({ error: 'not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'database error' });
  }
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await pool.execute('SELECT 1');
    res.json({ status: 'healthy', database: 'connected' });
  } catch (err) {
    console.error('Health check failed:', err);
    res.status(503).json({ status: 'unhealthy', database: 'disconnected' });
  }
});

const port = process.env.PORT || 3000;

// Initialize database and start server
async function startServer() {
  try {
    // Initialize database first
    await initializeDatabase();
    
    // Start the server
    app.listen(port, () => {
      console.log(`Server listening on port ${port}`);
      console.log('Database initialization completed');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
