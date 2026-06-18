require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./database');
const app = express();
const registrarLog =
  require('./middlewares/auditoriaMongo');
const conectarMongo =
  require('./config/mongodb');

conectarMongo();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    sistema: 'Banco Digital',
    status: 'online'
  });
});

app.get('/teste-db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');

    res.json({
      conectado: true,
      data: result.rows[0]
    });

  } catch (error) {
    res.status(500).json({
      conectado: false,
      erro: error.message
    });
  }
});
const jwt = require('jsonwebtoken');

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

    const token = jwt.sign(
      {
        id: usuario.id_usuario,
        perfil: usuario.perfil
      },
      process.env.JWT_SECRET || 'bancodigital',
      {
        expiresIn: '8h'
      }
    );

    // Salva log no Mongo
    await registrarLog(
      usuario.login,
      usuario.perfil,
      'LOGIN',
      req
    );

    res.json({
      token,
      perfil: usuario.perfil,
      id_cliente: usuario.id_cliente
    });

  } catch (error) {

    console.log(error);

    res.status(500).json({
      erro: error.message
    });

  }

});

app.listen(process.env.PORT, () => {
  console.log(`Servidor rodando na porta ${process.env.PORT}`);
});

app.get('/clientes', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM cliente
      ORDER BY id_cliente
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});

app.get('/dashboard', async (req, res) => {
  try {

    const clientes = await pool.query(
      'SELECT COUNT(*) as total FROM cliente'
    );

    const contas = await pool.query(
      'SELECT COUNT(*) as total FROM conta'
    );

    const transacoes = await pool.query(
      'SELECT COUNT(*) as total FROM transacao'
    );

    res.json({
      clientes: clientes.rows[0].total,
      contas: contas.rows[0].total,
      transacoes: transacoes.rows[0].total
    });

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});

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

app.get('/saldo-contas', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM vw_saldo_contas
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
});

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

app.post('/pix', async (req, res) => {

  const {
    conta_origem,
    destino,
    valor
  } = req.body;

  try {

    let contaDestino;

    // CPF
    if (destino.length === 11) {

      const result = await pool.query(`
        SELECT ct.id_conta
        FROM cliente c
        JOIN conta ct
          ON ct.id_cliente = c.id_cliente
        WHERE c.cpf_cnpj = $1
      `, [destino]);

      if (result.rows.length === 0) {

        return res.status(404).json({
          erro: 'CPF não encontrado'
        });

      }

      contaDestino =
        result.rows[0].id_conta;

    } else {

      // Número da conta

      const result = await pool.query(`
        SELECT id_conta
        FROM conta
        WHERE numero_conta = $1
      `, [destino]);

      if (result.rows.length === 0) {

        return res.status(404).json({
          erro: 'Conta não encontrada'
        });

      }

      contaDestino =
        result.rows[0].id_conta;

    }

    await pool.query(
      'CALL sp_pix($1,$2,$3)',
      [
        conta_origem,
        contaDestino,
        valor
      ]
    );

    res.json({
      sucesso: true,
      mensagem: 'PIX realizado'
    });

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }
  await pool.query(
    'CALL sp_pix($1,$2,$3)',
    [
      conta_origem,
      contaDestino,
      valor
    ]
  );

  await registrarLog(
    conta_origem,
    'CLIENTE',
    'PIX_REALIZADO',
    req
  );

});

app.get('/pix', async (req, res) => {
  const result = await pool.query('SELECT * FROM vw_pix');
  res.json(result.rows);
});

app.get('/deposito', (req, res) => {
  res.json({
    mensagem: 'Use POST para realizar depósitos'
  });
});

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
        erro: 'Usuário inválido'
      });

    }

    const usuario = result.rows[0];

    const token = jwt.sign(
      {
        id: usuario.id_usuario,
        perfil: usuario.perfil
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '8h'
      }
    );

    res.json({
      token,
      perfil: usuario.perfil,
      usuario
    });

    await registrarLog(
      usuario.login,
      usuario.perfil,
      'LOGIN',
      req
    );

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});

