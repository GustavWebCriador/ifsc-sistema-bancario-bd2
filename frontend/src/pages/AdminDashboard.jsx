import { Link } from 'react-router-dom';
import { useEffect, useState } from 'react';
import api from '../services/api';

export default function AdminDashboard() {

  const [dashboard, setDashboard] = useState({
    clientes: 0,
    contas: 0,
    transacoes: 0
  });

  useEffect(() => {
    carregarDashboard();
  }, []);

  async function carregarDashboard() {

    try {

      const response =
        await api.get('/dashboard');

      setDashboard(response.data);

    } catch (error) {

      console.error(error);

    }

  }

  return (

    <div className="container mt-4">

      <h1>Painel Administrativo</h1>

      <div className="row">

        <div className="col-md-4">

          <div className="card p-4 shadow">

            <h4>Clientes</h4>

            <h2>
              {dashboard.clientes}
            </h2>

          </div>

        </div>

        <div className="col-md-4">

          <div className="card p-4 shadow">

            <h4>Contas</h4>

            <h2>
              {dashboard.contas}
            </h2>

          </div>

        </div>

        <div className="col-md-4">

          <div className="card p-4 shadow">

            <h4>Transações</h4>

            <h2>
              {dashboard.transacoes}
            </h2>

          </div>

        </div>

      </div>

      <div className="mt-3 d-flex gap-3">

        <Link
          className="btn btn-primary me-2"
          to="/admin/clientes"
        >
          Clientes
        </Link>

        <Link
          className="btn btn-success me-2"
          to="/admin/contas"
        >
          Contas
        </Link>

        <Link
          className="btn btn-dark"
          to="/admin/auditoria"
        >
          Auditoria Logs
        </Link>

        <Link
          to="/admin/clientes/novo"
          className="btn btn-success me-2"
        >
          Novo Cliente
        </Link>

      </div>

    </div>

  );
}