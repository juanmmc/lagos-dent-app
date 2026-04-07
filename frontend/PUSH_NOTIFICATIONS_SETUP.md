# 📱 Implementación de Notificaciones Push Firebase

## Resumen de la Implementación

Se ha implementado completamente el flujo de notificaciones push en la app Flutter, integrando Firebase Cloud Messaging (FCM) con los endpoints del backend.

## ✅ Cambios Realizados

### 1. **Dependencias Añadidas**
- `firebase_core: ^3.7.0` - Core de Firebase
- `firebase_messaging: ^15.1.3` - Cloud Messaging

Ejecutar: `flutter pub get`

### 2. **Servicios Creados**

#### 📋 `lib/core/notifications/firebase_messaging_service.dart`
Maneja toda la lógica de Firebase Cloud Messaging:
- Inicializa FCM y solicita permisos de notificación
- Procesa mensajes en primer plano (foreground)
- Procesa notificaciones tocadas en segundo plano (background)
- Escucha cambios de token de Firebase
- Navega a la pantalla adecuada cuando el usuario toca una notificación

#### 🔑 `lib/core/notifications/device_token_service.dart`
Gestiona registro/desregistro de tokens con el backend:
- `registerToken()` - Llama `POST /api/device-tokens`
- `deregisterToken()` - Llama `DELETE /api/device-tokens`
- Almacena el último token registrado localmente

#### 🎯 `lib/core/notifications/notification_manager.dart`
Coordinador central que:
- Inicializa todas las notificaciones al arrancar la app
- Registra token después del login exitoso
- Desregistra token en logout
- Re-registra token cuando Firebase lo refresca

### 3. **Integración Auth**
- `lib/features/auth/presentation/controllers/auth_controller.dart`
  - Llamada a `registerDeviceTokenAfterLogin()` después de login (paciente y doctor)
  - Llamada a `deregisterDeviceTokenOnLogout()` en logout

### 4. **Almacenamiento**
- `lib/core/storage/session_storage.dart`
  - Métodos para guardar/recuperar/limpiar token del dispositivo
  - El token se mantiene sincronizado entre Firebase y el backend

### 5. **Inicialización App**
- `lib/main.dart`
  - Inicializa Firebase antes de lanzar la app
  - Llama al notification manager para configurar escuchadores

### 6. **Configuración Android**
- `android/app/src/main/AndroidManifest.xml`
  - Permiso: `android.permission.INTERNET`
  - Permiso: `android.permission.POST_NOTIFICATIONS` (Android 13+)

- `android/build.gradle.kts`
  - Plugin: `com.google.gms.google-services` v4.4.1

- `android/app/build.gradle.kts`
  - Plugin aplicado: `com.google.gms.google-services`

---

## 🔧 Configuración Manual Requerida

### Paso 1: Descargar `google-services.json`

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Seleccionar el proyecto
3. Ir a **Project Settings** (⚙️ esquina inferior izquierda)
4. Tab **Your apps** → seleccionar la app Android
5. Descargar `google-services.json`
6. Copiar el archivo a: **`android/app/`**

### Paso 2: Completar `firebase_options.dart`

El archivo `lib/firebase_options.dart` es un template que necesita credenciales reales.

1. En Firebase Console, ir a **Project Settings**
2. Tab **General**
3. En la sección de la app Android, encontrar:
   - **API Key** (para Android)
   - **App ID** 
   - **Project ID**
   - **Sender ID** (Messaging)

4. Actualizar `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'TU_API_KEY_AQUI',              // ← Actual API Key
  appId: '1:123456789:android:abcdef...',  // ← Actual App ID
  messagingSenderId: '123456789',          // ← Actual Sender ID
  projectId: 'tu-proyecto-id',             // ← Actual Project ID
  storageBucket: 'tu-proyecto-id.appspot.com',
);
```

### Paso 3: Reconstruir la App

```bash
# Limpiar valores antiguos
flutter clean

# Reinstalar dependencias
flutter pub get

# Reconstruir
flutter run
```

---

## 🔄 Flujo de Notificaciones

### Flujo de Login
```
1. Usuario inicia sesión (paciente o doctor)
2. ✅ Se obtiene token Sanctum del backend
3. ✅ Se obtiene token FCM de Firebase
4. ✅ Se registra token FCM en backend (POST /api/device-tokens)
5. ✅ Se guarda token localmente
6. ✅ App lista para recibir notificaciones
```

### Flujo de Refresco de Token
```
1. Firebase refresca el token FCM
2. ✅ Se detecta el nuevo token
3. ✅ Se valida que usuario está autenticado
4. ✅ Se registra nuevo token en backend
5. ✅ Se actualiza almacenamiento local
```

### Flujo de Logout
```
1. Usuario cierra sesión
2. ✅ Se desregistra token del backend (DELETE /api/device-tokens)
3. ✅ Se limpia almacenamiento local
4. ✅ Sesión invalidada
```

