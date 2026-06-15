import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

export default function Extrato() {

  const navigate = useNavigate();

  const [extrato, setExtrato] = useState([]);

  useEffect(() => {
    carregarExtrato();
  }, []);

  async function carregarExtrato() {

    try {

      const idCliente =
        localStorage.getItem('id_cliente');

      const response =
        await api.get(
          `/extrato/${idCliente}`
        );

      setExtrato(response.data);

    } catch (error) {

      console.log(error);

    }

  }

  return (
    <div className="container mt-4">

      <div className="d-flex justify-content-between align-items-center mb-4">

        <h1>Extrato</h1>

        <button
          className="btn btn-secondary"
          onClick={() =>
            navigate('/cliente/dashboard')
          }
        >
          ← Voltar
        </button>

      </div>

      <table className="table table-striped">

        <thead>
          <tr>
            <th>Data</th>
            <th>Descrição</th>
            <th>Valor</th>
          </tr>
        </thead>

        <tbody>

          {extrato.map(item => (

            <tr key={item.id_transacao}>

              <td>
                {new Date(
                  item.data_hora
                ).toLocaleDateString('pt-BR')}
              </td>

              <td>
                {item.descricao}
              </td>

              <td
                className={
                  Number(item.valor) >= 0
                    ? 'text-success'
                    : 'text-danger'
                }
              >
                R$ {Number(item.valor).toFixed(2)}
              </td>

            </tr>

          ))}

        </tbody>

      </table>

    </div>
  );
}