app.get('/auditoria', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM auditoria
      ORDER BY data_hora DESC
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      erro: error.message
    });
  }
});