### Flujo de Recepción de Notificación
```
1. Backend envía notificación con payload:
   {
     "appointment_id": "uuid-cita",
     "event": "confirmed|rescheduled|rejected|absent"
   }

2. Firebase entrega a dispositivo
3. ✅ Si app está abierta → Muestra notificación en primer plano
4. ✅ Si app está cerrada → Notificación en bandeja del sistema
5. Usuario toca notificación
6. ✅ App se abre/enfoca
7. ✅ Navega a pantalla de cita
8. ✅ Recarga datos de citas
```

---

## 🧪 Prueba Manual de Notificaciones

### Método 1: Usando el Endpoint Test del Backend

```bash
curl -X POST http://tu-backend/api/push-test \
  -H "Authorization: Bearer TU_TOKEN_SANCTUM" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "fcm-device-token-aqui",
    "title": "Prueba Cita",
    "body": "Tu cita ha sido confirmada",
    "data": {
      "appointment_id": "uuid-cita",
      "event": "confirmed"
    }
  }'
```

### Método 2: Desde la App (Después del Login)

1. Iniciar sesión en la app
2. Ver logs en Android Studio o `flutter logs`
3. Copiar el token FCM que aparece: `🔥 [FCM] Token obtained: abc...`
4. Usar ese token en el endpoint test del backend

### Verificación

- ✅ Token registrado: Ver logs `✅ [DEVICE_TOKEN] Token registered successfully`
- ✅ Notificación recibida: Sonido + vibración en el dispositivo
- ✅ App navega a cita después de tocar

---

## 📋 Tipos de Eventos Soportados

El backend envía notificaciones para estos eventos:

| Evento | Destinatario | Descripción |
|--------|-------------|-----------|
| `pending_confirmation` | Paciente | Cita pendiente de confirmación |
| `confirmed` | Paciente | Doctor confirmó la cita |
| `rescheduled` | Paciente | Doctor reprogramó la cita |
| `rejected` | Paciente | Doctor rechazó la cita |
| `absent` | Paciente | Doctor marcó ausencia |

---

## 🐛 Solución de Problemas

### ❌ Notificaciones no llegan

**Causa**: El archivo `google-services.json` no existe o es incorrecto

**Solución**:
```bash
# Verificar que el archivo existe
ls android/app/google-services.json

# Si no existe, descargarlo de Firebase Console
# Si existe pero es incorrecto, descargarlo de nuevo
```

### ❌ Error: "no se puede obtener el token"

**Causa**: Firebase no inicializado correctamente

**Solución**:
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

### ❌ Error: "Token registration failed"

**Causa**: Backend no accesible o token de autenticación inválido

**Solución**:
1. Verificar conexión de red: `adb shell ping 8.8.8.8`
2. Verificar URL del backend en `lib/core/config/app_config.dart`
3. Verificar token Sanctum válido: Ver logs de login

### ❌ Error en `firebase_options.dart`

**Causa**: Credenciales incompletas o incorrectas

**Solución**:
1. Copiar exactamente los valores de Firebase Console
2. No olvidar el `messagingSenderId` (puede verse como "Sender ID")
3. El `appId` debe ser `1:` + número + `:android:` + hexadecimal

---

## 🎯 Próximos Pasos Recomendados

### 1. **Crear Pantalla de Detalle de Cita** (Opcional)
Si no existe ya, se recomienda:
```dart
// lib/features/appointments/presentation/screens/appointment_detail_screen.dart
GoRoute(
  path: '/appointments/:appointmentId',
  builder: (context, state) => AppointmentDetailScreen(
    appointmentId: state.pathParameters['appointmentId']!,
  ),
)
```

### 2. **Mejorar Feedback Visual**
- Toast/Snackbar cuando se registra token
- Indicador visual en configuración mostrando token registrado
- Estado de sinc con servidor

### 3. **Manejo Avanzado**
- Manejo de errores de desregistro más robusto
- Reintento automático de registro si falla
- Analytics de notificaciones (qué usuario, cuándo)

---

## 📝 Consideraciones Importantes

1. **Token Persistencia**: El token se almacena localmente para poder desregistrarlo en logout
2. **Sincronización**: El token se re-registra automáticamente si Firebase lo refresca
3. **Autenticación**: Requiere token Sanctum válido para registrar/desregistrar
4. **Permisos Android**: 
   - Android 13+ requiere `POST_NOTIFICATIONS` en runtime
   - Considerar solicitar permiso explícitamente si es necesario
5. **Seguridad**: Nunca compartir `google-services.json` en repositorios públicos

---

## 📞 Debug y Logs

Para ver logs detallados de notificaciones:

```bash
# Ver todos los logs de FCM
flutter logs | grep "FCM\|DEVICE_TOKEN\|NOTIFICATION_MANAGER"

# Ver solo errores
flutter logs | grep "❌"

# Ver todo
flutter logs
```

Los servicios usan prefijos en debug:
- 🔥 `[FCM]` - Firebase Messaging
- 📱 `[DEVICE_TOKEN]` - Device Token Service
- 🔔 `[NOTIFICATION_MANAGER]` - Notification Manager
- 🧭 `[FCM]` - Navigation desde notificación

---

**Estado**: ✅ Implementación completada y lista para configurar Firebase
