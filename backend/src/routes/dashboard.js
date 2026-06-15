app.get('/dashboard', async (req, res) => {
  try {

    const clientes = await pool.query(
      'SELECT COUNT(*) FROM cliente'
    );

    const contas = await pool.query(
      'SELECT COUNT(*) FROM conta'
    );

    const transacoes = await pool.query(
      'SELECT COUNT(*) FROM transacao'
    );

    res.json({
      clientes: clientes.rows[0].count,
      contas: contas.rows[0].count,
      transacoes: transacoes.rows[0].count
    });

  } catch (error) {
    res.status(500).json({
      erro: error.message
    });
  }
});