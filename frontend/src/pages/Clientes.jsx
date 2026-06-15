import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Clientes() {

  const [clientes, setClientes] = useState([]);

  useEffect(() => {
    carregarClientes();
  }, []);

  async function carregarClientes() {

    const response = await api.get('/clientes');

    setClientes(response.data);
  }

  return (
    <div className="container mt-4">

      <h1>Clientes</h1>

      <table className="table table-striped">

        <thead>
          <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>CPF/CNPJ</th>
          </tr>
        </thead>

        <tbody>

          {clientes.map(cliente => (

            <tr key={cliente.id_cliente}>

              <td>{cliente.id_cliente}</td>

              <td>{cliente.nome_razao}</td>

              <td>{cliente.cpf_cnpj}</td>

            </tr>

          ))}

        </tbody>

      </table>

    </div>
  );
}