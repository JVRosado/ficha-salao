# Ficha Salão

Aplicativo para gestão de fichas de anamnese e histórico de atendimentos de
clientes de salão de beleza. Nasceu como conversão de um protótipo React/Figma
para Flutter/Dart e hoje é composto por um app Flutter + uma API REST própria
em Node.js conectada a um banco PostgreSQL.

> Relatório técnico completo (arquitetura, segurança, roadmap detalhado) em
> [`RELATORIO_PROJETO.md`](./RELATORIO_PROJETO.md).

## Stack

| Parte | Pasta | Tecnologia |
|---|---|---|
| App (frontend) | `lib/` | Flutter / Dart, `go_router`, `http`, `shared_preferences` |
| API (backend) | `backend/` | Node.js / TypeScript, Express, PostgreSQL (`pg`, sem ORM) |
| Autenticação | — | JWT (`jsonwebtoken`) + hash de senha (`bcryptjs`) |
| Validação | — | `zod` no backend |

## Estrutura

```
lib/
├── main.dart                    # Entry point
├── router.dart                  # GoRouter — todas as rotas + guard de login
├── theme.dart                   # Cores e ThemeData
├── models/
│   └── models.dart              # ClientModel, HealthInfo, ProcedureInfo, AppointmentModel
├── utils/
│   ├── api_client.dart          # Cliente HTTP (GET/POST/PUT/DELETE) + token JWT
│   └── storage.dart             # Camada de storage — chama a API
├── widgets/
│   └── shared_widgets.dart      # Componentes reutilizáveis
└── screens/
    ├── login_screen.dart        # Login
    ├── home_screen.dart         # Tela inicial
    ├── search_client_screen.dart
    ├── form_step1_screen.dart   # Ficha nova — dados básicos
    ├── form_step2_screen.dart   # Ficha nova — informações de saúde
    ├── form_step3_screen.dart   # Ficha nova — procedimentos capilares
    ├── form_step4_screen.dart   # Ficha nova — observações + salvar
    ├── success_screen.dart
    ├── history_screen.dart      # Lista de clientes
    ├── client_details_screen.dart
    ├── client_timeline_screen.dart
    └── add_appointment_screen.dart

backend/
├── package.json                 # scripts: dev / build / start / migrate
├── .env.example                 # PORT, DATABASE_URL, JWT_SECRET
└── src/
    ├── index.ts                 # bootstrap do Express
    ├── db/
    │   ├── pool.ts               # pool de conexões pg
    │   ├── schema.sql            # tabelas users / clients / appointments
    │   ├── migrate.ts            # aplica schema.sql no banco
    │   └── create-user.ts        # cria usuário de login (hash bcrypt)
    ├── middleware/
    │   └── auth.ts               # requireAuth — valida Bearer token
    ├── routes/
    │   ├── auth.ts                # POST /auth/login
    │   ├── clients.ts             # CRUD /clients
    │   ├── appointments.ts        # CRUD /clients/:clientId/appointments
    │   └── admin.ts               # GET /admin — painel HTML somente leitura (sem auth, uso local)
    └── utils/
        ├── jwt.ts                 # signToken / verifyToken
        └── mappers.ts             # linhas do Postgres (snake_case) → JSON (camelCase)
```

## Como rodar

### 1. Banco de dados (PostgreSQL)

Instale o PostgreSQL 16 e crie um banco:

```bash
createdb ficha_salao
```

### 2. Backend

```bash
cd backend
cp .env.example .env      # ajuste DATABASE_URL e JWT_SECRET
npm install
npm run migrate           # cria as tabelas
npm run dev                # sobe a API em http://localhost:3000
```

Crie um usuário de login com `src/db/create-user.ts` (ou via script equivalente)
antes do primeiro login.

### 3. App Flutter

Ajuste `apiBaseUrl` em `lib/utils/api_client.dart` conforme o ambiente:
- **Emulador Android:** `http://10.0.2.2:3000` (padrão atual)
- **Dispositivo físico:** IP da máquina que roda o backend na rede local
- **Windows/Web/Desktop:** `http://localhost:3000`

```bash
flutter pub get
flutter run
```

## Banco de dados

- **`users`** — credenciais de login (`email`, `password_hash`)
- **`clients`** — ficha de anamnese completa (dados básicos, saúde, procedimentos capilares, observações)
- **`appointments`** — histórico de atendimentos, vinculado a `clients` (`ON DELETE CASCADE`)

Schema completo em [`backend/src/db/schema.sql`](./backend/src/db/schema.sql).

## API

Todas as rotas de `/clients` e `/appointments` exigem `Authorization: Bearer <token>`.

| Método | Rota | Função |
|---|---|---|
| POST | `/auth/login` | Autentica e devolve um JWT |
| GET | `/clients` | Lista resumida de clientes |
| GET/POST/PUT/DELETE | `/clients/:id` | CRUD de ficha de cliente |
| GET/POST/PUT/DELETE | `/clients/:clientId/appointments/:apptId` | CRUD de atendimentos |
| GET | `/admin` | Painel HTML somente leitura (sem autenticação — uso local) |
| GET | `/health` | Healthcheck |

## Dependências principais (app)

| Pacote              | Uso                                          |
|---------------------|-----------------------------------------------|
| go_router           | Navegação declarativa                         |
| http                | Comunicação com a API REST                    |
| shared_preferences  | Guarda o token JWT de sessão                  |
| intl                | Formatação de datas em pt-BR                  |
| uuid                | Geração de IDs únicos                         |

## Notas de conversão (React → Flutter)

- `sessionStorage` → passagem de dados via `GoRouter.extra` (em memória por sessão)
- `localStorage` → API + `SharedPreferences` (hoje só o token de sessão fica local; os dados da ficha vivem no backend)
- Componentes shadcn/ui → widgets Flutter customizados
- Tailwind CSS → `ThemeData` + constantes em `AppTheme`
- `react-router` → `go_router`

## Estado atual e próximos passos

Fluxo completo (login → criar cliente → aparece no histórico) validado
localmente. Nada está publicado/hospedado ainda — API e banco rodam só na
máquina local. Pendências de segurança e infraestrutura antes de produção
(hospedagem, `JWT_SECRET` definitivo, proteger `/admin`, etc.) estão
detalhadas em [`RELATORIO_PROJETO.md`](./RELATORIO_PROJETO.md#8-atualizações-e-pendências-futuras).