app.get('/contas', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM conta
      ORDER BY id_conta
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      erro: error.message
    });
  }
});