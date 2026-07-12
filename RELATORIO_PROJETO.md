# Relatório Técnico do Projeto — Ficha Salão

**Data do relatório:** 12/07/2026
**Repositório:** `ficha_salao` (branch `main`)

---

## 1. Visão geral

O **Ficha Salão** é um aplicativo para gestão de fichas de anamnese e histórico de
atendimentos de clientes de salão de beleza. O projeto nasceu como uma conversão de
um protótipo React/Figma para **Flutter/Dart** e, posteriormente, evoluiu de um
armazenamento 100% local (`SharedPreferences`) para uma arquitetura **cliente-servidor**,
com um backend REST próprio em Node.js conectado a um banco **PostgreSQL**.

Hoje o sistema é composto por duas partes principais que vivem no mesmo repositório:

| Parte | Pasta | Tecnologia |
|---|---|---|
| Aplicativo (frontend) | `lib/` | Flutter / Dart |
| API (backend) | `backend/` | Node.js / TypeScript / Express / PostgreSQL |

---

## 2. Linguagens e tecnologias utilizadas

### 2.1 Frontend — Aplicativo Flutter

- **Linguagem:** Dart (SDK `>=3.0.0 <4.0.0`)
- **Framework:** Flutter (Material 3 — `useMaterial3: true`)
- **Gerenciamento de rotas:** [`go_router`](https://pub.dev/packages/go_router) `^13.0.0` — navegação declarativa, com redirecionamento automático para `/login` quando o usuário não está autenticado
- **Cliente HTTP:** [`http`](https://pub.dev/packages/http) `^1.2.0` — comunicação com a API REST
- **Internacionalização:** `flutter_localizations` + [`intl`](https://pub.dev/packages/intl) `^0.20.2` — formatação de datas em pt-BR
- **Persistência local:** [`shared_preferences`](https://pub.dev/packages/shared_preferences) `^2.2.2` — usado hoje apenas para guardar o **token JWT** de sessão (todo o resto dos dados passou a viver no backend)
- **Geração de IDs:** [`uuid`](https://pub.dev/packages/uuid) `^4.3.3`
- **Lint/qualidade:** `flutter_lints` `^3.0.0` (`analysis_options.yaml`)
- **Plataformas configuradas no projeto:** Android e Windows (pastas `android/` e `windows/` presentes — iOS/Web/Linux/macOS não foram inicializados)
- **Tema visual:** classe `AppTheme` (`lib/theme.dart`) centraliza paleta de cores (tons de azul, roxo, verde, âmbar e cinzas) e `ThemeData`, reproduzindo o visual originalmente feito em Tailwind CSS

### 2.2 Backend — API REST

- **Linguagem:** TypeScript, executado sobre **Node.js**
- **Framework web:** [`express`](https://www.npmjs.com/package/express) `^4.19.2`
- **Banco de dados:** **PostgreSQL 16**, acessado via driver nativo [`pg`](https://www.npmjs.com/package/pg) `^8.11.5` — **sem ORM** (SQL escrito à mão)
- **Autenticação:** [`jsonwebtoken`](https://www.npmjs.com/package/jsonwebtoken) `^9.0.2` (JWT, validade de 30 dias) + [`bcryptjs`](https://www.npmjs.com/package/bcryptjs) `^2.4.3` para hash de senha
- **Validação de dados de entrada:** [`zod`](https://www.npmjs.com/package/zod) `^3.23.8` — todos os `POST`/`PUT` validam o corpo da requisição antes de tocar no banco
- **CORS:** [`cors`](https://www.npmjs.com/package/cors) `^2.8.5` (liberado de forma ampla, adequado ao estágio atual de uso local)
- **Variáveis de ambiente:** [`dotenv`](https://www.npmjs.com/package/dotenv) `^16.4.5`, lidas de um arquivo `.env` (não versionado)
- **Execução/build:**
  - Desenvolvimento: `tsx watch` (hot reload)
  - Produção: `tsc` compila `src/` → `dist/`, executado com `node dist/index.js`
- **Tipagem:** `@types/*` para Express, cors, jsonwebtoken, node, pg, bcryptjs
- **Modelo de usuário:** login único de salão (não há multi-usuário/multi-tenant ainda — um único registro em `users` foi criado manualmente via script)

### 2.3 Banco de dados

- **SGBD:** PostgreSQL 16, instalado localmente via `winget`, rodando como serviço do Windows (`postgresql-ficha-salao`) na porta `5432`
- **Banco:** `ficha_salao`
- **Extensão usada:** `pgcrypto` (para gerar UUIDs com `gen_random_uuid()`)
- **Migração:** schema aplicado via script próprio (`npm run migrate` → `backend/src/db/migrate.ts`), que executa o `schema.sql` — não há uma ferramenta de migração versionada tipo Prisma/Knex/Flyway, apenas um `CREATE TABLE IF NOT EXISTS`
- **Usuário de teste local:** `joaovrosado2003@gmail.com`, criado via script `create-user.ts`

#### Estrutura das tabelas

**`users`** — credenciais de acesso ao sistema
| Coluna | Tipo | Observação |
|---|---|---|
| id | UUID (PK) | `gen_random_uuid()` |
| email | TEXT UNIQUE | login |
| password_hash | TEXT | hash bcrypt |
| created_at | TIMESTAMPTZ | default `now()` |

**`clients`** — ficha de anamnese completa do cliente
| Grupo | Colunas |
|---|---|
| Dados básicos | `name`, `phone`, `email`, `birth_date`, `date` |
| Saúde (`HealthInfo`) | `health_allergies`, `health_medications`, `health_skin_conditions` |
| Procedimentos (`ProcedureInfo`) | `proc_has_smoothing`, `proc_smoothing_type`, `proc_smoothing_date`, `proc_has_coloring`, `proc_coloring_type`, `proc_coloring_date`, `proc_today_desire`, `proc_has_inspiration_photo`, `proc_willing_to_cut`, `proc_pre_treatment`, `proc_post_treatment`, `proc_professional_advice`, `proc_last_strand_test_date` |
| Outros | `observations`, `created_at`, `updated_at` |

Todas as colunas de texto usam `TEXT NOT NULL DEFAULT ''` — ou seja, o schema é
deliberadamente "flat" (sem tabelas separadas para saúde/procedimentos), refletindo
1:1 os objetos `HealthInfo`/`ProcedureInfo` do lado Dart.

**`appointments`** — histórico de atendimentos de cada cliente
| Coluna | Tipo | Observação |
|---|---|---|
| id | UUID (PK) | |
| client_id | UUID (FK → clients.id) | `ON DELETE CASCADE` |
| date | TEXT | |
| services | TEXT | |
| products | TEXT | |
| notes | TEXT | |
| professional | TEXT | |
| created_at | TIMESTAMPTZ | |

Índice: `idx_appointments_client_id` para acelerar a busca do histórico por cliente.

---

## 3. Arquitetura e fluxo de dados

```
┌─────────────────────┐        HTTPS/HTTP + JWT        ┌──────────────────────┐        SQL         ┌──────────────┐
│  App Flutter (lib/)  │ ──────────────────────────────▶ │ API Express (backend) │ ──────────────────▶ │ PostgreSQL   │
│  ApiClient (http)    │ ◀────────────────────────────── │ routes + middleware   │ ◀────────────────── │ ficha_salao  │
└─────────────────────┘             JSON                 └──────────────────────┘                     └──────────────┘
```

- O app **não fala mais diretamente com um banco local** — `StorageService`
  (`lib/utils/storage.dart`) delega tudo para `ApiClient` (`lib/utils/api_client.dart`),
  que faz as requisições HTTP para a API.
- O **token JWT** é obtido no login (`POST /auth/login`) e guardado em
  `SharedPreferences`; todas as chamadas subsequentes enviam
  `Authorization: Bearer <token>`.
- `router.dart` usa o `redirect` do `go_router` para checar `ApiClient.isLoggedIn()`
  e mandar o usuário para `/login` quando necessário.
- No backend, `requireAuth` (middleware) protege todas as rotas de `clients` e
  `appointments` — apenas `/auth/login` e `/health` são públicas. Há também um
  endpoint `/admin` **sem autenticação**, criado como visualizador HTML somente
  leitura para depuração local (não deve ser exposto publicamente).

### Endpoints da API

| Método | Rota | Função |
|---|---|---|
| POST | `/auth/login` | Autentica e devolve um JWT |
| GET | `/health` | Healthcheck simples |
| GET | `/clients` | Lista resumida de clientes (nome, telefone, última visita) |
| GET | `/clients/:id` | Ficha completa de um cliente |
| POST | `/clients` | Cria uma ficha de cliente |
| PUT | `/clients/:id` | Atualiza uma ficha de cliente |
| DELETE | `/clients/:id` | Remove um cliente (cascata remove atendimentos) |
| GET | `/clients/:clientId/appointments` | Lista atendimentos do cliente |
| POST | `/clients/:clientId/appointments` | Cria um atendimento |
| PUT | `/clients/:clientId/appointments/:apptId` | Atualiza um atendimento |
| DELETE | `/clients/:clientId/appointments/:apptId` | Remove um atendimento |
| GET | `/admin` | Painel HTML somente leitura (sem autenticação, uso local) |

---

## 4. Hierarquia de pastas e arquivos

> Pastas geradas automaticamente (`.dart_tool/`, `build/`, `android/.gradle/`,
> `.idea/`, `node_modules/`, `backend/dist/`) foram omitidas por não fazerem parte
> do código-fonte versionado/relevante.

```
ficha_salao/
├── .gitignore
├── .metadata
├── README.md                      # não versionado (removido do git por decisão do usuário)
├── analysis_options.yaml          # regras de lint do Dart/Flutter
├── pubspec.yaml                   # dependências e metadados do app Flutter
├── pubspec.lock
├── ficha_salao.iml
│
├── lib/                           # ── código-fonte do app Flutter ──
│   ├── main.dart                  # entry point (MaterialApp.router)
│   ├── router.dart                # todas as rotas (go_router) + guard de login
│   ├── theme.dart                 # AppTheme — cores e ThemeData
│   │
│   ├── models/
│   │   └── models.dart            # ClientModel, HealthInfo, ProcedureInfo,
│   │                               # AppointmentModel, ClientSummary (toJson/fromJson)
│   │
│   ├── utils/
│   │   ├── api_client.dart        # cliente HTTP genérico (GET/POST/PUT/DELETE) + token
│   │   └── storage.dart           # camada de "storage" que hoje chama a API
│   │
│   ├── widgets/
│   │   └── shared_widgets.dart    # componentes reutilizáveis (botões, cards, inputs)
│   │
│   └── screens/                   # uma tela por arquivo
│       ├── login_screen.dart              # tela de login (email/senha)
│       ├── home_screen.dart               # tela inicial / menu principal
│       ├── search_client_screen.dart      # busca de clientes
│       ├── form_step1_screen.dart         # ficha nova — passo 1: dados básicos
│       ├── form_step2_screen.dart         # ficha nova — passo 2: informações de saúde
│       ├── form_step3_screen.dart         # ficha nova — passo 3: procedimentos capilares
│       ├── form_step4_screen.dart         # ficha nova — passo 4: observações + salvar
│       ├── success_screen.dart            # confirmação de sucesso ao salvar
│       ├── history_screen.dart            # lista/histórico de clientes cadastrados
│       ├── client_details_screen.dart     # detalhes completos da ficha de um cliente
│       ├── client_timeline_screen.dart    # linha do tempo de atendimentos do cliente
│       └── add_appointment_screen.dart    # criar/editar atendimento
│
├── test/
│   └── widget_test.dart           # teste padrão gerado pelo Flutter (smoke test)
│
├── android/                       # projeto nativo Android (Gradle/Kotlin)
│   └── app/src/.../MainActivity.kt, AndroidManifest.xml, ícones, etc.
│
├── windows/                       # projeto nativo Windows (C++/CMake, gerado pelo Flutter)
│   └── runner/, flutter/
│
└── backend/                        # ── API REST (Node.js/TypeScript) ──
    ├── package.json                # dependências e scripts (dev/build/start/migrate)
    ├── package-lock.json
    ├── tsconfig.json
    ├── .env                        # variáveis de ambiente (não versionado)
    ├── .env.example                # modelo: PORT, DATABASE_URL, JWT_SECRET
    ├── .gitignore
    │
    └── src/
        ├── index.ts                 # bootstrap do Express, registra rotas e middlewares
        │
        ├── db/
        │   ├── pool.ts              # pool de conexões `pg` (lê DATABASE_URL)
        │   ├── schema.sql           # definição das tabelas users/clients/appointments
        │   ├── migrate.ts           # script que aplica o schema.sql no banco
        │   └── create-user.ts       # script utilitário para criar usuário (bcrypt hash)
        │
        ├── middleware/
        │   └── auth.ts              # requireAuth — valida header Authorization: Bearer
        │
        ├── routes/
        │   ├── auth.ts              # POST /auth/login
        │   ├── clients.ts           # CRUD de /clients
        │   ├── appointments.ts      # CRUD de /clients/:clientId/appointments
        │   └── admin.ts             # GET /admin — painel HTML somente leitura
        │
        └── utils/
            ├── jwt.ts               # signToken/verifyToken (JWT_SECRET, expira em 30d)
            └── mappers.ts           # converte linhas do Postgres (snake_case) em
                                       # JSON no formato usado pelo Flutter (camelCase)
```

### Tamanho aproximado do código (linhas por arquivo, frontend)

| Arquivo | Linhas |
|---|---|
| `lib/screens/client_details_screen.dart` | 348 |
| `lib/widgets/shared_widgets.dart` | 305 |
| `lib/screens/form_step3_screen.dart` | 287 |
| `lib/screens/client_timeline_screen.dart` | 240 |
| `lib/screens/history_screen.dart` | 203 |
| `lib/screens/add_appointment_screen.dart` | 188 |
| `lib/screens/success_screen.dart` | 192 |
| `lib/screens/home_screen.dart` | 165 |
| `lib/screens/form_step4_screen.dart` | 153 |
| `lib/screens/form_step1_screen.dart` | 148 |
| `lib/screens/login_screen.dart` | 106 |
| `lib/screens/form_step2_screen.dart` | 116 |
| `lib/screens/search_client_screen.dart` | 98 |
| `lib/router.dart` | 79 |
| `lib/theme.dart` | 55 |
| `lib/main.dart` | 35 |
| **Total (lib/)** | **~2.718 linhas** |

---

## 5. Fluxo funcional do aplicativo

1. **Login** (`login_screen.dart`) — usuário informa email/senha; o app chama
   `POST /auth/login`, recebe um JWT e o guarda localmente.
2. **Tela inicial** (`home_screen.dart`) — ponto de entrada para criar nova ficha,
   buscar cliente ou ver histórico.
3. **Criação de ficha** — fluxo em 4 passos (`form_step1` a `form_step4`), com os
   dados sendo repassados de tela em tela via `extra` do `go_router` (em memória,
   sem persistência parcial):
   - Passo 1: dados básicos (nome, telefone, email, nascimento, data)
   - Passo 2: informações de saúde (alergias, medicamentos, condições de pele)
   - Passo 3: procedimentos capilares (alisamento, coloração, desejo do dia, teste de mecha etc.)
   - Passo 4: observações finais + botão salvar (`POST /clients`)
4. **Sucesso** (`success_screen.dart`) — confirmação visual após salvar.
5. **Busca** (`search_client_screen.dart`) e **Histórico** (`history_screen.dart`) —
   listam clientes via `GET /clients`.
6. **Detalhes do cliente** (`client_details_screen.dart`) — ficha completa,
   possibilidade de editar (`PUT /clients/:id`).
7. **Linha do tempo** (`client_timeline_screen.dart`) — lista os atendimentos
   (`GET /clients/:id/appointments`).
8. **Atendimento** (`add_appointment_screen.dart`) — cria ou edita um atendimento
   (`POST`/`PUT` em `/clients/:id/appointments`).

---

## 6. Ambiente de desenvolvimento atual

- **PostgreSQL 16** instalado localmente via `winget`, rodando como serviço do
  Windows `postgresql-ficha-salao` na porta `5432` (superusuário `postgres`/`postgres`,
  uso local apenas).
- Banco `ficha_salao` criado e migrado via `npm run migrate`.
- Usuário de teste: `joaovrosado2003@gmail.com` / `teste123`.
- `backend/.env` (não versionado) aponta `DATABASE_URL` para esse Postgres local.
- `apiBaseUrl` em `lib/utils/api_client.dart` está fixo em `http://10.0.2.2:3000`
  (endereço especial que o **emulador Android** usa para acessar o `localhost` da
  máquina host). Isso precisa ser ajustado manualmente se o app rodar em:
  - dispositivo físico → IP da máquina na rede local;
  - build Windows/Web/Desktop → `http://localhost:3000`.
- Nada foi publicado/exposto fora da máquina local: sem hospedagem contratada,
  sem contas em nuvem, sem custos recorrentes até o momento.
- Fluxo completo (login → criar cliente → aparece no histórico) foi validado
  manualmente de ponta a ponta.

---

## 7. Segurança — estado atual

| Item | Situação |
|---|---|
| Senhas | Armazenadas com hash `bcrypt` (nunca em texto puro) |
| Autenticação das rotas | JWT obrigatório (`Bearer token`) em `/clients` e `/appointments` |
| Validação de entrada | `zod` valida todo corpo de requisição antes do banco |
| Segredo do JWT | `JWT_SECRET` ainda está com valor de exemplo/placeholder em ambiente de dev — **precisa ser rotacionado antes de qualquer uso em produção** |
| Senha do banco | Credenciais padrão do Postgres local (`postgres`/`postgres`) — aceitável apenas em ambiente local isolado |
| Rota `/admin` | Sem autenticação — painel de leitura pensado só para debug local, **não deve ser exposto na internet** |
| CORS | Liberado de forma ampla — adequado para desenvolvimento, deve ser restringido em produção |
| Multiusuário | Não existe — o sistema foi desenhado para um único login de salão (sem isolamento entre "contas") |

---

## 8. Atualizações e pendências futuras

A seguir, uma lista do que ainda **precisa ser feito** para o projeto evoluir de
"validado localmente" para um produto usável em produção:

### 8.1 Infraestrutura / deploy
- [ ] **Escolher e contratar hospedagem para a API** (ex.: Railway, Render, Fly.io,
      ou VPS próprio) — hoje o backend só roda na máquina local.
- [ ] **Escolher hospedagem gerenciada para o PostgreSQL** (ou usar a mesma dos
      exemplos acima) — hoje o Postgres é um serviço Windows local.
- [ ] Definir domínio/URL pública da API e atualizar `apiBaseUrl` no app para lê-lo
      de forma configurável por ambiente (dev/prod), em vez de valor fixo no código.
- [ ] Automatizar a execução de `npm run migrate` no deploy (pipeline CI/CD).

### 8.2 Segurança
- [ ] Gerar um `JWT_SECRET` forte e exclusivo de produção (o atual é placeholder).
- [ ] Trocar a senha padrão do Postgres antes de expor o banco fora da máquina local.
- [ ] Restringir CORS a domínios conhecidos.
- [ ] Proteger ou remover o endpoint `/admin` antes de qualquer deploy público (hoje é
      leitura livre sem autenticação).
- [ ] Adicionar rate limiting no `/auth/login` para mitigar força bruta.

### 8.3 Funcionalidades do app
- [ ] Revisar a rota de **edição de ficha de cliente** (havia um problema conhecido
      relacionado a isso, corrigido no commit mais recente — vale um teste de
      regressão completo).
- [ ] Avaliar suporte a **múltiplos usuários/profissionais** (hoje é um único login
      fixo para o salão inteiro).
- [ ] Persistência parcial do formulário de nova ficha (hoje, se o app fechar no
      meio do fluxo de 4 passos, os dados digitados se perdem, pois trafegam só em
      memória via `extra` do `go_router`).
- [ ] Upload de foto de inspiração (o campo `hasInspirationPhoto` existe como texto
      Sim/Não, mas não há upload/armazenamento de imagem de fato).
- [ ] Busca/filtro mais avançado na tela de histórico (hoje é uma lista simples).
- [ ] Exportação da ficha (PDF/impressão) para uso físico no salão, se for uma
      necessidade do negócio.

### 8.4 Qualidade / manutenção
- [ ] Ampliar a cobertura de testes automatizados (hoje só existe o `widget_test.dart`
      padrão gerado pelo Flutter, sem testes de tela ou de API).
- [ ] Adicionar testes automatizados para as rotas do backend (auth, clients,
      appointments).
- [ ] Configurar builds/CI para iOS e Web, caso o produto precise rodar nessas
      plataformas (hoje só Android e Windows estão inicializados).
- [ ] Documentar formalmente o contrato da API (ex.: OpenAPI/Swagger) para facilitar
      manutenção futura.

---

## 9. Resumo executivo

| Categoria | Escolha atual |
|---|---|
| Linguagem do app | Dart |
| Framework do app | Flutter (Material 3) |
| Roteamento | go_router |
| Linguagem do backend | TypeScript (Node.js) |
| Framework do backend | Express |
| Banco de dados | PostgreSQL 16 (sem ORM, SQL puro via `pg`) |
| Autenticação | JWT + bcrypt |
| Validação | Zod |
| Hospedagem | Nenhuma — tudo local até o momento |
| Plataformas do app configuradas | Android, Windows |
| Estado geral | Funcional e validado localmente; pronto para evoluir rumo à produção após os itens da seção 8 |