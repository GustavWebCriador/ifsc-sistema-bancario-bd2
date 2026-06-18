const mongoose = require('mongoose');

const AuditoriaSchema = new mongoose.Schema({

  usuario: String,

  perfil: String,

  acao: String,

  ip: String,

  dataHora: {
    type: Date,
    default: Date.now
  }

});

module.exports = mongoose.model(
  'Auditoria',
  AuditoriaSchema
);