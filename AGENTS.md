# StudyFlow IA — instrucciones para agentes

Aplicación Flutter independiente para el proyecto final del curso CEDIA MOD3. Su dominio es la planificación académica; no es una extensión de ExploraEC.

## Alcance obligatorio

- Flutter/Dart y Material 3.
- Estado compartido con GetX.
- Arquitectura pantalla → controlador → repositorio → fuente de datos.
- Registro, inicio y cierre de sesión; token solo en almacenamiento seguro.
- Catálogo remoto de 20 recursos, CRUD remoto aislado por usuario y favoritos locales con Hive.
- Asistente académico consumido mediante `server/`; ninguna clave de IA pertenece al cliente.
- Estados explícitos de carga, vacío, error y contenido.

## Calidad y seguridad

- Ejecutar `flutter analyze`, `flutter test` y `node --test server/test/*.test.js`.
- No versionar `.env`, `server/data.json`, tokens, contraseñas, cookies ni claves.
- Mantener mensajes diferenciados para 400, 401, 422, 5xx y fallos de red.
- No llamar HTTP, Hive ni almacenamiento seguro directamente desde pantallas.
- No desactivar pruebas para obtener CI verde.

## Publicación

La publicación, etiquetas y Releases requieren aprobación explícita. Antes de etiquetar, comprobar el flujo en un emulador limpio y que `API_BASE_URL` apunte a un servidor HTTPS accesible.

Las antiguas prácticas se conservan en ramas `practica/sesionXX`; no mezclarlas nuevamente con `main`.
