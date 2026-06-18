app.post('/login', async (req, res) => {

  const { login, senha } = req.body;

  try {

    const result = await pool.query(
      `
      SELECT *
      FROM usuario
      WHERE login = $1
      AND senha = $2
      `,
      [login, senha]
    );

    if (result.rows.length === 0) {

      return res.status(401).json({
        erro: 'Usuário ou senha inválidos'
      });

    }

    const usuario = result.rows[0];

    await registrarLog(
      usuario.login,
      usuario.perfil,
      'LOGIN',
      req
    );

    const token = jwt.sign(
      {
        id: usuario.id_usuario,
        perfil: usuario.perfil
      },
      process.env.JWT_SECRET ||
      'bancodigital',
      {
        expiresIn: '8h'
      }
    );

    res.json({
      token,
      perfil: usuario.perfil,
      id_cliente: usuario.id_cliente
    });

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});