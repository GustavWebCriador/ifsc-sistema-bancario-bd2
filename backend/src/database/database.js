const { Pool } = require('pg')

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'sistema_bancario',
  password: '123456',
  port: 5433
})

module.exports = pool