--
-- PostgreSQL database cluster dump
--

-- Started on 2026-06-14 22:39:01

\restrict V7rbiTvRp8r9GkIuWRizCuNtC1FVMBeSTVvEIis0MBm9y4hPHwLcUNAy9MhCCUy

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;

--
-- User Configurations
--








\unrestrict V7rbiTvRp8r9GkIuWRizCuNtC1FVMBeSTVvEIis0MBm9y4hPHwLcUNAy9MhCCUy

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict g0QcqmRhtIy7Y3gueCBnbt6hmUNWYwPg5Cm44gvsobzhveI1TbwYnV2XIx0kbYr

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-14 22:39:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Completed on 2026-06-14 22:39:01

--
-- PostgreSQL database dump complete
--

\unrestrict g0QcqmRhtIy7Y3gueCBnbt6hmUNWYwPg5Cm44gvsobzhveI1TbwYnV2XIx0kbYr

--
-- Database "sistema_bancario" dump
--

--
-- PostgreSQL database dump
--

\restrict sBGedF8Oqp1vR4rcKirfJgAaPrndiuLr75P7jAR2bdf6yXP1KcNtye7dFVsF2LZ

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-14 22:39:02

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5052 (class 1262 OID 24576)
-- Name: sistema_bancario; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE sistema_bancario WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';


ALTER DATABASE sistema_bancario OWNER TO postgres;

\unrestrict sBGedF8Oqp1vR4rcKirfJgAaPrndiuLr75P7jAR2bdf6yXP1KcNtye7dFVsF2LZ
\connect sistema_bancario
\restrict sBGedF8Oqp1vR4rcKirfJgAaPrndiuLr75P7jAR2bdf6yXP1KcNtye7dFVsF2LZ

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 243 (class 1255 OID 24577)
-- Name: fn_auditoria_transacao(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_auditoria_transacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN

    INSERT INTO auditoria (
        tabela_auditada,
        operacao,
        usuario_sistema,
        data_hora,
        detalhes
    )
    VALUES (
        'TRANSACAO',
        'INSERT',
        CURRENT_USER,
        CURRENT_TIMESTAMP,
        'Transacao ID ' || NEW.id_transacao ||
        ' Tipo: ' || NEW.tipo_transacao ||
        ' Valor: R$ ' || NEW.valor
    );

    RETURN NEW;

END;
$_$;


ALTER FUNCTION public.fn_auditoria_transacao() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 24578)
-- Name: sp_deposito(integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_deposito(IN p_id_conta integer, IN p_valor numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE conta
    SET saldo = saldo + p_valor
    WHERE id_conta = p_id_conta;

END;
$$;


ALTER PROCEDURE public.sp_deposito(IN p_id_conta integer, IN p_valor numeric) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 24579)
-- Name: sp_pix(bigint, bigint, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_pix(IN p_conta_origem bigint, IN p_conta_destino bigint, IN p_valor numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_saldo_origem NUMERIC(15,2);
BEGIN

    SELECT saldo
    INTO v_saldo_origem
    FROM conta
    WHERE id_conta = p_conta_origem;

    IF v_saldo_origem < p_valor THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;

    UPDATE conta
    SET saldo = saldo - p_valor
    WHERE id_conta = p_conta_origem;

    UPDATE conta
    SET saldo = saldo + p_valor
    WHERE id_conta = p_conta_destino;

    INSERT INTO transacao (
        tipo_transacao,
        valor,
        data_hora,
        descricao,
        conta_origem,
        conta_destino,
        saldo_anterior,
        saldo_posterior,
        ip_origem
    )
    VALUES (
        'PIX',
        p_valor,
        CURRENT_TIMESTAMP,
        'Transferencia PIX',
        p_conta_origem,
        p_conta_destino,
        v_saldo_origem,
        v_saldo_origem - p_valor,
        '127.0.0.1'
    );

END;
$$;


ALTER PROCEDURE public.sp_pix(IN p_conta_origem bigint, IN p_conta_destino bigint, IN p_valor numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 24580)
-- Name: agencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agencia (
    id_agencia bigint NOT NULL,
    numero_agencia character varying(10) NOT NULL,
    nome_agencia character varying(100) NOT NULL,
    endereco character varying(200),
    cidade character varying(100),
    estado character(2),
    telefone character varying(20)
);


ALTER TABLE public.agencia OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24586)
-- Name: agencia_id_agencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agencia_id_agencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agencia_id_agencia_seq OWNER TO postgres;

--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 220
-- Name: agencia_id_agencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agencia_id_agencia_seq OWNED BY public.agencia.id_agencia;


--
-- TOC entry 221 (class 1259 OID 24587)
-- Name: auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria (
    id_auditoria bigint NOT NULL,
    tabela_auditada character varying(50) NOT NULL,
    operacao character varying(20) NOT NULL,
    usuario_sistema character varying(100),
    data_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    detalhes text
);


ALTER TABLE public.auditoria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24596)
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_id_auditoria_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditoria_id_auditoria_seq OWNER TO postgres;

--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 222
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_id_auditoria_seq OWNED BY public.auditoria.id_auditoria;


--
-- TOC entry 223 (class 1259 OID 24597)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    id_cliente bigint NOT NULL,
    tipo_cliente character varying(2),
    nome_razao_social character varying(150) CONSTRAINT cliente_nomo_razao_social_not_null NOT NULL,
    cpf_cnpj character varying(18) NOT NULL,
    email character varying(150) NOT NULL,
    telefone character varying(20),
    data_cadastro timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24605)
-- Name: cliente_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cliente_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cliente_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 224
-- Name: cliente_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cliente_id_cliente_seq OWNED BY public.cliente.id_cliente;


--
-- TOC entry 225 (class 1259 OID 24606)
-- Name: conta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conta (
    id_conta bigint NOT NULL,
    numero_conta character varying(20) NOT NULL,
    tipo_conta character varying(20) NOT NULL,
    saldo numeric(15,2) DEFAULT 0,
    data_abertura date NOT NULL,
    status character varying(20) NOT NULL,
    id_cliente bigint NOT NULL,
    id_agencia bigint NOT NULL
);


ALTER TABLE public.conta OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24617)
-- Name: conta_id_conta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conta_id_conta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conta_id_conta_seq OWNER TO postgres;

--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 226
-- Name: conta_id_conta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conta_id_conta_seq OWNED BY public.conta.id_conta;


--
-- TOC entry 227 (class 1259 OID 24618)
-- Name: convenio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.convenio (
    id_convenio bigint NOT NULL,
    nome_convenio character varying(100) NOT NULL,
    codigo_convenio character varying(30) NOT NULL,
    tipo_convenio character varying(50),
    status character varying(20) DEFAULT 'ATIVO'::character varying,
    id_conta bigint NOT NULL
);


ALTER TABLE public.convenio OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24626)
-- Name: convenio_id_convenio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.convenio_id_convenio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.convenio_id_convenio_seq OWNER TO postgres;

--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 228
-- Name: convenio_id_convenio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.convenio_id_convenio_seq OWNED BY public.convenio.id_convenio;


--
-- TOC entry 229 (class 1259 OID 24627)
-- Name: endereco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endereco (
    id_endereco bigint NOT NULL,
    id_cliente bigint NOT NULL,
    tipo_endereco character varying(20) NOT NULL,
    logradouro character varying(150) NOT NULL,
    numero character varying(10),
    complemento character varying(100),
    bairro character varying(100),
    cidade character varying(100) NOT NULL,
    estado character(2) NOT NULL,
    cep character varying(9)
);


ALTER TABLE public.endereco OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 24638)
-- Name: endereco_id_endereco_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.endereco_id_endereco_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.endereco_id_endereco_seq OWNER TO postgres;

--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 230
-- Name: endereco_id_endereco_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.endereco_id_endereco_seq OWNED BY public.endereco.id_endereco;


--
-- TOC entry 231 (class 1259 OID 24639)
-- Name: pix_pessoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pix_pessoa (
    id_pix bigint NOT NULL,
    tipo_chave character varying(20) NOT NULL,
    chave_pix character varying(100) NOT NULL,
    data_cadastro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'ATIVA'::character varying,
    id_conta bigint NOT NULL
);


ALTER TABLE public.pix_pessoa OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 24648)
-- Name: pix_pessoa_id_pix_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pix_pessoa_id_pix_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pix_pessoa_id_pix_seq OWNER TO postgres;

--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 232
-- Name: pix_pessoa_id_pix_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pix_pessoa_id_pix_seq OWNED BY public.pix_pessoa.id_pix;


--
-- TOC entry 233 (class 1259 OID 24649)
-- Name: rende_diario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rende_diario (
    id_rendimento bigint NOT NULL,
    data_rendimento date NOT NULL,
    saldo_base numeric(15,2) NOT NULL,
    taxa_rendimento numeric(8,4) NOT NULL,
    valor_rendimento numeric(15,2) NOT NULL,
    id_conta bigint NOT NULL
);


ALTER TABLE public.rende_diario OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 24658)
-- Name: rende_diario_id_rendimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rende_diario_id_rendimento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rende_diario_id_rendimento_seq OWNER TO postgres;

--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 234
-- Name: rende_diario_id_rendimento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rende_diario_id_rendimento_seq OWNED BY public.rende_diario.id_rendimento;


--
-- TOC entry 235 (class 1259 OID 24659)
-- Name: transacao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transacao (
    id_transacao bigint NOT NULL,
    tipo_transacao character varying(30) NOT NULL,
    valor numeric(15,2) NOT NULL,
    data_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    descricao character varying(255),
    conta_origem bigint NOT NULL,
    conta_destino bigint,
    saldo_anterior numeric(15,2),
    saldo_posterior numeric(15,2),
    ip_origem character varying(45)
);


