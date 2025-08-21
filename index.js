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

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server listening on port ${port}`));
