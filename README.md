# app_rtsg_client

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Variables de entorno

Copia `env.example.json` como `env.json` y completa los valores necesarios.
El archivo `env.json` está excluido de Git.

Ejecutar en desarrollo:

```bash
flutter run --dart-define-from-file=env.json
```

Generar Android:

```bash
flutter build apk --dart-define-from-file=env.json
```

Generar iOS:

```bash
flutter build ios --dart-define-from-file=env.json
```

Las variables se inyectan durante la compilación. No se deben guardar tokens
privados directamente en `ApiConstants`.