ALTER TABLE public.transacao OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 24667)
-- Name: transacao_id_transacao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transacao_id_transacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transacao_id_transacao_seq OWNER TO postgres;

--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 236
-- Name: transacao_id_transacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transacao_id_transacao_seq OWNED BY public.transacao.id_transacao;


--
-- TOC entry 242 (class 1259 OID 24761)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    id_cliente integer,
    login character varying(100) NOT NULL,
    senha character varying(255) NOT NULL,
    perfil character varying(20) NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 24760)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 241
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 237 (class 1259 OID 24668)
-- Name: vw_extrato_conta; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_extrato_conta AS
 SELECT id_transacao,
    data_hora,
    tipo_transacao,
    valor,
    descricao,
    conta_origem,
    conta_destino
   FROM public.transacao t;


ALTER VIEW public.vw_extrato_conta OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 24672)
-- Name: vw_pagamentos_convenio; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pagamentos_convenio AS
 SELECT id_transacao,
    data_hora,
    conta_origem,
    valor,
    descricao
   FROM public.transacao
  WHERE ((tipo_transacao)::text = 'PAGAMENTO_CONVENIO'::text);


ALTER VIEW public.vw_pagamentos_convenio OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 24676)
-- Name: vw_pix; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pix AS
 SELECT id_transacao,
    data_hora,
    conta_origem,
    conta_destino,
    valor,
    descricao
   FROM public.transacao
  WHERE ((tipo_transacao)::text = 'PIX'::text);


ALTER VIEW public.vw_pix OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 24680)
-- Name: vw_saldo_contas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_saldo_contas AS
 SELECT c.id_conta,
    c.numero_conta,
    cli.nome_razao_social,
    c.tipo_conta,
    c.saldo,
    c.status
   FROM (public.conta c
     JOIN public.cliente cli ON ((cli.id_cliente = c.id_cliente)));


ALTER VIEW public.vw_saldo_contas OWNER TO postgres;

--
-- TOC entry 4819 (class 2604 OID 24684)
-- Name: agencia id_agencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agencia ALTER COLUMN id_agencia SET DEFAULT nextval('public.agencia_id_agencia_seq'::regclass);


--
-- TOC entry 4820 (class 2604 OID 24685)
-- Name: auditoria id_auditoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria ALTER COLUMN id_auditoria SET DEFAULT nextval('public.auditoria_id_auditoria_seq'::regclass);


--
-- TOC entry 4822 (class 2604 OID 24686)
-- Name: cliente id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('public.cliente_id_cliente_seq'::regclass);


--
-- TOC entry 4824 (class 2604 OID 24687)
-- Name: conta id_conta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conta ALTER COLUMN id_conta SET DEFAULT nextval('public.conta_id_conta_seq'::regclass);


--
-- TOC entry 4826 (class 2604 OID 24688)
-- Name: convenio id_convenio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.convenio ALTER COLUMN id_convenio SET DEFAULT nextval('public.convenio_id_convenio_seq'::regclass);


--
-- TOC entry 4828 (class 2604 OID 24689)
-- Name: endereco id_endereco; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco ALTER COLUMN id_endereco SET DEFAULT nextval('public.endereco_id_endereco_seq'::regclass);


--
-- TOC entry 4829 (class 2604 OID 24690)
-- Name: pix_pessoa id_pix; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pix_pessoa ALTER COLUMN id_pix SET DEFAULT nextval('public.pix_pessoa_id_pix_seq'::regclass);


--
-- TOC entry 4832 (class 2604 OID 24691)
-- Name: rende_diario id_rendimento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rende_diario ALTER COLUMN id_rendimento SET DEFAULT nextval('public.rende_diario_id_rendimento_seq'::regclass);


--
-- TOC entry 4833 (class 2604 OID 24692)
-- Name: transacao id_transacao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacao ALTER COLUMN id_transacao SET DEFAULT nextval('public.transacao_id_transacao_seq'::regclass);


--
-- TOC entry 4835 (class 2604 OID 24764)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 5027 (class 0 OID 24580)
-- Dependencies: 219
-- Data for Name: agencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agencia (id_agencia, numero_agencia, nome_agencia, endereco, cidade, estado, telefone) FROM stdin;
1	0001	Agência Principe	Avenida dos Expedicionarios, 2675	Canoinhas	SC	(47)99999-0000
\.


--
-- TOC entry 5029 (class 0 OID 24587)
-- Dependencies: 221
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditoria (id_auditoria, tabela_auditada, operacao, usuario_sistema, data_hora, detalhes) FROM stdin;
1	TRANSACAO	INSERT	postgres	2026-06-08 05:52:16.465932	Transacao ID 72 Tipo: PIX Valor: R$ 50.00
2	TRANSACAO	INSERT	postgres	2026-06-08 05:55:47.562072	Transacao ID 73 Tipo: PIX Valor: R$ 100.00
3	TRANSACAO	INSERT	postgres	2026-06-10 20:52:40.431341	Transacao ID 74 Tipo: PIX Valor: R$ 2.00
4	TRANSACAO	INSERT	postgres	2026-06-10 20:53:13.664898	Transacao ID 75 Tipo: PIX Valor: R$ 50.00
5	TRANSACAO	INSERT	postgres	2026-06-10 20:54:01.150613	Transacao ID 76 Tipo: PIX Valor: R$ 80.00
6	TRANSACAO	INSERT	postgres	2026-06-13 11:15:02.542906	Transacao ID 81 Tipo: PIX Valor: R$ 20.00
7	TRANSACAO	INSERT	postgres	2026-06-14 22:13:50.232145	Transacao ID 83 Tipo: PIX Valor: R$ 5000.00
\.


