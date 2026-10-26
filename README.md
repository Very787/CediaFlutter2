# StudyFlow IA

Aplicación móvil Flutter para organizar actividades académicas, descubrir técnicas de estudio y convertir pendientes en un plan semanal mediante un asistente de IA.

> Proyecto final individual del curso **Desarrolla Aplicaciones Móviles Robustas con Flutter e IA**. StudyFlow IA es un dominio independiente de la aplicación guiada ExploraEC.

## Funcionalidades

- Registro, inicio y cierre de sesión con autorización por token.
- Token guardado con `flutter_secure_storage`.
- CRUD remoto de actividades; cada usuario solo accede a sus registros.
- Catálogo remoto con 20 técnicas de estudio y estados de carga, vacío y error.
- Favoritos persistentes en Hive que sobreviven al reinicio.
- Estado compartido centralizado en controladores GetX.
- Planificador académico con IA a través de un servidor propio; la clave nunca llega al APK.
- Mensajes diferenciados para errores 400, 401, 422, 5xx y conexión.

## Arquitectura

```text
Pantallas Flutter
       ↓
Controladores GetX
       ↓
StudyFlowRepository
       ↓
API HTTP / almacenamiento seguro / Hive
```

Las pantallas no realizan solicitudes HTTP ni acceden directamente a la persistencia. `StudyFlowRepository` coordina las fuentes de datos, y `StudyFlowApi` concentra protocolo, autorización y traducción de errores.

El servidor incluido usa Node.js sin dependencias externas. Conserva usuarios y actividades en `server/data.json`, cifra contraseñas con `scrypt`, firma tokens HMAC y es el único componente que conoce `OPENAI_API_KEY`.

## Requisitos

- Flutter 3.47.8 o compatible con Dart 3.5+
- Android SDK y Java 17
- Node.js 20 o superior
- Una clave del proveedor de IA, únicamente si se probará el asistente real

## Ejecutar el servidor

PowerShell:

```powershell
cd server
$env:JWT_SECRET='cambia-este-secreto-local'
$env:OPENAI_API_KEY='tu-clave-solo-en-el-servidor'
node server.js
```

El servidor responde en `http://localhost:8080`. Comprueba su estado en `http://localhost:8080/health`.

No copies `.env.example` con valores reales al repositorio. Los archivos `.env` y `server/data.json` están ignorados por Git.

## Ejecutar Flutter

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

`10.0.2.2` conecta el emulador Android con el servidor del computador. Para un dispositivo físico usa la IP LAN del computador y permite el puerto 8080 en el firewall.

## Generar e instalar el APK

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8080
adb uninstall com.very787.studyflow
adb install build/app/outputs/flutter-apk/app-release.apk
```

La firma actual es de laboratorio y no está destinada a una tienda.

## Pruebas y escenarios observables

```powershell
flutter analyze
flutter test
cd server
node --test test/*.test.js
```

Para comprobar errores:

1. Detén el servidor: la app muestra un error de conexión y permite reintentar.
2. Usa credenciales incorrectas: el servidor devuelve 401.
3. Envía formularios incompletos: cliente y servidor validan los campos; el servidor devuelve 422.
4. Inicia con dos cuentas: cada una observa exclusivamente sus actividades.
5. Guarda un recurso, cierra completamente la app y vuelve a abrirla: el favorito permanece.

## Configuración por entorno

| Entorno | `API_BASE_URL` |
|---|---|
| Android Emulator | `http://10.0.2.2:8080` |
| Dispositivo físico | `http://IP_DEL_COMPUTADOR:8080` |
| Servicio publicado | URL HTTPS configurada en GitHub Actions |

Para que el APK del Release funcione fuera del laboratorio, configura la variable de repositorio `API_BASE_URL` con un servidor HTTPS desplegado antes de crear la etiqueta.

## Release automático

El workflow `.github/workflows/release-apk.yml` ejecuta análisis y pruebas, compila el APK y crea un GitHub Release al recibir una etiqueta:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

Antes de etiquetar, verifica que `main` esté publicado, que CI esté en verde y que `API_BASE_URL` apunte al servidor desplegado. La publicación remota no forma parte de los pasos locales de este documento.

## Decisión técnica

Se eligió un servidor HTTP pequeño y auditable en lugar de llamadas directas a un proveedor desde Flutter. Esto permite demostrar autorización real, aislamiento entre usuarios y protección de la clave de IA. Se descartó incluir la clave en `--dart-define`: esos valores pueden extraerse del APK y no constituyen almacenamiento secreto.

## Seguridad, privacidad y licencias

- La app no contiene claves, cookies ni contraseñas predefinidas.
- Las contraseñas se almacenan derivadas con `scrypt`, nunca en texto plano.
- El token móvil vive en almacenamiento seguro.
- El servidor debe ejecutarse con HTTPS y un `JWT_SECRET` fuerte fuera del laboratorio.
- No introduzcas datos académicos sensibles en el asistente.
- Flutter y los paquetes usados conservan sus licencias originales; consulta `pubspec.yaml` y sus páginas en pub.dev.
- El catálogo de técnicas fue redactado para este proyecto y no copia una fuente externa.

## Autoría

Proyecto académico de Verónica Villarreal (`@Very787`), 2026.
