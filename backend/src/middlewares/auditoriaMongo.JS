const Auditoria =
require('../models/Auditoria');

async function registrarLog(
  usuario,
  perfil,
  acao,
  req
) {

  try {

    await Auditoria.create({

      usuario,
      perfil,
      acao,

      ip:
        req.ip ||
        req.connection.remoteAddress,

      dataHora:
        new Date()

    });

  } catch (error) {

    console.log(
      'Erro auditoria:',
      error.message
    );

  }

}

module.exports = registrarLog;