--
-- TOC entry 5031 (class 0 OID 24597)
-- Dependencies: 223
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cliente (id_cliente, tipo_cliente, nome_razao_social, cpf_cnpj, email, telefone, data_cadastro) FROM stdin;
1	PF	Mauricio Oliveira	22345678910	mau@yahoo.com	47988224894	2026-06-08 00:44:32.05146-03
2	PF	Lais Fernandes	22345678911	lais@email.com	47988224895	2026-06-08 00:44:32.05146-03
3	PF	Manoro Costa	22345678912	manoro@email.com	47988224896	2026-06-08 00:44:32.05146-03
4	PF	Gustavo Ribeiro	22345678913	gustavo@email.com	47988224897	2026-06-08 00:44:32.05146-03
5	PF	Ana Carolina Souza	22345678914	ana@email.com	47988224898	2026-06-08 00:44:32.05146-03
6	PF	Bruno Henrique Martins	22345678915	bruno@email.com	47988224899	2026-06-08 00:44:32.05146-03
7	PF	Carla Mendes	22345678916	carla@email.com	47988224900	2026-06-08 00:44:32.05146-03
8	PF	Daniel Rocha	22345678917	daniel@email.com	47988224901	2026-06-08 00:44:32.05146-03
9	PF	Eduarda Lima	22345678918	eduarda@email.com	47988224902	2026-06-08 00:44:32.05146-03
10	PF	Felipe Costa	22345678919	felipe@email.com	47988224903	2026-06-08 00:44:32.05146-03
11	PF	Gabriela Alves	22345678920	gabriela@email.com	47988224904	2026-06-08 00:44:32.05146-03
12	PF	Henrique Dias	22345678921	henrique@email.com	47988224905	2026-06-08 00:44:32.05146-03
13	PF	Isabela Pereira	22345678922	isabela@email.com	47988224906	2026-06-08 00:44:32.05146-03
14	PF	Joao Ribeiro	22345678923	joao@email.com	47988224907	2026-06-08 00:44:32.05146-03
15	PF	Karen Fernandes	22345678924	karen@email.com	47988224908	2026-06-08 00:44:32.05146-03
16	PF	Leonardo Gomes	22345678925	leonardo@email.com	47988224909	2026-06-08 00:44:32.05146-03
17	PF	Mariana Teixeira	22345678926	mariana@email.com	47988224910	2026-06-08 00:44:32.05146-03
18	PF	Nicolas Cardoso	22345678927	nicolas@email.com	47988224911	2026-06-08 00:44:32.05146-03
19	PF	Olivia Batista	22345678928	olivia@email.com	47988224912	2026-06-08 00:44:32.05146-03
20	PF	Paulo Nunes	22345678929	paulo@email.com	47988224913	2026-06-08 00:44:32.05146-03
21	PJ	Mercado Estrela do Sul LTDA	11222333000101	contato@estreladosul.com	47988225001	2026-06-08 00:44:32.05146-03
22	PJ	Transportadora Rota Brasil LTDA	11222333000102	contato@rotabrasil.com	47988225002	2026-06-08 00:44:32.05146-03
23	PJ	Construtora Horizonte Verde LTDA	11222333000103	contato@horizonteverde.com	47988225003	2026-06-08 00:44:32.05146-03
24	PJ	TechNova Solucoes Digitais LTDA	11222333000104	contato@technova.com	47988225004	2026-06-08 00:44:32.05146-03
25	PJ	AgroVale Agronegocios LTDA	11222333000105	contato@agrovale.com	47988225005	2026-06-08 00:44:32.05146-03
26	PJ	Metal Forte Industria LTDA	11222333000106	contato@metalforte.com	47988225006	2026-06-08 00:44:32.05146-03
27	PJ	Clinica Vida Plena LTDA	11222333000107	contato@vidaplena.com	47988225007	2026-06-08 00:44:32.05146-03
28	PJ	Rede SuperMax LTDA	11222333000108	contato@supermax.com	47988225008	2026-06-08 00:44:32.05146-03
29	PJ	Hotel Serra Imperial LTDA	11222333000109	contato@serraimperial.com	47988225009	2026-06-08 00:44:32.05146-03
30	PJ	Farmacia Bem Estar LTDA	11222333000110	contato@bemestar.com	47988225010	2026-06-08 00:44:32.05146-03
31	PJ	Universidade Serra Sul LTDA	11222333000111	contato@serrasul.com	47988225011	2026-06-08 00:44:32.05146-03
32	PJ	Energia Verde Brasil LTDA	11222333000112	contato@energiaverde.com	47988225012	2026-06-08 00:44:32.05146-03
33	PJ	Posto Bandeirantes LTDA	11222333000113	contato@bandeirantes.com	47988225013	2026-06-08 00:44:32.05146-03
34	PJ	Moveis Elegance LTDA	11222333000114	contato@elegance.com	47988225014	2026-06-08 00:44:32.05146-03
35	PJ	Logistica Expresso Nacional LTDA	11222333000115	contato@expresso.com	47988225015	2026-06-08 00:44:32.05146-03
36	PJ	Cafe Colonial Bella Serra LTDA	11222333000116	contato@bellaserra.com	47988225016	2026-06-08 00:44:32.05146-03
37	PJ	Industria Textil Aurora LTDA	11222333000117	contato@aurora.com	47988225017	2026-06-08 00:44:32.05146-03
38	PJ	Cooperativa Serra Azul LTDA	11222333000118	contato@serraazul.com	47988225018	2026-06-08 00:44:32.05146-03
39	PJ	Auto Center Premium LTDA	11222333000119	contato@autocenter.com	47988225019	2026-06-08 00:44:32.05146-03
40	PJ	Hospital Sao Lucas LTDA	11222333000120	contato@saolucas.com	47988225020	2026-06-08 00:44:32.05146-03
41	PF	Mauricio Oliveira	22345679001	mau@yahoo.com	47988224894	2026-06-08 00:44:33.924577-03
42	PF	Lais Fernandes	22345679002	lais@email.com	47988224895	2026-06-08 00:44:33.924577-03
43	PF	Manoro Costa	22345679003	manoro@email.com	47988224896	2026-06-08 00:44:33.924577-03
44	PF	Gustavo Ribeiro	22345679004	gustavo@email.com	47988224897	2026-06-08 00:44:33.924577-03
45	PF	Ana Carolina Souza	22345679005	ana@email.com	47988224898	2026-06-08 00:44:33.924577-03
46	PF	Bruno Henrique Martins	22345679006	bruno@email.com	47988224899	2026-06-08 00:44:33.924577-03
47	PF	Carla Mendes	22345679007	carla@email.com	47988224900	2026-06-08 00:44:33.924577-03
48	PF	Daniel Rocha	22345679008	daniel@email.com	47988224901	2026-06-08 00:44:33.924577-03
49	PF	Eduarda Lima	22345679009	eduarda@email.com	47988224902	2026-06-08 00:44:33.924577-03
50	PF	Felipe Costa	22345679010	felipe@email.com	47988224903	2026-06-08 00:44:33.924577-03
51	PF	Gabriela Alves	22345679011	gabriela@email.com	47988224904	2026-06-08 00:44:33.924577-03
52	PF	Henrique Dias	22345679012	henrique@email.com	47988224905	2026-06-08 00:44:33.924577-03
53	PF	Isabela Pereira	22345679013	isabela@email.com	47988224906	2026-06-08 00:44:33.924577-03
54	PF	Joao Ribeiro	22345679014	joao@email.com	47988224907	2026-06-08 00:44:33.924577-03
55	PF	Karen Fernandes	22345679015	karen@email.com	47988224908	2026-06-08 00:44:33.924577-03
56	PF	Leonardo Gomes	22345679016	leonardo@email.com	47988224909	2026-06-08 00:44:33.924577-03
57	PF	Mariana Teixeira	22345679017	mariana@email.com	47988224910	2026-06-08 00:44:33.924577-03
58	PF	Nicolas Cardoso	22345679018	nicolas@email.com	47988224911	2026-06-08 00:44:33.924577-03
59	PF	Olivia Batista	22345679019	olivia@email.com	47988224912	2026-06-08 00:44:33.924577-03
60	PF	Paulo Nunes	22345679020	paulo@email.com	47988224913	2026-06-08 00:44:33.924577-03
61	PJ	Mercado Estrela do Sul LTDA	11222333000121	contato@estreladosul.com	47988225001	2026-06-08 00:44:33.924577-03
62	PJ	Transportadora Rota Brasil LTDA	11222333000122	contato@rotabrasil.com	47988225002	2026-06-08 00:44:33.924577-03
63	PJ	Construtora Horizonte Verde LTDA	11222333000123	contato@horizonteverde.com	47988225003	2026-06-08 00:44:33.924577-03
64	PJ	TechNova Solucoes Digitais LTDA	11222333000124	contato@technova.com	47988225004	2026-06-08 00:44:33.924577-03
65	PJ	AgroVale Agronegocios LTDA	11222333000125	contato@agrovale.com	47988225005	2026-06-08 00:44:33.924577-03
66	PJ	Metal Forte Industria LTDA	11222333000126	contato@metalforte.com	47988225006	2026-06-08 00:44:33.924577-03
67	PJ	Clinica Vida Plena LTDA	11222333000127	contato@vidaplena.com	47988225007	2026-06-08 00:44:33.924577-03
68	PJ	Rede SuperMax LTDA	11222333000128	contato@supermax.com	47988225008	2026-06-08 00:44:33.924577-03
69	PJ	Hotel Serra Imperial LTDA	11222333000129	contato@serraimperial.com	47988225009	2026-06-08 00:44:33.924577-03
70	PJ	Farmacia Bem Estar LTDA	11222333000130	contato@bemestar.com	47988225010	2026-06-08 00:44:33.924577-03
71	PJ	Universidade Serra Sul LTDA	11222333000131	contato@serrasul.com	47988225011	2026-06-08 00:44:33.924577-03
72	PJ	Energia Verde Brasil LTDA	11222333000132	contato@energiaverde.com	47988225012	2026-06-08 00:44:33.924577-03
73	PJ	Posto Bandeirantes LTDA	11222333000133	contato@bandeirantes.com	47988225013	2026-06-08 00:44:33.924577-03
74	PJ	Moveis Elegance LTDA	11222333000134	contato@elegance.com	47988225014	2026-06-08 00:44:33.924577-03
75	PJ	Logistica Expresso Nacional LTDA	11222333000135	contato@expresso.com	47988225015	2026-06-08 00:44:33.924577-03
76	PJ	Cafe Colonial Bella Serra LTDA	11222333000136	contato@bellaserra.com	47988225016	2026-06-08 00:44:33.924577-03
77	PJ	Industria Textil Aurora LTDA	11222333000137	contato@aurora.com	47988225017	2026-06-08 00:44:33.924577-03
78	PJ	Cooperativa Serra Azul LTDA	11222333000138	contato@serraazul.com	47988225018	2026-06-08 00:44:33.924577-03
79	PJ	Auto Center Premium LTDA	11222333000139	contato@autocenter.com	47988225019	2026-06-08 00:44:33.924577-03
80	PJ	Hospital Sao Lucas LTDA	11222333000140	contato@saolucas.com	47988225020	2026-06-08 00:44:33.924577-03
85	PF	Rosiana Engel	08383326920	rosiana@gmail.com	1111111111111	2026-06-13 10:01:41.760422-03
86	PF	Gustavo Medeiros	04701846988	ovatsug.luiz@hotmail.com	47984532946	2026-06-14 21:01:08.237927-03
\.


