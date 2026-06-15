app.get('/extrato', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM vw_extrato_conta
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});