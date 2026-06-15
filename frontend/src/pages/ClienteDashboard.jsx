import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';

export default function ClienteDashboard() {

  const [cliente, setCliente] = useState(null);

  useEffect(() => {
    carregarDados();
  }, []);

  async function carregarDados() {

    try {

      const idCliente =
        localStorage.getItem('id_cliente');

      const response =
        await api.get(
          `/cliente/${idCliente}`
        );

      localStorage.setItem(
        'id_conta',
        response.data.id_conta
      );

      setCliente(response.data);

    } catch (error) {

      console.log(error);

    }

  }

  if (!cliente) {

    return (
      <div className="container mt-5">
        Carregando...
      </div>
    );

  }

  return (

    <div className="container mt-4">

      <div className="d-flex justify-content-between align-items-center mb-4">

        <div>

          <h2>
            Olá, {cliente.nome_razao_social}
          </h2>

          <small className="text-muted">
            Bem-vindo ao Banco Digital
          </small>

        </div>

        <button
          className="btn btn-danger"
          onClick={() => {

            localStorage.clear();

            window.location.href = '/';

          }}
        >
          Sair
        </button>

      </div>

      <div className="row">

        <div className="col-md-4 mb-3">

          <div className="card shadow-sm">

            <div className="card-body">

              <h5>Agência</h5>

              <h3>
                {cliente.numero_agencia}
              </h3>

            </div>

          </div>

        </div>

        <div className="col-md-4 mb-3">

          <div className="card shadow-sm">

            <div className="card-body">

              <h5>Conta</h5>

              <h3>
                {cliente.numero_conta}
              </h3>

            </div>

          </div>

        </div>

        <div className="col-md-4 mb-3">

          <div className="card shadow-sm border-success">

            <div className="card-body">

              <h5>Saldo Disponível</h5>

              <h2 className="text-success">

                R$ {Number(cliente.saldo)
                  .toLocaleString(
                    'pt-BR',
                    {
                      minimumFractionDigits: 2
                    }
                  )}

              </h2>

            </div>

          </div>

        </div>

      </div>

      <div className="card mt-4 shadow-sm">

        <div className="card-body">

          <h4>
            Acesso Rápido
          </h4>

          <div className="mt-3">

            <Link
              className="btn btn-primary me-2"
              to="/cliente/pix"
            >
              PIX
            </Link>

            <Link
              className="btn btn-success me-2"
              to="/cliente/extrato"
            >
              Extrato
            </Link>

          </div>

        </div>

      </div>

      <div className="card mt-4 shadow-sm">

        <div className="card-body">

          <h4>
            Dados da Conta
          </h4>

          <table className="table mt-3">

            <tbody>

              <tr>

                <td>
                  Cliente
                </td>

                <td>
                  {cliente.nome_razao_social}
                </td>

              </tr>

              <tr>

                <td>
                  Agência
                </td>

                <td>
                  {cliente.numero_agencia}
                </td>

              </tr>

              <tr>

                <td>
                  Conta
                </td>

                <td>
                  {cliente.numero_conta}
                </td>

              </tr>

              <tr>

                <td>
                  Saldo
                </td>

                <td className="text-success">

                  R$ {Number(cliente.saldo)
                    .toLocaleString(
                      'pt-BR',
                      {
                        minimumFractionDigits: 2
                      }
                    )}

                </td>

              </tr>

            </tbody>

          </table>

        </div>

      </div>

    </div>

  );

}