--
-- TOC entry 5033 (class 0 OID 24606)
-- Dependencies: 225
-- Data for Name: conta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conta (id_conta, numero_conta, tipo_conta, saldo, data_abertura, status, id_cliente, id_agencia) FROM stdin;
3	100003	CORRENTE	3738.35	2026-05-09	ATIVA	3	1
4	100004	CORRENTE	14549.58	2026-05-03	ATIVA	4	1
5	100005	CORRENTE	12155.13	2025-06-28	ATIVA	5	1
6	100006	CORRENTE	16563.10	2026-04-07	ATIVA	6	1
7	100007	CORRENTE	8618.15	2025-11-14	ATIVA	7	1
8	100008	CORRENTE	13836.05	2025-12-12	ATIVA	8	1
9	100009	CORRENTE	8880.16	2026-04-16	ATIVA	9	1
10	100010	CORRENTE	14844.00	2025-10-24	ATIVA	10	1
11	100011	CORRENTE	12617.27	2025-06-12	ATIVA	11	1
12	100012	CORRENTE	16956.71	2026-03-04	ATIVA	12	1
13	100013	CORRENTE	13236.89	2025-08-10	ATIVA	13	1
14	100014	CORRENTE	5190.97	2026-02-18	ATIVA	14	1
15	100015	CORRENTE	11230.91	2025-12-26	ATIVA	15	1
16	100016	CORRENTE	9407.14	2026-02-16	ATIVA	16	1
17	100017	CORRENTE	2222.93	2026-05-27	ATIVA	17	1
18	100018	CORRENTE	3316.53	2025-09-03	ATIVA	18	1
19	100019	CORRENTE	17633.52	2025-09-21	ATIVA	19	1
20	100020	CORRENTE	1584.44	2025-09-05	ATIVA	20	1
21	100021	EMPRESARIAL	347811.34	2025-10-23	ATIVA	21	1
22	100022	EMPRESARIAL	464623.68	2025-09-09	ATIVA	22	1
23	100023	EMPRESARIAL	321550.82	2026-04-10	ATIVA	23	1
24	100024	EMPRESARIAL	234804.92	2026-01-05	ATIVA	24	1
25	100025	EMPRESARIAL	478030.38	2025-11-21	ATIVA	25	1
26	100026	EMPRESARIAL	337645.46	2026-04-06	ATIVA	26	1
27	100027	EMPRESARIAL	293122.25	2026-03-23	ATIVA	27	1
28	100028	EMPRESARIAL	408881.65	2026-02-22	ATIVA	28	1
29	100029	EMPRESARIAL	157097.49	2026-02-06	ATIVA	29	1
30	100030	EMPRESARIAL	397542.58	2026-02-14	ATIVA	30	1
31	100031	EMPRESARIAL	153659.77	2026-03-13	ATIVA	31	1
32	100032	EMPRESARIAL	342735.03	2025-08-16	ATIVA	32	1
33	100033	EMPRESARIAL	229875.95	2025-09-12	ATIVA	33	1
34	100034	EMPRESARIAL	121190.89	2025-12-04	ATIVA	34	1
35	100035	EMPRESARIAL	486064.93	2025-07-02	ATIVA	35	1
36	100036	EMPRESARIAL	142332.15	2026-01-06	ATIVA	36	1
37	100037	EMPRESARIAL	245517.22	2025-12-28	ATIVA	37	1
38	100038	EMPRESARIAL	114167.92	2026-05-20	ATIVA	38	1
39	100039	EMPRESARIAL	234658.64	2025-12-25	ATIVA	39	1
40	100040	EMPRESARIAL	471823.94	2025-09-05	ATIVA	40	1
41	100041	CORRENTE	2237.97	2026-02-27	ATIVA	41	1
42	100042	CORRENTE	7068.74	2025-06-24	ATIVA	42	1
43	100043	CORRENTE	8454.99	2026-04-26	ATIVA	43	1
44	100044	CORRENTE	3835.63	2025-12-29	ATIVA	44	1
45	100045	CORRENTE	19885.26	2026-01-19	ATIVA	45	1
46	100046	CORRENTE	15222.21	2026-03-01	ATIVA	46	1
47	100047	CORRENTE	16449.16	2025-11-27	ATIVA	47	1
48	100048	CORRENTE	1183.21	2025-10-29	ATIVA	48	1
49	100049	CORRENTE	14179.05	2025-10-11	ATIVA	49	1
50	100050	CORRENTE	18915.80	2026-02-12	ATIVA	50	1
51	100051	CORRENTE	10627.52	2025-06-18	ATIVA	51	1
52	100052	CORRENTE	14850.65	2026-05-07	ATIVA	52	1
53	100053	CORRENTE	19904.24	2026-01-17	ATIVA	53	1
54	100054	CORRENTE	11344.26	2025-09-30	ATIVA	54	1
55	100055	CORRENTE	5522.12	2025-09-29	ATIVA	55	1
56	100056	CORRENTE	13528.88	2026-03-21	ATIVA	56	1
57	100057	CORRENTE	17693.37	2026-03-23	ATIVA	57	1
58	100058	CORRENTE	9738.71	2025-11-07	ATIVA	58	1
59	100059	CORRENTE	13788.20	2026-04-18	ATIVA	59	1
60	100060	CORRENTE	13458.90	2025-08-29	ATIVA	60	1
61	100061	EMPRESARIAL	208194.57	2025-12-08	ATIVA	61	1
62	100062	EMPRESARIAL	453880.48	2025-12-21	ATIVA	62	1
63	100063	EMPRESARIAL	67792.86	2025-11-16	ATIVA	63	1
64	100064	EMPRESARIAL	294190.55	2026-03-30	ATIVA	64	1
65	100065	EMPRESARIAL	434168.48	2025-06-26	ATIVA	65	1
66	100066	EMPRESARIAL	162198.82	2025-07-28	ATIVA	66	1
67	100067	EMPRESARIAL	266773.39	2026-04-14	ATIVA	67	1
68	100068	EMPRESARIAL	207325.57	2025-08-26	ATIVA	68	1
69	100069	EMPRESARIAL	271171.33	2025-06-27	ATIVA	69	1
70	100070	EMPRESARIAL	70413.58	2026-04-07	ATIVA	70	1
71	100071	EMPRESARIAL	204296.55	2025-08-13	ATIVA	71	1
72	100072	EMPRESARIAL	228451.32	2025-11-22	ATIVA	72	1
73	100073	EMPRESARIAL	424766.33	2025-11-14	ATIVA	73	1
74	100074	EMPRESARIAL	353155.26	2026-02-11	ATIVA	74	1
75	100075	EMPRESARIAL	283167.73	2025-11-09	ATIVA	75	1
76	100076	EMPRESARIAL	313009.46	2026-03-01	ATIVA	76	1
77	100077	EMPRESARIAL	408676.43	2025-06-10	ATIVA	77	1
78	100078	EMPRESARIAL	342035.22	2025-08-09	ATIVA	78	1
79	100079	EMPRESARIAL	390649.57	2025-06-15	ATIVA	79	1
80	100080	EMPRESARIAL	271789.50	2026-01-24	ATIVA	80	1
1	100001	CORRENTE	9293.44	2026-03-27	ATIVA	1	1
2	100002	CORRENTE	12656.90	2025-11-04	ATIVA	2	1
84	100082	CORRENTE	45000.00	2026-06-14	ATIVA	86	1
83	100081	CORRENTE	5000.00	2026-06-13	ATIVA	85	1
\.


--
-- TOC entry 5035 (class 0 OID 24618)
-- Dependencies: 227
-- Data for Name: convenio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.convenio (id_convenio, nome_convenio, codigo_convenio, tipo_convenio, status, id_conta) FROM stdin;
1	CASAN	CV000001	AGUA	ATIVO	1
2	VIVO	CV000002	TELEFONIA	ATIVO	2
3	TIM	CV000003	TELEFONIA	ATIVO	3
4	CLARO	CV000004	TELEFONIA	ATIVO	4
5	OI FIBRA	CV000005	INTERNET	ATIVO	5
6	UNIMED	CV000006	SAUDE	ATIVO	6
7	BB SEGUROS	CV000007	SEGURO	ATIVO	7
8	RECEITA FEDERAL	CV000008	IMPOSTO	ATIVO	8
9	PREFEITURA MUNICIPAL 	CV000009	MUNICIPAL	ATIVO	9
10	CELESC	CV000010	ENERGIA	ATIVO	10
11	CASAN	CV000011	AGUA	ATIVO	11
12	VIVO	CV000012	TELEFONIA	ATIVO	12
13	TIM	CV000013	TELEFONIA	ATIVO	13
14	CLARO	CV000014	TELEFONIA	ATIVO	14
15	OI FIBRA	CV000015	INTERNET	ATIVO	15
16	UNIMED	CV000016	SAUDE	ATIVO	16
17	BB SEGUROS	CV000017	SEGURO	ATIVO	17
18	RECEITA FEDERAL	CV000018	IMPOSTO	ATIVO	18
19	PREFEITURA MUNICIPAL 	CV000019	MUNICIPAL	ATIVO	19
20	CELESC	CV000020	ENERGIA	ATIVO	20
21	CASAN	CV000021	AGUA	ATIVO	21
22	VIVO	CV000022	TELEFONIA	ATIVO	22
23	TIM	CV000023	TELEFONIA	ATIVO	23
24	CLARO	CV000024	TELEFONIA	ATIVO	24
25	OI FIBRA	CV000025	INTERNET	ATIVO	25
26	UNIMED	CV000026	SAUDE	ATIVO	26
27	BB SEGUROS	CV000027	SEGURO	ATIVO	27
28	RECEITA FEDERAL	CV000028	IMPOSTO	ATIVO	28
29	PREFEITURA MUNICIPAL 	CV000029	MUNICIPAL	ATIVO	29
30	CELESC	CV000030	ENERGIA	ATIVO	30
31	CASAN	CV000031	AGUA	ATIVO	31
32	VIVO	CV000032	TELEFONIA	ATIVO	32
33	TIM	CV000033	TELEFONIA	ATIVO	33
34	CLARO	CV000034	TELEFONIA	ATIVO	34
35	OI FIBRA	CV000035	INTERNET	ATIVO	35
36	UNIMED	CV000036	SAUDE	ATIVO	36
37	BB SEGUROS	CV000037	SEGURO	ATIVO	37
38	RECEITA FEDERAL	CV000038	IMPOSTO	ATIVO	38
39	PREFEITURA MUNICIPAL 	CV000039	MUNICIPAL	ATIVO	39
40	CELESC	CV000040	ENERGIA	ATIVO	40
41	CASAN	CV000041	AGUA	ATIVO	41
42	VIVO	CV000042	TELEFONIA	ATIVO	42
43	TIM	CV000043	TELEFONIA	ATIVO	43
44	CLARO	CV000044	TELEFONIA	ATIVO	44
45	OI FIBRA	CV000045	INTERNET	ATIVO	45
46	UNIMED	CV000046	SAUDE	ATIVO	46
47	BB SEGUROS	CV000047	SEGURO	ATIVO	47
48	RECEITA FEDERAL	CV000048	IMPOSTO	ATIVO	48
49	PREFEITURA MUNICIPAL 	CV000049	MUNICIPAL	ATIVO	49
50	CELESC	CV000050	ENERGIA	ATIVO	50
51	CASAN	CV000051	AGUA	ATIVO	51
52	VIVO	CV000052	TELEFONIA	ATIVO	52
53	TIM	CV000053	TELEFONIA	ATIVO	53
54	CLARO	CV000054	TELEFONIA	ATIVO	54
55	OI FIBRA	CV000055	INTERNET	ATIVO	55
56	UNIMED	CV000056	SAUDE	ATIVO	56
57	BB SEGUROS	CV000057	SEGURO	ATIVO	57
58	RECEITA FEDERAL	CV000058	IMPOSTO	ATIVO	58
59	PREFEITURA MUNICIPAL 	CV000059	MUNICIPAL	ATIVO	59
60	CELESC	CV000060	ENERGIA	ATIVO	60
61	CASAN	CV000061	AGUA	ATIVO	61
62	VIVO	CV000062	TELEFONIA	ATIVO	62
63	TIM	CV000063	TELEFONIA	ATIVO	63
64	CLARO	CV000064	TELEFONIA	ATIVO	64
65	OI FIBRA	CV000065	INTERNET	ATIVO	65
66	UNIMED	CV000066	SAUDE	ATIVO	66
67	BB SEGUROS	CV000067	SEGURO	ATIVO	67
68	RECEITA FEDERAL	CV000068	IMPOSTO	ATIVO	68
69	PREFEITURA MUNICIPAL 	CV000069	MUNICIPAL	ATIVO	69
70	CELESC	CV000070	ENERGIA	ATIVO	70
71	CASAN	CV000071	AGUA	ATIVO	71
72	VIVO	CV000072	TELEFONIA	ATIVO	72
73	TIM	CV000073	TELEFONIA	ATIVO	73
74	CLARO	CV000074	TELEFONIA	ATIVO	74
75	OI FIBRA	CV000075	INTERNET	ATIVO	75
76	UNIMED	CV000076	SAUDE	ATIVO	76
77	BB SEGUROS	CV000077	SEGURO	ATIVO	77
78	RECEITA FEDERAL	CV000078	IMPOSTO	ATIVO	78
79	PREFEITURA MUNICIPAL 	CV000079	MUNICIPAL	ATIVO	79
80	CELESC	CV000080	ENERGIA	ATIVO	80
\.


