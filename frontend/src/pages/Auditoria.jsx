import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Auditoria() {

  const [logs, setLogs] =
    useState([]);

  useEffect(() => {

    carregarLogs();

  }, []);

  async function carregarLogs() {

    try {

      const response =
        await api.get(
          '/auditoria-mongo'
        );

      setLogs(response.data);

    } catch (error) {

      console.log(error);

    }

  }

  return (

    <div className="container mt-4">

      <h1>
        Auditoria Logs de Login
      </h1>

      <table className="table table-striped">

        <thead>

          <tr>
            <th>Data</th>
            <th>Usuário</th>
            <th>Perfil</th>
            <th>Ação</th>
            <th>IP</th>
          </tr>

        </thead>

        <tbody>

          {logs.map(log => (

            <tr key={log._id}>

              <td>
                {new Date(
                  log.dataHora
                ).toLocaleString('pt-BR')}
              </td>

              <td>
                {log.usuario}
              </td>

              <td>
                {log.perfil}
              </td>

              <td>
                {log.acao}
              </td>

              <td>
                {log.ip}
              </td>

            </tr>

          ))}

        </tbody>

      </table>

    </div>

  );

}