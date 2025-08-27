# ace-tests-backend

Simple Node.js Express backend storing messages in a MySQL database.

Routes:
- POST /messages - body: { "content": "..." } - creates a message and returns it
- GET /messages - returns all messages
- GET /messages/:id - returns message by id

Run locally:
1. Copy .env.example to .env and set DB_* values
2. Run the SQL in create_table.sql to create the database and table
3. npm install
4. npm start

secret fixed
