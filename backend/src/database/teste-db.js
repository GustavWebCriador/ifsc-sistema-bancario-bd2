const pool = require('./database');

app.get('/teste-db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');

    res.json({
      conectado: true,
      servidor: result.rows[0]
    });

  } catch (error) {
    res.status(500).json({
      conectado: false,
      erro: error.message
    });
  }
});