import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

export default function Login() {

  const navigate = useNavigate();

  const [cpf, setCpf] = useState('');
  const [senha, setSenha] = useState('');

  async function entrar(e) {

    e.preventDefault();

    try {

      const response = await api.post('/login', {
        login: cpf,
        senha
      });
      console.log('LOGIN:', response.data);

      localStorage.setItem(
        'token',
        response.data.token
      );

      localStorage.setItem(
        'perfil',
        response.data.perfil
      );

      localStorage.setItem(
        'id_cliente',
        response.data.id_cliente
      );

    console.log(response.data);

      if (response.data.perfil === 'ADMIN') {

        navigate('/admin/dashboard');

      } else {

        navigate('/cliente/dashboard');

      }

    } catch (error) {

      alert('Usuário ou senha inválidos');

    }

  }

  return (
    <div className="container vh-100 d-flex justify-content-center align-items-center">

      <div className="card p-4 shadow" style={{ width: '400px' }}>

        <h2 className="text-center mb-4">
          Banco Digital
        </h2>

        <form onSubmit={entrar}>

          <div className="mb-3">

            <label>CPF/CNPJ</label>

            <input
              className="form-control"
              value={cpf}
              onChange={(e) =>
                setCpf(e.target.value)
              }
            />

          </div>

          <div className="mb-3">

            <label>Senha</label>

            <input
              type="password"
              className="form-control"
              value={senha}
              onChange={(e) =>
                setSenha(e.target.value)
              }
            />

          </div>

          <button className="btn btn-primary w-100">
            Entrar
          </button>

        </form>

      </div>

    </div>
  );
}