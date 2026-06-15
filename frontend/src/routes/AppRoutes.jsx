import {
  BrowserRouter,
  Routes,
  Route,
  Navigate
} from 'react-router-dom';

import Login from '../pages/Login';

import ClienteDashboard from '../pages/ClienteDashboard';
import Pix from '../pages/Pix';
import Extrato from '../pages/Extrato';

import AdminDashboard from '../pages/AdminDashboard';
import Clientes from '../pages/Clientes';
import Contas from '../pages/Contas';
import Auditoria from '../pages/Auditoria';
import NovoCliente from '../pages/NovoCliente';

export default function AppRoutes() {

  return (
    <BrowserRouter>

      <Routes>

        {/* Login */}
        <Route
          path="/"
          element={<Login />}
        />

        {/* Cliente */}
        <Route
          path="/cliente/dashboard"
          element={<ClienteDashboard />}
        />

        <Route
          path="/cliente/pix"
          element={<Pix />}
        />

        <Route
          path="/cliente/extrato"
          element={<Extrato />}
        />

        {/* Administrador */}
        <Route
          path="/admin/dashboard"
          element={<AdminDashboard />}
        />

        <Route
          path="/admin/clientes"
          element={<Clientes />}
        />

        <Route
          path="/admin/contas"
          element={<Contas />}
        />

        <Route
          path="/admin/auditoria"
          element={<Auditoria />}
        />

        <Route
          path="/admin/clientes/novo"
          element={<NovoCliente />}
        />

        {/* Redirecionamentos */}
        <Route
          path="/admin"
          element={<Navigate to="/admin/dashboard" />}
        />

        <Route
          path="/cliente"
          element={<Navigate to="/cliente/dashboard" />}
        />

        {/* Página não encontrada */}
        <Route
          path="*"
          element={
            <div className="container mt-5">
              <h1>404</h1>
              <p>Página não encontrada.</p>
            </div>
          }
        />

      </Routes>

    </BrowserRouter>
  );
}