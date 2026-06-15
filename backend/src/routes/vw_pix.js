app.get('/vwpix', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM vw_pix
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});