--
-- TOC entry 5037 (class 0 OID 24627)
-- Dependencies: 229
-- Data for Name: endereco; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.endereco (id_endereco, id_cliente, tipo_endereco, logradouro, numero, complemento, bairro, cidade, estado, cep) FROM stdin;
1	1	RESIDENCIAL	Rua das Palmeiras	101	Casa	Centro	Tres Barras	SC	89460-000
2	2	RESIDENCIAL	Rua das Palmeiras	102	Casa	Centro	Bela Vista do Toldo	SC	89460-000
3	3	RESIDENCIAL	Rua das Palmeiras	103	Casa	Centro	Major Vieira	SC	89460-000
4	4	RESIDENCIAL	Rua das Palmeiras	104	Casa	Centro	Canoinhas	SC	89460-000
5	5	RESIDENCIAL	Rua das Palmeiras	105	Casa	Centro	Tres Barras	SC	89460-000
6	6	RESIDENCIAL	Rua das Palmeiras	106	Casa	Centro	Bela Vista do Toldo	SC	89460-000
7	7	RESIDENCIAL	Rua das Palmeiras	107	Casa	Centro	Major Vieira	SC	89460-000
8	8	RESIDENCIAL	Rua das Palmeiras	108	Casa	Centro	Canoinhas	SC	89460-000
9	9	RESIDENCIAL	Rua das Palmeiras	109	Casa	Centro	Tres Barras	SC	89460-000
10	10	RESIDENCIAL	Rua das Palmeiras	110	Casa	Centro	Bela Vista do Toldo	SC	89460-000
11	11	RESIDENCIAL	Rua das Palmeiras	111	Casa	Centro	Major Vieira	SC	89460-000
12	12	RESIDENCIAL	Rua das Palmeiras	112	Casa	Centro	Canoinhas	SC	89460-000
13	13	RESIDENCIAL	Rua das Palmeiras	113	Casa	Centro	Tres Barras	SC	89460-000
14	14	RESIDENCIAL	Rua das Palmeiras	114	Casa	Centro	Bela Vista do Toldo	SC	89460-000
15	15	RESIDENCIAL	Rua das Palmeiras	115	Casa	Centro	Major Vieira	SC	89460-000
16	16	RESIDENCIAL	Rua das Palmeiras	116	Casa	Centro	Canoinhas	SC	89460-000
17	17	RESIDENCIAL	Rua das Palmeiras	117	Casa	Centro	Tres Barras	SC	89460-000
18	18	RESIDENCIAL	Rua das Palmeiras	118	Casa	Centro	Bela Vista do Toldo	SC	89460-000
19	19	RESIDENCIAL	Rua das Palmeiras	119	Casa	Centro	Major Vieira	SC	89460-000
20	20	RESIDENCIAL	Rua das Palmeiras	120	Casa	Centro	Canoinhas	SC	89460-000
21	41	RESIDENCIAL	Rua das Palmeiras	141	Casa	Centro	Tres Barras	SC	89460-000
22	42	RESIDENCIAL	Rua das Palmeiras	142	Casa	Centro	Bela Vista do Toldo	SC	89460-000
23	43	RESIDENCIAL	Rua das Palmeiras	143	Casa	Centro	Major Vieira	SC	89460-000
24	44	RESIDENCIAL	Rua das Palmeiras	144	Casa	Centro	Canoinhas	SC	89460-000
25	45	RESIDENCIAL	Rua das Palmeiras	145	Casa	Centro	Tres Barras	SC	89460-000
26	46	RESIDENCIAL	Rua das Palmeiras	146	Casa	Centro	Bela Vista do Toldo	SC	89460-000
27	47	RESIDENCIAL	Rua das Palmeiras	147	Casa	Centro	Major Vieira	SC	89460-000
28	48	RESIDENCIAL	Rua das Palmeiras	148	Casa	Centro	Canoinhas	SC	89460-000
29	49	RESIDENCIAL	Rua das Palmeiras	149	Casa	Centro	Tres Barras	SC	89460-000
30	50	RESIDENCIAL	Rua das Palmeiras	150	Casa	Centro	Bela Vista do Toldo	SC	89460-000
31	51	RESIDENCIAL	Rua das Palmeiras	151	Casa	Centro	Major Vieira	SC	89460-000
32	52	RESIDENCIAL	Rua das Palmeiras	152	Casa	Centro	Canoinhas	SC	89460-000
33	53	RESIDENCIAL	Rua das Palmeiras	153	Casa	Centro	Tres Barras	SC	89460-000
34	54	RESIDENCIAL	Rua das Palmeiras	154	Casa	Centro	Bela Vista do Toldo	SC	89460-000
35	55	RESIDENCIAL	Rua das Palmeiras	155	Casa	Centro	Major Vieira	SC	89460-000
36	56	RESIDENCIAL	Rua das Palmeiras	156	Casa	Centro	Canoinhas	SC	89460-000
37	57	RESIDENCIAL	Rua das Palmeiras	157	Casa	Centro	Tres Barras	SC	89460-000
38	58	RESIDENCIAL	Rua das Palmeiras	158	Casa	Centro	Bela Vista do Toldo	SC	89460-000
39	59	RESIDENCIAL	Rua das Palmeiras	159	Casa	Centro	Major Vieira	SC	89460-000
40	60	RESIDENCIAL	Rua das Palmeiras	160	Casa	Centro	Canoinhas	SC	89460-000
41	1	RESIDENCIAL	Rua das Palmeiras	101	Casa	Centro	Tres Barras	SC	89460-000
42	2	RESIDENCIAL	Rua das Palmeiras	102	Casa	Centro	Bela Vista do Toldo	SC	89460-000
43	3	RESIDENCIAL	Rua das Palmeiras	103	Casa	Centro	Major Vieira	SC	89460-000
44	4	RESIDENCIAL	Rua das Palmeiras	104	Casa	Centro	Canoinhas	SC	89460-000
45	5	RESIDENCIAL	Rua das Palmeiras	105	Casa	Centro	Tres Barras	SC	89460-000
46	6	RESIDENCIAL	Rua das Palmeiras	106	Casa	Centro	Bela Vista do Toldo	SC	89460-000
47	7	RESIDENCIAL	Rua das Palmeiras	107	Casa	Centro	Major Vieira	SC	89460-000
48	8	RESIDENCIAL	Rua das Palmeiras	108	Casa	Centro	Canoinhas	SC	89460-000
49	9	RESIDENCIAL	Rua das Palmeiras	109	Casa	Centro	Tres Barras	SC	89460-000
50	10	RESIDENCIAL	Rua das Palmeiras	110	Casa	Centro	Bela Vista do Toldo	SC	89460-000
51	11	RESIDENCIAL	Rua das Palmeiras	111	Casa	Centro	Major Vieira	SC	89460-000
52	12	RESIDENCIAL	Rua das Palmeiras	112	Casa	Centro	Canoinhas	SC	89460-000
53	13	RESIDENCIAL	Rua das Palmeiras	113	Casa	Centro	Tres Barras	SC	89460-000
54	14	RESIDENCIAL	Rua das Palmeiras	114	Casa	Centro	Bela Vista do Toldo	SC	89460-000
55	15	RESIDENCIAL	Rua das Palmeiras	115	Casa	Centro	Major Vieira	SC	89460-000
56	16	RESIDENCIAL	Rua das Palmeiras	116	Casa	Centro	Canoinhas	SC	89460-000
57	17	RESIDENCIAL	Rua das Palmeiras	117	Casa	Centro	Tres Barras	SC	89460-000
58	18	RESIDENCIAL	Rua das Palmeiras	118	Casa	Centro	Bela Vista do Toldo	SC	89460-000
59	19	RESIDENCIAL	Rua das Palmeiras	119	Casa	Centro	Major Vieira	SC	89460-000
60	20	RESIDENCIAL	Rua das Palmeiras	120	Casa	Centro	Canoinhas	SC	89460-000
61	41	RESIDENCIAL	Rua das Palmeiras	141	Casa	Centro	Tres Barras	SC	89460-000
62	42	RESIDENCIAL	Rua das Palmeiras	142	Casa	Centro	Bela Vista do Toldo	SC	89460-000
63	43	RESIDENCIAL	Rua das Palmeiras	143	Casa	Centro	Major Vieira	SC	89460-000
64	44	RESIDENCIAL	Rua das Palmeiras	144	Casa	Centro	Canoinhas	SC	89460-000
65	45	RESIDENCIAL	Rua das Palmeiras	145	Casa	Centro	Tres Barras	SC	89460-000
66	46	RESIDENCIAL	Rua das Palmeiras	146	Casa	Centro	Bela Vista do Toldo	SC	89460-000
67	47	RESIDENCIAL	Rua das Palmeiras	147	Casa	Centro	Major Vieira	SC	89460-000
68	48	RESIDENCIAL	Rua das Palmeiras	148	Casa	Centro	Canoinhas	SC	89460-000
69	49	RESIDENCIAL	Rua das Palmeiras	149	Casa	Centro	Tres Barras	SC	89460-000
70	50	RESIDENCIAL	Rua das Palmeiras	150	Casa	Centro	Bela Vista do Toldo	SC	89460-000
71	51	RESIDENCIAL	Rua das Palmeiras	151	Casa	Centro	Major Vieira	SC	89460-000
72	52	RESIDENCIAL	Rua das Palmeiras	152	Casa	Centro	Canoinhas	SC	89460-000
73	53	RESIDENCIAL	Rua das Palmeiras	153	Casa	Centro	Tres Barras	SC	89460-000
74	54	RESIDENCIAL	Rua das Palmeiras	154	Casa	Centro	Bela Vista do Toldo	SC	89460-000
75	55	RESIDENCIAL	Rua das Palmeiras	155	Casa	Centro	Major Vieira	SC	89460-000
76	56	RESIDENCIAL	Rua das Palmeiras	156	Casa	Centro	Canoinhas	SC	89460-000
77	57	RESIDENCIAL	Rua das Palmeiras	157	Casa	Centro	Tres Barras	SC	89460-000
78	58	RESIDENCIAL	Rua das Palmeiras	158	Casa	Centro	Bela Vista do Toldo	SC	89460-000
79	59	RESIDENCIAL	Rua das Palmeiras	159	Casa	Centro	Major Vieira	SC	89460-000
80	60	RESIDENCIAL	Rua das Palmeiras	160	Casa	Centro	Canoinhas	SC	89460-000
81	1	COMERCIAL	Avenida dos Comerciarios	501	Sala 01	Centro	Tres Barras	SC	89460-000
82	2	COMERCIAL	Avenida dos Comerciarios	502	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
83	3	COMERCIAL	Avenida dos Comerciarios	503	Sala 01	Centro	Major Vieira	SC	89460-000
84	4	COMERCIAL	Avenida dos Comerciarios	504	Sala 01	Centro	Canoinhas	SC	89460-000
85	5	COMERCIAL	Avenida dos Comerciarios	505	Sala 01	Centro	Tres Barras	SC	89460-000
86	6	COMERCIAL	Avenida dos Comerciarios	506	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
87	7	COMERCIAL	Avenida dos Comerciarios	507	Sala 01	Centro	Major Vieira	SC	89460-000
88	8	COMERCIAL	Avenida dos Comerciarios	508	Sala 01	Centro	Canoinhas	SC	89460-000
89	9	COMERCIAL	Avenida dos Comerciarios	509	Sala 01	Centro	Tres Barras	SC	89460-000
90	10	COMERCIAL	Avenida dos Comerciarios	510	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
91	11	COMERCIAL	Avenida dos Comerciarios	511	Sala 01	Centro	Major Vieira	SC	89460-000
92	12	COMERCIAL	Avenida dos Comerciarios	512	Sala 01	Centro	Canoinhas	SC	89460-000
93	13	COMERCIAL	Avenida dos Comerciarios	513	Sala 01	Centro	Tres Barras	SC	89460-000
94	14	COMERCIAL	Avenida dos Comerciarios	514	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
95	15	COMERCIAL	Avenida dos Comerciarios	515	Sala 01	Centro	Major Vieira	SC	89460-000
96	16	COMERCIAL	Avenida dos Comerciarios	516	Sala 01	Centro	Canoinhas	SC	89460-000
97	17	COMERCIAL	Avenida dos Comerciarios	517	Sala 01	Centro	Tres Barras	SC	89460-000
98	18	COMERCIAL	Avenida dos Comerciarios	518	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
99	19	COMERCIAL	Avenida dos Comerciarios	519	Sala 01	Centro	Major Vieira	SC	89460-000
100	20	COMERCIAL	Avenida dos Comerciarios	520	Sala 01	Centro	Canoinhas	SC	89460-000
101	41	COMERCIAL	Avenida dos Comerciarios	541	Sala 01	Centro	Tres Barras	SC	89460-000
102	42	COMERCIAL	Avenida dos Comerciarios	542	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
103	43	COMERCIAL	Avenida dos Comerciarios	543	Sala 01	Centro	Major Vieira	SC	89460-000
104	44	COMERCIAL	Avenida dos Comerciarios	544	Sala 01	Centro	Canoinhas	SC	89460-000
105	45	COMERCIAL	Avenida dos Comerciarios	545	Sala 01	Centro	Tres Barras	SC	89460-000
106	46	COMERCIAL	Avenida dos Comerciarios	546	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
107	47	COMERCIAL	Avenida dos Comerciarios	547	Sala 01	Centro	Major Vieira	SC	89460-000
108	48	COMERCIAL	Avenida dos Comerciarios	548	Sala 01	Centro	Canoinhas	SC	89460-000
109	49	COMERCIAL	Avenida dos Comerciarios	549	Sala 01	Centro	Tres Barras	SC	89460-000
110	50	COMERCIAL	Avenida dos Comerciarios	550	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
111	51	COMERCIAL	Avenida dos Comerciarios	551	Sala 01	Centro	Major Vieira	SC	89460-000
112	52	COMERCIAL	Avenida dos Comerciarios	552	Sala 01	Centro	Canoinhas	SC	89460-000
113	53	COMERCIAL	Avenida dos Comerciarios	553	Sala 01	Centro	Tres Barras	SC	89460-000
114	54	COMERCIAL	Avenida dos Comerciarios	554	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
115	55	COMERCIAL	Avenida dos Comerciarios	555	Sala 01	Centro	Major Vieira	SC	89460-000
116	56	COMERCIAL	Avenida dos Comerciarios	556	Sala 01	Centro	Canoinhas	SC	89460-000
117	57	COMERCIAL	Avenida dos Comerciarios	557	Sala 01	Centro	Tres Barras	SC	89460-000
118	58	COMERCIAL	Avenida dos Comerciarios	558	Sala 01	Centro	Bela Vista do Toldo	SC	89460-000
119	59	COMERCIAL	Avenida dos Comerciarios	559	Sala 01	Centro	Major Vieira	SC	89460-000
120	60	COMERCIAL	Avenida dos Comerciarios	560	Sala 01	Centro	Canoinhas	SC	89460-000
\.


