# iOS Configuration for Push Notifications (Opcional)

Este documento describe los pasos para configurar notificaciones push en iOS (cuando sea necesario).

## Requerimientos

- Apple Developer Account
- APN Certificate (Apple Push Notification certificate)
- Firebase Project configurado en iOS

## Paso 1: Configurar APN Certificate en Apple Developer

1. Ir a [Apple Developer](https://developer.apple.com)
2. Account → Certificates, IDs & Profiles
3. Certificates → crear nuevo certificado
4. Seleccionar "Apple Push Notification service SSL (Sandbox & Production)"
5. Seleccionar App ID
6. Seguir instrucciones para crear CSR y descargar certificado

## Paso 2: Subir APN Certificate a Firebase

1. Firebase Console → Project Settings → Cloud Messaging
2. Tab **Apple**
3. Subir el certificado APNs descargado

## Paso 3: Configurar GoogleService-Info.plist

1. Firebase Console → Project Settings → Your apps → iOS
2. Descargar `GoogleService-Info.plist`
3. En Xcode:
   - Ejecutar: `open ios/Runner.xcworkspace`
   - Drag & drop `GoogleService-Info.plist` en Runner
   - Select "Copy if needed"

## Paso 4: Actualizar firebase_options.dart

El template ya incluye la configuración de iOS, solo necesitas actualizar con las credenciales:

```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSy...', // Actual iOS API Key
  appId: '1:...:ios:...', // Actual iOS App ID  
  messagingSenderId: '...', // Actual Sender ID
  projectId: 'proyecto-id',
  storageBucket: 'proyecto-id.appspot.com',
  iosBundleId: 'com.example.frontend', // Tu Bundle ID
);
```

## Paso 5: Configurar Info.plist

En `ios/Runner/Info.plist`, asegurar que está permitida la notificación:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

## Paso 6: Solicitar Permiso de Usuario

En iOS 10+, es necesario solicitar permiso explícitamente. La app ya lo hace en:

```dart
// En firebase_messaging_service.dart
await _messaging.requestPermission(
  alert: true,
  sound: true,
  badge: true,
);
```

## Testing en iOS

```bash
flutter run -d iPhone
# Luego enviar notificación de prueba desde backend
```

**Nota**: El testing requiere ejecutar en un dispositivo real, no en simulador (el simulador no recibe notificaciones push de Apple).

## Troubleshooting iOS

- **No recibe notificaciones**: Verificar que APN Certificate está válido en Apple Developer
- **Error "invalid APNs certificate"**: Descargar nuevo certificado y subirlo
- **"Entitlements not found"**: Asegurar que `GoogleService-Info.plist` está agregado al proyecto

## Links Útiles

- [Firebase iOS Setup](https://firebase.flutter.dev/docs/messaging/overview)
- [Apple Push Notifications](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)
- [iOS Capabilities](https://developer.apple.com/support/cloudkit/)

---

**Nota**: Por ahora, la configuración está lista para Android. iOS puede configurarse cuando sea necesario.
