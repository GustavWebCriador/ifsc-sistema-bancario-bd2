const { MongoClient } = require('mongodb');

const uri = process.env.MONGO_URI;

const client = new MongoClient(uri);

let db;

async function conectarMongo() {

  if (!db) {

    await client.connect();

    db = client.db('banco_digital');

    console.log('MongoDB conectado');

  }

  return db;
}

module.exports = conectarMongo;