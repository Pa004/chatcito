# 💬 Chatcito

<div align="center">

Aplicación de mensajería en tiempo real desarrollada con **Flutter** y **Firebase**, que permite conversaciones privadas entre usuarios con autenticación segura, sincronización en tiempo real y notificaciones push mediante Firebase Cloud Messaging.

![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-6A5ACD?style=for-the-badge)
![Material 3](https://img.shields.io/badge/Material%203-4285F4?style=for-the-badge&logo=materialdesign&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![REST API](https://img.shields.io/badge/REST-API-005571?style=for-the-badge)

</div>

---

## 📖 Descripción

**Chatcito** es una aplicación móvil de mensajería instantánea desarrollada con **Flutter** y respaldada por **Firebase**, diseñada para ofrecer comunicación privada entre usuarios mediante conversaciones en tiempo real.

La aplicación integra autenticación mediante correo electrónico, almacenamiento de datos en Firebase Realtime Database, notificaciones push con Firebase Cloud Messaging (FCM), persistencia de preferencias del usuario y una interfaz moderna inspirada en aplicaciones como **WhatsApp** y **Telegram**.

---

## ✨ Características

- 🔐 Autenticación mediante correo electrónico y contraseña.
- 👤 Registro de usuarios.
- 💬 Chats privados uno a uno.
- ⚡ Sincronización de mensajes en tiempo real.
- 🔔 Notificaciones Push mediante Firebase Cloud Messaging.
- 📲 Banner de notificaciones dentro de la aplicación.
- 🌙 Tema claro y oscuro persistente.
- ✏️ Edición de mensajes enviados.
- 🗑️ Eliminación de mensajes.
- 📶 Indicador del estado de conexión.
- 🎨 Interfaz moderna basada en Material Design 3.
- 📱 Compatible con Android.

---

# 🏗 Arquitectura

El proyecto sigue una arquitectura organizada por capas:

```
Presentation
     │
     ▼
 Domain
     │
     ▼
  Data
     │
     ▼
 Firebase
```

Se emplea **Riverpod** para la gestión de estado y Firebase como backend para autenticación, almacenamiento de datos y notificaciones.

---

# 🛠 Tecnologías utilizadas

| Tecnología | Uso |
|------------|-----|
| Flutter | Desarrollo de la aplicación |
| Dart | Lenguaje de programación |
| Firebase Authentication | Inicio de sesión |
| Firebase Realtime Database | Base de datos en tiempo real |
| Firebase Cloud Messaging | Notificaciones Push |
| Riverpod | Gestión del estado |
| Shared Preferences | Persistencia del tema |
| HTTP | Comunicación con FCM HTTP v1 |
| Material 3 | Diseño de interfaz |

---

# 📂 Estructura del proyecto

```
lib/
│
├── data/
│   └── services/
│
├── domain/
│   └── models/
│
├── presentation/
│   ├── providers/
│   ├── theme/
│   ├── views/
│   └── widgets/
│
├── firebase_options.dart
└── main.dart
```

---

# 🚀 Instalación

## 1. Clonar el repositorio

```bash
git clone https://github.com/Pa004/chatcito.git
```

Entrar al proyecto:

```bash
cd chatcito
```

---

## 2. Instalar dependencias

```bash
flutter pub get
```

---

## 3. Configurar Firebase

Generar nuevamente la configuración mediante FlutterFire:

```bash
flutterfire configure
```

---

## 4. Ejecutar la aplicación

```bash
flutter run
```

---

## 5. Analizar el proyecto

```bash
flutter analyze
```

---

# 🔥 Firebase

El proyecto utiliza los siguientes servicios de Firebase:

- Firebase Authentication
- Firebase Realtime Database
- Firebase Cloud Messaging (FCM)

---

# 📲 Funcionalidades principales

### Autenticación

- Registro de usuarios
- Inicio de sesión
- Cierre de sesión

### Chat

- Conversaciones privadas
- Mensajes en tiempo real
- Edición de mensajes
- Eliminación de mensajes
- Ordenamiento cronológico

### Notificaciones

- Push Notifications
- Banner dentro de la aplicación
- Navegación directa al chat

### Interfaz

- Tema claro
- Tema oscuro
- Persistencia del tema
- Animaciones
- Transiciones personalizadas

---

# 📦 Dependencias principales

- firebase_core
- firebase_auth
- firebase_database
- firebase_messaging
- flutter_riverpod
- flutter_local_notifications
- googleapis_auth
- shared_preferences
- http

---

# 🤝 Contribuciones

Las contribuciones son bienvenidas.

Si deseas colaborar:

1. Haz un Fork del proyecto.
2. Crea una nueva rama.

```bash
git checkout -b feature/nueva-funcionalidad
```

3. Realiza los cambios.

4. Haz commit.

```bash
git commit -m "Agregar nueva funcionalidad"
```

5. Envía los cambios.

```bash
git push origin feature/nueva-funcionalidad
```

6. Abre un Pull Request.

---

# 👨‍💻 Autor

**Pablo Domínguez**

---

# 📄 Licencia

Este proyecto se distribuye únicamente con fines académicos.

---

<div align="center">

Desarrollado utilizando Flutter y Firebase.

</div>