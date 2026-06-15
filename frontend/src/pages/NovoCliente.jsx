import { useState } from 'react';
import api from '../services/api';

export default function NovoCliente() {

  const [tipoCliente, setTipoCliente] = useState('PF');
  const [nome, setNome] = useState('');
  const [cpf, setCpf] = useState('');
  const [email, setEmail] = useState('');
  const [telefone, setTelefone] = useState('');

  async function salvar(e) {

    e.preventDefault();

    try {

const response = await api.post(
  '/clientes-completo',
  {
    tipo_cliente: tipoCliente,
    nome_razao_social: nome,
    cpf_cnpj: cpf,
    email,
    telefone
  }
);

alert(`
Cliente criado com sucesso!

Agência: ${response.data.agencia}
Conta: ${response.data.conta}

Login: ${response.data.login}
Senha Inicial: ${response.data.senha}
`);
      alert(
        `Cliente ${response.data.nome_razao_social} cadastrado com sucesso!`
      );

      setNome('');
      setCpf('');
      setEmail('');
      setTelefone('');

    } catch (error) {

      alert(
        error.response?.data?.erro ||
        'Erro ao cadastrar cliente'
      );

    }

  }

  return (

    <div className="container mt-4">

      <h1>Novo Cliente</h1>

      <div className="card p-4 shadow">

        <form onSubmit={salvar}>

          <div className="mb-3">

            <label>Tipo Cliente</label>

            <select
              className="form-control"
              value={tipoCliente}
              onChange={(e) =>
                setTipoCliente(e.target.value)
              }
            >
              <option value="PF">
                Pessoa Física
              </option>

              <option value="PJ">
                Pessoa Jurídica
              </option>

            </select>

          </div>

          <div className="mb-3">

            <label>Nome / Razão Social</label>

            <input
              className="form-control"
              value={nome}
              onChange={(e) =>
                setNome(e.target.value)
              }
            />

          </div>

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

            <label>Email</label>

            <input
              className="form-control"
              value={email}
              onChange={(e) =>
                setEmail(e.target.value)
              }
            />

          </div>

          <div className="mb-3">

            <label>Telefone</label>

            <input
              className="form-control"
              value={telefone}
              onChange={(e) =>
                setTelefone(e.target.value)
              }
            />

          </div>

          <button
            className="btn btn-success"
            type="submit"
          >
            Salvar Cliente
          </button>

        </form>

      </div>

    </div>

  );

}