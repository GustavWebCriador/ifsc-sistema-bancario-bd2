app.get('/transacao', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM transacao
      ORDER BY data_hora DESC
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});