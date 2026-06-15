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

      const idConta =
        localStorage.getItem('id_conta');

      const response =
        await api.get(`/extrato/${idConta}`);

      console.log('Extrato:', response.data);

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

          {extrato.length === 0 ? (

            <tr>
              <td
                colSpan="3"
                className="text-center"
              >
                Nenhuma movimentação encontrada.
              </td>
            </tr>

          ) : (

            extrato.map(item => (

              <tr key={item.id_transacao}>

                <td>
                  {new Date(item.data_hora)
                    .toLocaleString('pt-BR')}
                </td>

                <td>
                  {item.descricao}
                </td>

                <td
                  className={
                    item.conta_origem ==
                      localStorage.getItem('id_conta')
                      ? 'text-danger'
                      : 'text-success'
                  }
                >
                  {item.conta_origem ==
                    localStorage.getItem('id_conta')
                    ? '-'
                    : '+'}
                  R$ {Number(item.valor).toFixed(2)}
                </td>

              </tr>

            ))

          )}

        </tbody>

      </table>

    </div>

  );

}