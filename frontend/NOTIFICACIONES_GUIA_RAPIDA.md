# 📱 Notificaciones Push Firebase - Guía Rápida

## ✅ Implementación Completada

Todos los servicios y flujos de notificaciones push están implementados en la app. Solo necesitas configurar Firebase.

---

## 🚀 Pasos de Configuración (5 minutos)

### 1️⃣ Obtener `google-services.json`

**En tu navegador:**
1. Ir a https://console.firebase.google.com
2. Selecciona tu proyecto
3. Click en ⚙️ → **Project Settings**
4. Tab **Your Apps** → selecciona tu app Android
5. Click **Download google-services.json**

**En tu proyecto:**
- Copiar el archivo a: `android/app/google-services.json`

### 2️⃣ Actualizar `lib/firebase_options.dart`

Reemplaza estos valores con los de Firebase Console (Project Settings → General):

```dart
// android
apiKey: 'TU_API_KEY_ANDROID',
appId: '1:123456789:android:ABC123...',
messagingSenderId: '123456789',
projectId: 'tu-proyecto-id',

// iOS (si lo vas a usar)
apiKey: 'TU_API_KEY_IOS',
appId: '1:123456789:ios:ABC123...',
```

### 3️⃣ Reconstruir la App

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Probar Notificaciones

### Desde tu app:
1. Inicia sesión (paciente o doctor)
2. Abre las DevTools: `flutter run` en terminal
3. Busca en los logs: `🔥 [FCM] Token obtained: ...`
4. Copia ese token

### Desde tu backend:
```bash
curl -X POST http://localhost:8000/api/push-test \
  -H "Authorization: Bearer TU_TOKEN_SANCTUM" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "COPIA_AQUI_EL_TOKEN_FCM",
    "title": "¡Hola!",
    "body": "Prueba de notificación",
    "data": {
      "appointment_id": "123e4567-e89b-12d3-a456-426614174000",
      "event": "confirmed"
    }
  }'
```

### Resultado esperado:
- ✅ Notificación aparece en el dispositivo
- ✅ Al tocarla, vuelve a la pantalla principal
- ✅ Los datos de citas se actualizan

---

## 📋 Archivos Creados/Modificados

### Nuevos servicios:
- ✅ `lib/core/notifications/firebase_messaging_service.dart` - Maneja FCM
- ✅ `lib/core/notifications/device_token_service.dart` - Registra token en backend
- ✅ `lib/core/notifications/notification_manager.dart` - Coordinador de notificaciones

### Modificados:
- ✅ `lib/main.dart` - Inicializa Firebase
- ✅ `lib/core/storage/session_storage.dart` - Almacena token local
- ✅ `lib/features/auth/.../auth_controller.dart` - Registra/desregistra en login/logout
- ✅ `android/app/src/main/AndroidManifest.xml` - Permisos de notificaciones
- ✅ `android/build.gradle.kts` - Plugin Google Services
- ✅ `android/app/build.gradle.kts` - Plugin aplicado
- ✅ `pubspec.yaml` - Dependencias Firebase

### Plantillas de configuración:
- ✅ `lib/firebase_options.dart` - Necesita credenciales
- ✅ `android/app/google-services.json` - Necesita descargar

---

## 🔄 Flujo Automático

```
📱 Login exitoso
    ↓
🔥 FCM obtiene token del dispositivo
    ↓
📤 Token enviado a backend (POST /api/device-tokens)
    ↓
💾 Token guardado localmente
    ↓
✅ Listo para recibir notificaciones

---

📨 Backend envía notificación
    ↓
🔔 FCM entrega a dispositivo
    ↓
👆 Usuario toca notificación
    ↓
🏠 App abre y navega a citas
    ↓
🔄 Datos de citas se actualizan

---

🚪 Usuario hace logout
    ↓
🔑 Token desregistrado del backend (DELETE /api/device-tokens)
    ↓
🗑️ Token eliminado localmente
    ↓
✅ Sesión cerrada
```

---

## 🐛 Si Algo No Funciona

### ❌ **Error: "No se puede obtener el token"**
```bash
flutter clean
flutter pub get
flutter run
```

### ❌ **Error: "Notificaciones no se reciben"**
1. Verifica que `android/app/google-services.json` existe
2. Verifica que tienes internet en el dispositivo: `adb shell ping 8.8.8.8`
3. Verifica logs: `flutter logs | grep FCM`

### ❌ **Error: "Token registration failed"**
1. Verifica que el token Sanctum es válido
2. Verifica que la app está correctamente autenticada
3. Verifica que el backend está accesible

---

## 📞 Debug en Logs

Busca estos prefijos en los logs::
- 🔥 `[FCM]` - Mensajería de Firebase
- 📱 `[DEVICE_TOKEN]` - Registro de token
- 🔔 `[NOTIFICATION_MANAGER]` - Coordinador

```bash
# Ver logs de FCM
flutter logs | grep "FCM\|DEVICE_TOKEN\|NOTIFICATION_MANAGER"

# Ver todos los logs
flutter logs
```

---

## 📝 Soportados Eventos de Notificación

| Evento | Quién Recibe | Cuándo |
|--------|-------------|--------|
| `confirmed` | 👤 Paciente | Doctor confirma cita |
| `rescheduled` | 👤 Paciente | Doctor reprograma cita |
| `rejected` | 👤 Paciente | Doctor rechaza cita |
| `absent` | 👤 Paciente | Doctor marca ausencia |

---

## ✨ Próximos Pasos (Opcionales)

1. **Crear pantalla de detalles de cita** (actualmente navega a home)
2. **Solicitar permiso de notificación en runtime** (Android 13+)
3. **Mostrar badge en el ícono de la app** (iOS)
4. **Analytics de notificaciones** (tracking)

---

## 💡 Notas Importantes

- El token se refresca automáticamente y se re-registra
- El token se desregistra al hacer logout
- Funciona tanto con app en primer plano como en segundo plano
- Android 13+ necesita permiso `POST_NOTIFICATIONS` (ya incluido)

---

**Status**: ✅ **LISTO PARA USAR** 

Solo falta descargar `google-services.json` y configurar `firebase_options.dart`