--
-- TOC entry 5039 (class 0 OID 24639)
-- Dependencies: 231
-- Data for Name: pix_pessoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pix_pessoa (id_pix, tipo_chave, chave_pix, data_cadastro, status, id_conta) FROM stdin;
1	CPF	22345678910	2026-06-08 05:07:05.750121	ATIVA	1
2	CPF	22345678911	2026-06-08 05:07:05.750121	ATIVA	2
3	CPF	22345678912	2026-06-08 05:07:05.750121	ATIVA	3
4	CPF	22345678913	2026-06-08 05:07:05.750121	ATIVA	4
5	CPF	22345678914	2026-06-08 05:07:05.750121	ATIVA	5
6	CPF	22345678915	2026-06-08 05:07:05.750121	ATIVA	6
7	CPF	22345678916	2026-06-08 05:07:05.750121	ATIVA	7
8	CPF	22345678917	2026-06-08 05:07:05.750121	ATIVA	8
9	CPF	22345678918	2026-06-08 05:07:05.750121	ATIVA	9
10	CPF	22345678919	2026-06-08 05:07:05.750121	ATIVA	10
11	CPF	22345678920	2026-06-08 05:07:05.750121	ATIVA	11
12	CPF	22345678921	2026-06-08 05:07:05.750121	ATIVA	12
13	CPF	22345678922	2026-06-08 05:07:05.750121	ATIVA	13
14	CPF	22345678923	2026-06-08 05:07:05.750121	ATIVA	14
15	CPF	22345678924	2026-06-08 05:07:05.750121	ATIVA	15
16	CPF	22345678925	2026-06-08 05:07:05.750121	ATIVA	16
17	CPF	22345678926	2026-06-08 05:07:05.750121	ATIVA	17
18	CPF	22345678927	2026-06-08 05:07:05.750121	ATIVA	18
19	CPF	22345678928	2026-06-08 05:07:05.750121	ATIVA	19
20	CPF	22345678929	2026-06-08 05:07:05.750121	ATIVA	20
21	CNPJ	11222333000101	2026-06-08 05:07:05.750121	ATIVA	21
22	CNPJ	11222333000102	2026-06-08 05:07:05.750121	ATIVA	22
23	CNPJ	11222333000103	2026-06-08 05:07:05.750121	ATIVA	23
24	CNPJ	11222333000104	2026-06-08 05:07:05.750121	ATIVA	24
25	CNPJ	11222333000105	2026-06-08 05:07:05.750121	ATIVA	25
26	CNPJ	11222333000106	2026-06-08 05:07:05.750121	ATIVA	26
27	CNPJ	11222333000107	2026-06-08 05:07:05.750121	ATIVA	27
28	CNPJ	11222333000108	2026-06-08 05:07:05.750121	ATIVA	28
29	CNPJ	11222333000109	2026-06-08 05:07:05.750121	ATIVA	29
30	CNPJ	11222333000110	2026-06-08 05:07:05.750121	ATIVA	30
31	CNPJ	11222333000111	2026-06-08 05:07:05.750121	ATIVA	31
32	CNPJ	11222333000112	2026-06-08 05:07:05.750121	ATIVA	32
33	CNPJ	11222333000113	2026-06-08 05:07:05.750121	ATIVA	33
34	CNPJ	11222333000114	2026-06-08 05:07:05.750121	ATIVA	34
35	CNPJ	11222333000115	2026-06-08 05:07:05.750121	ATIVA	35
36	CNPJ	11222333000116	2026-06-08 05:07:05.750121	ATIVA	36
37	CNPJ	11222333000117	2026-06-08 05:07:05.750121	ATIVA	37
38	CNPJ	11222333000118	2026-06-08 05:07:05.750121	ATIVA	38
39	CNPJ	11222333000119	2026-06-08 05:07:05.750121	ATIVA	39
40	CNPJ	11222333000120	2026-06-08 05:07:05.750121	ATIVA	40
41	CPF	22345679001	2026-06-08 05:07:05.750121	ATIVA	41
42	CPF	22345679002	2026-06-08 05:07:05.750121	ATIVA	42
43	CPF	22345679003	2026-06-08 05:07:05.750121	ATIVA	43
44	CPF	22345679004	2026-06-08 05:07:05.750121	ATIVA	44
45	CPF	22345679005	2026-06-08 05:07:05.750121	ATIVA	45
46	CPF	22345679006	2026-06-08 05:07:05.750121	ATIVA	46
47	CPF	22345679007	2026-06-08 05:07:05.750121	ATIVA	47
48	CPF	22345679008	2026-06-08 05:07:05.750121	ATIVA	48
49	CPF	22345679009	2026-06-08 05:07:05.750121	ATIVA	49
50	CPF	22345679010	2026-06-08 05:07:05.750121	ATIVA	50
51	CPF	22345679011	2026-06-08 05:07:05.750121	ATIVA	51
52	CPF	22345679012	2026-06-08 05:07:05.750121	ATIVA	52
53	CPF	22345679013	2026-06-08 05:07:05.750121	ATIVA	53
54	CPF	22345679014	2026-06-08 05:07:05.750121	ATIVA	54
55	CPF	22345679015	2026-06-08 05:07:05.750121	ATIVA	55
56	CPF	22345679016	2026-06-08 05:07:05.750121	ATIVA	56
57	CPF	22345679017	2026-06-08 05:07:05.750121	ATIVA	57
58	CPF	22345679018	2026-06-08 05:07:05.750121	ATIVA	58
59	CPF	22345679019	2026-06-08 05:07:05.750121	ATIVA	59
60	CPF	22345679020	2026-06-08 05:07:05.750121	ATIVA	60
61	CNPJ	11222333000121	2026-06-08 05:07:05.750121	ATIVA	61
62	CNPJ	11222333000122	2026-06-08 05:07:05.750121	ATIVA	62
63	CNPJ	11222333000123	2026-06-08 05:07:05.750121	ATIVA	63
64	CNPJ	11222333000124	2026-06-08 05:07:05.750121	ATIVA	64
65	CNPJ	11222333000125	2026-06-08 05:07:05.750121	ATIVA	65
66	CNPJ	11222333000126	2026-06-08 05:07:05.750121	ATIVA	66
67	CNPJ	11222333000127	2026-06-08 05:07:05.750121	ATIVA	67
68	CNPJ	11222333000128	2026-06-08 05:07:05.750121	ATIVA	68
69	CNPJ	11222333000129	2026-06-08 05:07:05.750121	ATIVA	69
70	CNPJ	11222333000130	2026-06-08 05:07:05.750121	ATIVA	70
71	CNPJ	11222333000131	2026-06-08 05:07:05.750121	ATIVA	71
72	CNPJ	11222333000132	2026-06-08 05:07:05.750121	ATIVA	72
73	CNPJ	11222333000133	2026-06-08 05:07:05.750121	ATIVA	73
74	CNPJ	11222333000134	2026-06-08 05:07:05.750121	ATIVA	74
75	CNPJ	11222333000135	2026-06-08 05:07:05.750121	ATIVA	75
76	CNPJ	11222333000136	2026-06-08 05:07:05.750121	ATIVA	76
77	CNPJ	11222333000137	2026-06-08 05:07:05.750121	ATIVA	77
78	CNPJ	11222333000138	2026-06-08 05:07:05.750121	ATIVA	78
79	CNPJ	11222333000139	2026-06-08 05:07:05.750121	ATIVA	79
80	CNPJ	11222333000140	2026-06-08 05:07:05.750121	ATIVA	80
\.


