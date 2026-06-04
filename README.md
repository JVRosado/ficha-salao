# Ficha Salão — Flutter

Conversão do projeto React/Figma para Flutter/Dart.

## Estrutura

```
lib/
├── main.dart                   # Entry point
├── router.dart                 # GoRouter — todas as rotas
├── theme.dart                  # Cores e ThemeData
├── models/
│   └── models.dart             # ClientModel, AppointmentModel, etc.
├── utils/
│   └── storage.dart            # SharedPreferences (persistência local)
├── widgets/
│   └── shared_widgets.dart     # Componentes reutilizáveis
└── screens/
    ├── home_screen.dart         # Tela inicial
    ├── search_client_screen.dart
    ├── form_step1_screen.dart   # Dados básicos
    ├── form_step2_screen.dart   # Informações de saúde
    ├── form_step3_screen.dart   # Procedimentos capilares
    ├── form_step4_screen.dart   # Observações + salvar
    ├── success_screen.dart
    ├── history_screen.dart      # Lista de clientes
    ├── client_details_screen.dart
    ├── client_timeline_screen.dart
    └── add_appointment_screen.dart
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Dependências principais

| Pacote              | Uso                                  |
|---------------------|--------------------------------------|
| go_router           | Navegação declarativa                |
| shared_preferences  | Persistência local (substitui localStorage) |
| intl                | Formatação de datas em pt-BR         |
| uuid                | Geração de IDs únicos                |

## Notas de conversão

- `sessionStorage` → passagem de dados via `GoRouter.extra` (em memória por sessão)
- `localStorage` → `SharedPreferences` (persiste entre sessões)
- Componentes shadcn/ui → widgets Flutter customizados
- Tailwind CSS → `ThemeData` + constantes em `AppTheme`
- `react-router` → `go_router`

## Para pt-BR completo no DatePicker

Adicione ao `pubspec.yaml`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

E em `main.dart` importe e adicione os delegates:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

localizationsDelegates: [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```
