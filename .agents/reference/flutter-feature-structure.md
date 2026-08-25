# Flutter Feature Workflow — Directory Structure

[Extracted from flutter-architecture.md — feature directory tree]

## Standard Feature Structure

```
lib/features/<feature>/
├── data/
│   ├── dto/
│   │   └── user.dto.dart
│   ├── repository/
│   │   └── user_repository.dart
│   └── service/
│       └── api_service.dart
├── domain/
│   ├── cubit/
│   │   └── user_cubit.dart
│   ├── entity/
│   │   └── user.entity.dart
│   └── interface/
│       └── i_user_repository.dart
└── presentation/
    ├── views/
    │   └── user_screen.dart
    ├── widgets/
    │   └── user_card.dart
    │   └── dialogs/
    │       └── confirm_dialog.dart
    └── ...
```

## Naming Conventions (per file)

- Screen: `user_screen.dart`
- Cubit: `user_cubit.dart`
- Repository: `user_repository.dart`
- DTO: `user.dto.dart`
- Entity: `user.entity.dart`
- Dialog: `confirm_dialog.dart`
- Interface: `i_user_repository.dart`
