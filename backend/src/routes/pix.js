const registrarLog =
  require('../middlewares/auditoriaMongo');

app.post('/pix', async (req, res) => {

  const {
    conta_origem,
    chave_pix,
    valor
  } = req.body;

  try {

    await pool.query(
      'CALL sp_pix($1,$2,$3)',
      [conta_origem, chave_pix, valor]
    );

    // REGISTRA NO MONGO
    await registrarLog(
      conta_origem,
      'CLIENTE',
      'PIX_REALIZADO',
      req
    );

    res.json({
      sucesso: true,
      mensagem: 'PIX realizado com sucesso'
    });

  } catch (error) {

    res.status(500).json({
      sucesso: false,
      erro: error.message
    });

  }

});