import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

export default function Pix() {

  const navigate = useNavigate();
  const [pix, setPix] = useState([]);

  const [destino, setDestino] = useState('');
  const [valor, setValor] = useState('');

  useEffect(() => {
    carregarPix();
  }, []);

  async function carregarPix() {

    const idConta =
      localStorage.getItem('id_conta');

    const response =
      await api.get(`/pix/${idConta}`);

    setPix(response.data);
  }

  async function enviarPix(e) {

    e.preventDefault();

    try {

      await api.post('/pix', {
        conta_origem:
          Number(localStorage.getItem('id_conta')),
        destino,
        valor:
          Number(valor)
      });
      alert('PIX enviado com sucesso!');

      setDestino('');
      setValor('');
      carregarPix();

    } catch (error) {

      alert(
        error.response?.data?.erro ||
        'Erro ao realizar PIX'
      );

    }

  }

  return (


    <div className="container mt-4">

      <h1>PIX</h1>

      <div className="mb-3">

        <button
          className="btn btn-secondary"
          onClick={() =>
            navigate('/cliente/dashboard')
          }
        >
          ← Voltar
        </button>

      </div>

      <div className="card p-3 mb-4">

        <h4>Novo PIX</h4>
        <div className="alert alert-info">

          Você pode enviar PIX utilizando:

          <ul className="mb-0 mt-2">
            <li>CPF do destinatário</li>
            <li>Número da conta</li>
          </ul>

        </div>

        <form onSubmit={enviarPix}>

          <input
            className="form-control mb-2"
            placeholder="CPF ou Número da Conta"
            value={destino}
            onChange={(e) =>
              setDestino(e.target.value)
            }
          />

          <input
            type="number"
            step="0.01"
            className="form-control mb-2"
            placeholder="Valor"
            value={valor}
            onChange={(e) =>
              setValor(e.target.value)
            }
          />

          <button
            type="submit"
            className="btn btn-success"
          >
            Enviar PIX
          </button>

        </form>

      </div>

      <h3>Histórico PIX</h3>

      <table className="table">

        <thead>

          <tr>
            <th>ID</th>
            <th>Origem</th>
            <th>Destino</th>
            <th>Valor</th>
          </tr>

        </thead>

        <tbody>

          {pix.map(item => (

            <tr key={item.id_transacao}>

              <td>{item.id_transacao}</td>

              <td>{item.conta_origem}</td>

              <td>{item.conta_destino}</td>

              <td>R$ {item.valor}</td>

            </tr>

          ))}

        </tbody>

      </table>

    </div>

  );

}