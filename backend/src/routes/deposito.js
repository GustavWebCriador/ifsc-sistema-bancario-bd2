app.post('/deposito', async (req, res) => {

  const { id_conta, valor } = req.body;

  try {

    await pool.query(
      'CALL sp_deposito($1,$2)',
      [id_conta, valor]
    );

    res.json({
      sucesso: true,
      mensagem: 'Depósito realizado'
    });

  } catch (error) {

    res.status(500).json({
      sucesso: false,
      erro: error.message
    });

  }

});