--
-- TOC entry 5041 (class 0 OID 24649)
-- Dependencies: 233
-- Data for Name: rende_diario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rende_diario (id_rendimento, data_rendimento, saldo_base, taxa_rendimento, valor_rendimento, id_conta) FROM stdin;
\.


--
-- TOC entry 5043 (class 0 OID 24659)
-- Dependencies: 235
-- Data for Name: transacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transacao (id_transacao, tipo_transacao, valor, data_hora, descricao, conta_origem, conta_destino, saldo_anterior, saldo_posterior, ip_origem) FROM stdin;
1	PIX	150.00	2026-06-08 05:20:41.788834	PIX Conta 1 para Conta 2	1	2	3413.44	3263.44	192.168.1.10
2	PIX	300.00	2026-06-08 05:20:41.788834	PIX Conta 2 para Conta 3	2	3	12536.90	12236.90	192.168.1.11
3	PIX	200.00	2026-06-08 05:20:41.788834	PIX Conta 3 para Conta 4	3	4	3738.35	3538.35	192.168.1.12
4	PIX	500.00	2026-06-08 05:20:41.788834	PIX Conta 4 para Conta 5	4	5	14549.58	14049.58	192.168.1.13
5	PIX	250.00	2026-06-08 05:20:41.788834	PIX Conta 5 para Conta 6	5	6	12155.13	11905.13	192.168.1.14
6	PIX	400.00	2026-06-08 05:20:41.788834	PIX Conta 6 para Conta 7	6	7	16563.10	16163.10	192.168.1.15
7	PIX	175.00	2026-06-08 05:20:41.788834	PIX Conta 7 para Conta 8	7	8	8618.15	8443.15	192.168.1.16
8	PIX	220.00	2026-06-08 05:20:41.788834	PIX Conta 8 para Conta 9	8	9	13836.05	13616.05	192.168.1.17
9	PIX	180.00	2026-06-08 05:20:41.788834	PIX Conta 9 para Conta 10	9	10	8880.16	8700.16	192.168.1.18
10	PIX	350.00	2026-06-08 05:20:41.788834	PIX Conta 10 para Conta 1	10	1	14844.00	14494.00	192.168.1.19
11	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	1	\N	3413.44	3344.94	192.168.0.100
12	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	2	\N	12536.90	12468.40	192.168.0.100
13	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	3	\N	3738.35	3669.85	192.168.0.100
14	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	4	\N	14549.58	14481.08	192.168.0.100
15	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	5	\N	12155.13	12086.63	192.168.0.100
16	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	6	\N	16563.10	16494.60	192.168.0.100
17	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	7	\N	8618.15	8549.65	192.168.0.100
18	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	8	\N	13836.05	13767.55	192.168.0.100
19	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	9	\N	8880.16	8811.66	192.168.0.100
20	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	10	\N	14844.00	14775.50	192.168.0.100
21	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	11	\N	12617.27	12548.77	192.168.0.100
22	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	12	\N	16956.71	16888.21	192.168.0.100
23	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	13	\N	13236.89	13168.39	192.168.0.100
24	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	14	\N	5190.97	5122.47	192.168.0.100
25	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	15	\N	11230.91	11162.41	192.168.0.100
26	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	16	\N	9407.14	9338.64	192.168.0.100
27	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	17	\N	2222.93	2154.43	192.168.0.100
28	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	18	\N	3316.53	3248.03	192.168.0.100
29	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	19	\N	17633.52	17565.02	192.168.0.100
30	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	20	\N	1584.44	1515.94	192.168.0.100
31	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	21	\N	347811.34	347742.84	192.168.0.100
32	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	22	\N	464623.68	464555.18	192.168.0.100
33	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	23	\N	321550.82	321482.32	192.168.0.100
34	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	24	\N	234804.92	234736.42	192.168.0.100
35	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	25	\N	478030.38	477961.88	192.168.0.100
36	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	26	\N	337645.46	337576.96	192.168.0.100
37	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	27	\N	293122.25	293053.75	192.168.0.100
38	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	28	\N	408881.65	408813.15	192.168.0.100
39	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	29	\N	157097.49	157028.99	192.168.0.100
40	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	30	\N	397542.58	397474.08	192.168.0.100
41	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	31	\N	153659.77	153591.27	192.168.0.100
42	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	32	\N	342735.03	342666.53	192.168.0.100
43	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	33	\N	229875.95	229807.45	192.168.0.100
44	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	34	\N	121190.89	121122.39	192.168.0.100
45	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	35	\N	486064.93	485996.43	192.168.0.100
46	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	36	\N	142332.15	142263.65	192.168.0.100
47	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	37	\N	245517.22	245448.72	192.168.0.100
48	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	38	\N	114167.92	114099.42	192.168.0.100
49	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	39	\N	234658.64	234590.14	192.168.0.100
50	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	40	\N	471823.94	471755.44	192.168.0.100
51	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	41	\N	2237.97	2169.47	192.168.0.100
52	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	42	\N	7068.74	7000.24	192.168.0.100
53	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	43	\N	8454.99	8386.49	192.168.0.100
54	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	44	\N	3835.63	3767.13	192.168.0.100
55	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	45	\N	19885.26	19816.76	192.168.0.100
56	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	46	\N	15222.21	15153.71	192.168.0.100
57	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	47	\N	16449.16	16380.66	192.168.0.100
58	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	48	\N	1183.21	1114.71	192.168.0.100
59	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	49	\N	14179.05	14110.55	192.168.0.100
60	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	50	\N	18915.80	18847.30	192.168.0.100
61	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	51	\N	10627.52	10559.02	192.168.0.100
62	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	52	\N	14850.65	14782.15	192.168.0.100
63	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	53	\N	19904.24	19835.74	192.168.0.100
64	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	54	\N	11344.26	11275.76	192.168.0.100
65	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	55	\N	5522.12	5453.62	192.168.0.100
66	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	56	\N	13528.88	13460.38	192.168.0.100
67	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	57	\N	17693.37	17624.87	192.168.0.100
68	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	58	\N	9738.71	9670.21	192.168.0.100
69	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	59	\N	13788.20	13719.70	192.168.0.100
70	PAGAMENTO_CONVENIO	68.50	2026-06-08 05:31:14.735093	Taxa de Lixo - Prefeitura Municipal	60	\N	13458.90	13390.40	192.168.0.100
71	PIX	100.00	2026-06-08 05:48:48.916701	Teste PIX	1	2	3413.44	3313.44	192.168.1.10
72	PIX	50.00	2026-06-08 05:52:16.465932	Teste Auditoria	1	2	3413.44	3363.44	192.168.1.50
73	PIX	100.00	2026-06-08 05:55:47.562072	Transferencia PIX	1	2	3913.44	3813.44	127.0.0.1
74	PIX	2.00	2026-06-10 20:52:40.431341	Transferencia PIX	1	1	9313.44	9311.44	127.0.0.1
75	PIX	50.00	2026-06-10 20:53:13.664898	Transferencia PIX	1	1	9313.44	9263.44	127.0.0.1
76	PIX	80.00	2026-06-10 20:54:01.150613	Transferencia PIX	1	1	9313.44	9233.44	127.0.0.1
81	PIX	20.00	2026-06-13 11:15:02.542906	Transferencia PIX	1	2	9313.44	9293.44	127.0.0.1
83	PIX	5000.00	2026-06-14 22:13:50.232145	Transferencia PIX	84	83	50000.00	45000.00	127.0.0.1
\.