app.get('/saldo/:idConta', async (req, res) => {

  try {

    const result = await pool.query(
      `
      SELECT
        id_conta,
        numero_conta,
        saldo
      FROM conta
      WHERE id_conta = $1
      `,
      [req.params.idConta]
    );

    res.json(result.rows[0]);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});

app.get('/extrato/:idConta', async (req, res) => {

  try {

    const result = await pool.query(
      `
      SELECT *
      FROM transacao
      WHERE conta_origem = $1
         OR conta_destino = $1
      ORDER BY data_hora DESC
      `,
      [req.params.idConta]
    );

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});

app.post('/clientes-completo', async (req, res) => {

  const client = await pool.connect();

  try {

    await client.query('BEGIN');

    const {
      tipo_cliente,
      nome_razao_social,
      cpf_cnpj,
      email,
      telefone
    } = req.body;

    // Cria cliente
    const clienteResult = await client.query(
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

    const cliente = clienteResult.rows[0];

    // Busca último número de conta
    const contaResult = await client.query(`
  SELECT
      COALESCE(
      MAX(numero_conta::BIGINT),
      100000
    ) AS ultima_conta
      FROM conta
`    );

    const numeroConta =
      Number(contaResult.rows[0].ultima_conta) + 1;

    // Cria conta corrente
    await client.query(
      `
      INSERT INTO conta
      (
        numero_conta,
        tipo_conta,
        saldo,
        data_abertura,
        status,
        id_cliente,
        id_agencia
      )
      VALUES
      (
        $1,
        'CORRENTE',
        0,
        CURRENT_DATE,
        'ATIVA',
        $2,
        1
      )
      `,
      [
        numeroConta,
        cliente.id_cliente
      ]
    );

    // Cria usuário
    await client.query(
      `
      INSERT INTO usuario
      (
        id_cliente,
        login,
        senha,
        perfil
      )
      VALUES
      (
        $1,
        $2,
        '123456',
        'CLIENTE'
      )
      `,
      [
        cliente.id_cliente,
        cpf_cnpj
      ]
    );

    await client.query('COMMIT');

    res.json({
      sucesso: true,
      cliente: cliente.nome_razao_social,
      agencia: '0001',
      conta: numeroConta,
      login: cpf_cnpj,
      senha: '123456'
    });

  } catch (error) {

    await client.query('ROLLBACK');

    res.status(500).json({
      erro: error.message
    });

  } finally {

    client.release();

  }

});

app.get('/cliente/:id', async (req, res) => {

  try {

    const result = await pool.query(`
      SELECT
        c.id_cliente,
        c.nome_razao_social,
        ct.id_conta,
        ct.numero_conta,
        ct.saldo,
        a.numero_agencia
      FROM cliente c
      JOIN conta ct
        ON ct.id_cliente = c.id_cliente
      JOIN agencia a
        ON a.id_agencia = ct.id_agencia
      WHERE c.id_cliente = $1
    `,
      [req.params.id]);

    if (result.rows.length === 0) {

      return res.status(404).json({
        erro: 'Cliente não encontrado'
      });

    }

    res.json(result.rows[0]);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      erro: error.message
    });

  }

});

app.get('/extrato/:idCliente', async (req, res) => {

  console.log('ENTROU NA ROTA EXTRATO');

  try {

    const result = await pool.query(`
      SELECT *
      FROM transacao
      WHERE conta_origem IN (
        SELECT id_conta
        FROM conta
        WHERE id_cliente = $1
      )
      OR conta_destino IN (
        SELECT id_conta
        FROM conta
        WHERE id_cliente = $1
      )
      ORDER BY data_hora DESC
    `,
      [req.params.idCliente]);

    console.log('ID:', req.params.idCliente);
    console.log('TOTAL:', result.rows.length);

    res.json(result.rows);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      erro: error.message
    });

  }

});

app.get('/pix/:idConta', async (req, res) => {

  try {

    const result = await pool.query(`
      SELECT *
      FROM transacao
      WHERE conta_origem = $1
         OR conta_destino = $1
      ORDER BY data_hora DESC
    `,
      [req.params.idConta]);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});

const Auditoria =
require('./models/Auditoria');

app.get('/auditoria-mongo', async (req, res) => {

  try {

    const logs = await Auditoria
      .find()
      .sort({ dataHora: -1 });

    res.json(logs);

  } catch (error) {

    res.status(500).json({
      erro: error.message
    });

  }

});