app.post('/clientes', async (req, res) => {

  const {
    tipo_cliente,
    nome_razao_social,
    cpf_cnpj,
    email,
    telefone
  } = req.body;

  try {

    const result = await pool.query(
      `
      INSERT INTO cliente
      (
        tipo_cliente,
        nome_razao_social,
        cpf_cnpj,
        email,
        telefone
      )
      VALUES
      ($1,$2,$3,$4,$5)
      RETURNING *
      `,
      [
        tipo_cliente,
        nome_razao_social,
        cpf_cnpj,
        email,
        telefone
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});