--
-- TOC entry 5046 (class 0 OID 24761)
-- Dependencies: 242
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, id_cliente, login, senha, perfil) FROM stdin;
1	\N	admin	123456	ADMIN
2	1	11111111111	123456	CLIENTE
3	85	08383326920	123456	CLIENTE
4	86	04701846988	123456	CLIENTE
\.


--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 220
-- Name: agencia_id_agencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agencia_id_agencia_seq', 1, true);


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 222
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_id_auditoria_seq', 7, true);


--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 224
-- Name: cliente_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_id_cliente_seq', 86, true);


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 226
-- Name: conta_id_conta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conta_id_conta_seq', 84, true);


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 228
-- Name: convenio_id_convenio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.convenio_id_convenio_seq', 80, true);


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 230
-- Name: endereco_id_endereco_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.endereco_id_endereco_seq', 436, true);


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 232
-- Name: pix_pessoa_id_pix_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pix_pessoa_id_pix_seq', 80, true);


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 234
-- Name: rende_diario_id_rendimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rende_diario_id_rendimento_seq', 1, false);


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 236
-- Name: transacao_id_transacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transacao_id_transacao_seq', 83, true);


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 241
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 4, true);


--
-- TOC entry 4837 (class 2606 OID 24694)
-- Name: agencia agencia_numero_agencia_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agencia
    ADD CONSTRAINT agencia_numero_agencia_key UNIQUE (numero_agencia);


--
-- TOC entry 4839 (class 2606 OID 24696)
-- Name: agencia agencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agencia
    ADD CONSTRAINT agencia_pkey PRIMARY KEY (id_agencia);


--
-- TOC entry 4841 (class 2606 OID 24698)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id_auditoria);


--
-- TOC entry 4843 (class 2606 OID 24700)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4845 (class 2606 OID 24702)
-- Name: conta conta_numero_conta_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conta
    ADD CONSTRAINT conta_numero_conta_key UNIQUE (numero_conta);


--
-- TOC entry 4847 (class 2606 OID 24704)
-- Name: conta conta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conta
    ADD CONSTRAINT conta_pkey PRIMARY KEY (id_conta);


--
-- TOC entry 4849 (class 2606 OID 24706)
-- Name: convenio convenio_codigo_convenio_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.convenio
    ADD CONSTRAINT convenio_codigo_convenio_key UNIQUE (codigo_convenio);


--
-- TOC entry 4851 (class 2606 OID 24708)
-- Name: convenio convenio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.convenio
    ADD CONSTRAINT convenio_pkey PRIMARY KEY (id_convenio);


--
-- TOC entry 4853 (class 2606 OID 24710)
-- Name: endereco endereco_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT endereco_pkey PRIMARY KEY (id_endereco);


--
-- TOC entry 4855 (class 2606 OID 24712)
-- Name: pix_pessoa pix_pessoa_chave_pix_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pix_pessoa
    ADD CONSTRAINT pix_pessoa_chave_pix_key UNIQUE (chave_pix);


--
-- TOC entry 4857 (class 2606 OID 24714)
-- Name: pix_pessoa pix_pessoa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pix_pessoa
    ADD CONSTRAINT pix_pessoa_pkey PRIMARY KEY (id_pix);


--
-- TOC entry 4859 (class 2606 OID 24716)
-- Name: rende_diario rende_diario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rende_diario
    ADD CONSTRAINT rende_diario_pkey PRIMARY KEY (id_rendimento);


--
-- TOC entry 4861 (class 2606 OID 24718)
-- Name: transacao transacao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT transacao_pkey PRIMARY KEY (id_transacao);


--
-- TOC entry 4863 (class 2606 OID 24772)
-- Name: usuario usuario_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_login_key UNIQUE (login);


--
-- TOC entry 4865 (class 2606 OID 24770)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4875 (class 2620 OID 24719)
-- Name: transacao trg_auditoria_transacao; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_transacao AFTER INSERT ON public.transacao FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria_transacao();


--
-- TOC entry 4866 (class 2606 OID 24720)
-- Name: conta fk_conta_agencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conta
    ADD CONSTRAINT fk_conta_agencia FOREIGN KEY (id_agencia) REFERENCES public.agencia(id_agencia);


--
-- TOC entry 4867 (class 2606 OID 24725)
-- Name: conta fk_conta_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conta
    ADD CONSTRAINT fk_conta_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 4868 (class 2606 OID 24730)
-- Name: convenio fk_convenio_conta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.convenio
    ADD CONSTRAINT fk_convenio_conta FOREIGN KEY (id_conta) REFERENCES public.conta(id_conta);


--
-- TOC entry 4869 (class 2606 OID 24735)
-- Name: endereco fk_endereco_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endereco
    ADD CONSTRAINT fk_endereco_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 4870 (class 2606 OID 24740)
-- Name: pix_pessoa fk_pix_conta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pix_pessoa
    ADD CONSTRAINT fk_pix_conta FOREIGN KEY (id_conta) REFERENCES public.conta(id_conta);


--
-- TOC entry 4871 (class 2606 OID 24745)
-- Name: rende_diario fk_rendimento_conta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rende_diario
    ADD CONSTRAINT fk_rendimento_conta FOREIGN KEY (id_conta) REFERENCES public.conta(id_conta);


--
-- TOC entry 4872 (class 2606 OID 24750)
-- Name: transacao fk_transacao_destino; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT fk_transacao_destino FOREIGN KEY (conta_destino) REFERENCES public.conta(id_conta);


--
-- TOC entry 4873 (class 2606 OID 24755)
-- Name: transacao fk_transacao_origem; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacao
    ADD CONSTRAINT fk_transacao_origem FOREIGN KEY (conta_origem) REFERENCES public.conta(id_conta);


--
-- TOC entry 4874 (class 2606 OID 24773)
-- Name: usuario usuario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


-- Completed on 2026-06-14 22:39:02

--
-- PostgreSQL database dump complete
--

\unrestrict sBGedF8Oqp1vR4rcKirfJgAaPrndiuLr75P7jAR2bdf6yXP1KcNtye7dFVsF2LZ

-- Completed on 2026-06-14 22:39:02

--
-- PostgreSQL database cluster dump complete
--

