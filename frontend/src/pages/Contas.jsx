import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Contas() {

  const [contas, setContas] = useState([]);

  useEffect(() => {
    carregarContas();
  }, []);

  async function carregarContas() {

    const response = await api.get('/contas');

    setContas(response.data);
  }

  return (
    <div className="container mt-4">

      <h1>Contas</h1>

      <table className="table">

        <thead>
          <tr>
            <th>Conta</th>
            <th>Saldo</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>

          {contas.map(conta => (

            <tr key={conta.id_conta}>

              <td>{conta.numero_conta}</td>

              <td>
                R$ {Number(conta.saldo).toFixed(2)}
              </td>

              <td>{conta.status}</td>

            </tr>

          ))}

        </tbody>

      </table>

    </div>
  );
}