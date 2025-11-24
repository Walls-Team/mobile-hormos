# 🌍 Auditoría de Internacionalización - Genius Hormo

**Fecha:** 23 de Noviembre, 2025  
**Versión:** 1.0.4+7  
**Estado:** Fase 1 - Auditoría Inicial Completa

---

## 📊 Resumen Ejecutivo

### Cobertura Actual de Localización
- ✅ **Archivos de localización:** 2 idiomas (EN, ES)
- ✅ **Keys existentes:** ~280 strings traducidos
- ⚠️ **Strings hardcodeados encontrados:** 97+ instancias
- ⚠️ **SnackBars/AlertDialogs:** 108 instancias que revisar

### Estado por Feature
| Feature | Localización | Hardcoded | Prioridad |
|---------|--------------|-----------|-----------|
| **Settings** | Parcial | 29 textos | 🔴 ALTA |
| **Auth (Login/Register)** | Parcial | 15 textos | 🔴 ALTA |
| **Profile Form** | Parcial | 14 textos | 🔴 ALTA |
| **Email Verification** | Parcial | 12 textos | 🟡 MEDIA |
| **Reset Password** | Parcial | 10 textos | 🟡 MEDIA |
| **Store** | ✅ Completo | 4 textos | 🟢 BAJA |
| **Terms & Conditions** | Mínima | 5 textos | 🟡 MEDIA |
| **Dashboard** | ✅ Completo | 3 textos | 🟢 BAJA |
| **Stats** | ✅ Completo | 3 textos | 🟢 BAJA |
| **Daily Questions** | ✅ Completo | 3 textos | 🟢 BAJA |
| **Accept Device** | ✅ Completo | 0 textos | 🟢 BAJA |

---

## 🔍 Hallazgos Detallados

### 1. Settings (29 hardcoded strings) - 🔴 PRIORIDAD ALTA

**Archivos afectados:**
- `/lib/features/settings/settings.dart` (33 SnackBars/AlertDialogs)
- `/lib/features/settings/widgets/profile_form.dart` (16 SnackBars/AlertDialogs)
- `/lib/features/settings/widgets/avatar_selector_modal.dart` (1 texto)

**Problemas identificados:**
- ❌ Botones de confirmación hardcodeados ("Cancel", "Open link", "Disconnect Device")
- ❌ Mensajes de SnackBar sin traducir ("Profile updated successfully")
- ❌ Títulos de AlertDialog hardcodeados ("Open external link", "Log Out")
- ❌ Mensajes de error hardcodeados ("Authentication token not found")
- ❌ Textos de validación ("Height is required", "Weight must be at least...")
- ❌ Labels de formulario ("Username", "Height", "Weight", "BirthDay")

**Localización existente disponible:** ✅
- `settings.user`, `settings.height`, `settings.weight`, `settings.birthDate`
- `settings.selectAvatar`, `settings.avatarUpdated`
- `settings.deleteAccount`, `settings.deleteAccountModal.*`
- `common.cancel`, `common.save`

**Acción requerida:**
- Agregar keys faltantes para validaciones de formulario
- Reemplazar todos los textos hardcodeados por localización
- Agregar traducciones para mensajes de avatar selector

---

### 2. Auth - Login/Register (15 hardcoded strings) - 🔴 PRIORIDAD ALTA

**Archivos afectados:**
- `/lib/features/auth/pages/login.dart` (5 textos, 4 SnackBars)
- `/lib/features/auth/pages/register.dart` (10 textos, 4 SnackBars)

**Problemas identificados:**
- ❌ Placeholders hardcodeados ("Enter your email", "Enter your password")
- ❌ Botones sin traducir ("Log in", "Create Account")
- ❌ Links hardcodeados ("Forgot Password?", "Already have an account?")
- ❌ Mensajes de error sin traducir
- ❌ Checkboxes de términos y condiciones

**Localización existente disponible:** ✅
- `auth.login`, `auth.register`, `auth.email`, `auth.password`
- `auth.loginSuccess`, `auth.loginError`
- `auth.registerSuccess`, `auth.registerError`

**Acción requerida:**
- Agregar keys para placeholders
- Agregar keys para links ("forgotPassword", "haveAccount", "noAccount")
- Implementar traducciones en widgets de formulario

---

### 3. Profile Form (14 hardcoded strings) - 🔴 PRIORIDAD ALTA

**Archivos afectados:**
- `/lib/features/settings/widgets/profile_form.dart`

**Problemas identificados:**
- ❌ Labels de campos ("Username", "Height", "Weight", "BirthDay", "Gender")
- ❌ Mensajes de validación ("Height is required", "Please enter a valid number")
- ❌ Mensajes de error personalizados
- ❌ Botón "Save Profile"
- ❌ Texto de helper ("Tap avatar to change it")

**Localización existente disponible:** ✅
- `settings.user`, `settings.height`, `settings.weight`, `settings.birthDate`
- `settings.gender`, `gender.*`
- `common.save`

**Acción requerida:**
- Agregar keys para validaciones específicas
- Agregar key para "tapAvatarToChange"
- Implementar todas las traducciones en el formulario

---

### 4. Email Verification (12 hardcoded strings) - 🟡 PRIORIDAD MEDIA

**Archivos afectados:**
- `/lib/features/auth/pages/email_verification/verify_email.dart` (12 SnackBars)
- `/lib/features/auth/pages/email_verification/email_verified.dart` (1 texto)

**Problemas identificados:**
- ❌ Mensajes de verificación sin traducir
- ❌ Botones de reenvío de código
- ❌ Mensajes de error/éxito
- ❌ Títulos y descripciones

**Localización existente disponible:** ⚠️ PARCIAL
- Necesita agregar sección completa en localization files

**Acción requerida:**
- Crear sección `emailVerification` en archivos de localización
- Agregar todas las keys necesarias (title, description, resend, success, error)

---

### 5. Reset Password (10 hardcoded strings) - 🟡 PRIORIDAD MEDIA

**Archivos afectados:**
- `/lib/features/auth/pages/reset_password/forgot_password.dart` (4 textos, 4 SnackBars)
- `/lib/features/auth/pages/reset_password/reset_password_form.dart` (4 textos, 9 SnackBars)
- `/lib/features/auth/pages/reset_password/reset_password_validate_code.dart` (2 textos, 10 SnackBars)

**Problemas identificados:**
- ❌ Títulos de pantalla
- ❌ Instrucciones
- ❌ Botones de acción
- ❌ Mensajes de validación de código

**Localización existente disponible:** ⚠️ PARCIAL
- `changePassword.*` existe pero no cubre todo el flujo de reset

**Acción requerida:**
- Expandir sección `resetPassword` o `forgotPassword` en localization
- Agregar keys para validación de código OTP

---

### 6. Avatar Selector Modal - 🟡 PRIORIDAD MEDIA

**Archivos afectados:**
- `/lib/features/settings/widgets/avatar_selector_modal.dart`

**Problemas identificados:**
- ❌ "Select Your Avatar"
- ❌ "Retry"
- ❌ "No avatars available"
- ❌ "Confirm Selection"
- ❌ "Authentication token not found"
- ❌ "Error loading avatars"
- ❌ "Connection error"

**Localización existente disponible:** ✅ PARCIAL
- `settings.selectAvatar` existe
- `common.cancel`, `errors.retry` existen

**Acción requerida:**
- Agregar keys específicas para modal de avatar
- Implementar traducciones

---

### 7. Store - 🟢 PRIORIDAD BAJA

**Estado:** ✅ **COMPLETAMENTE LOCALIZADO**

La sección Store ya usa `AppLocalizations` correctamente:
- `localizations.storeTitle`
- `localizations.storeSubtitle`
- `localizations.storeVitaminsTitle`
- etc.

Solo tiene 4 textos menores para verificar.

---

### 8. Dashboard - 🟢 PRIORIDAD BAJA

**Estado:** ✅ **MAYORMENTE LOCALIZADO**

Dashboard usa localización extensivamente. Solo 3 textos menores para revisar.

---

### 9. Terms & Conditions - 🟡 PRIORIDAD MEDIA

**Archivos afectados:**
- `/lib/features/terms_and_conditions/terms_and_conditions.dart` (5 textos)

**Problemas identificados:**
- ❌ Contenido completo de términos y condiciones hardcodeado
- ❌ Título sin traducir

**Acción requerida:**
- Crear sección `termsAndConditions` en localization
- Agregar contenido completo en ambos idiomas

---

## 📋 Keys Faltantes por Agregar

### Settings
```dart
'settings': {
  'formValidation': {
    'heightRequired': 'Height is required',
    'heightInvalidNumber': 'Please enter a valid number',
    'heightRange': 'Height must be between 3.0 and 9.0 ft',
    'weightRequired': 'Weight is required',
    'weightInvalidNumber': 'Please enter a valid number',
    'weightMin': 'Weight must be at least 40.0 lbs',
    'birthDateRequired': 'Birth date is required',
    'birthDateInvalid': 'Invalid date format',
    'genderRequired': 'Please select a gender',
    'usernameRequired': 'Username is required',
  },
  'avatarModal': {
    'title': 'Select Your Avatar',
    'noAvatars': 'No avatars available',
    'confirm': 'Confirm Selection',
    'tokenNotFound': 'Authentication token not found',
    'loadError': 'Error loading avatars',
    'connectionError': 'Connection error',
  },
  'tapAvatarToChange': 'Tap avatar to change it',
  'profileUpdateSuccess': 'Profile updated successfully',
  'profileUpdateError': 'Error updating profile',
}
```

### Auth
```dart
'auth': {
  'placeholders': {
    'email': 'Enter your email',
    'password': 'Enter your password',
    'confirmPassword': 'Confirm your password',
    'username': 'Enter your username',
  },
  'forgotPassword': 'Forgot Password?',
  'alreadyHaveAccount': 'Already have an account?',
  'noAccount': 'Don\'t have an account?',
  'createAccount': 'Create Account',
  'agreeToTerms': 'I agree to the Terms and Conditions',
}
```

### Email Verification
```dart
'emailVerification': {
  'title': 'Verify Your Email',
  'description': 'We sent a verification code to your email',
  'enterCode': 'Enter verification code',
  'resend': 'Resend Code',
  'verify': 'Verify',
  'success': 'Email verified successfully',
  'error': 'Verification failed',
  'invalidCode': 'Invalid verification code',
  'codeExpired': 'Code expired',
  'resendSuccess': 'Code resent successfully',
}
```

### Reset Password
```dart
'resetPassword': {
  'title': 'Reset Password',
  'enterEmail': 'Enter your email to receive reset code',
  'sendCode': 'Send Code',
  'enterNewPassword': 'Enter new password',
  'validateCode': {
    'title': 'Enter Verification Code',
    'description': 'We sent a code to your email',
    'verify': 'Verify Code',
  },
  'success': 'Password reset successfully',
  'error': 'Failed to reset password',
  'codeSent': 'Reset code sent to your email',
}
```

### Terms and Conditions
```dart
'termsAndConditions': {
  'title': 'Terms and Conditions',
  'content': '[Full content here]',
  'accept': 'Accept',
  'decline': 'Decline',
}
```

---

## 🎯 Plan de Implementación Recomendado

### Fase 2A: Features Prioritarios (Semana 1)
1. **Settings** (1-2 días)
   - Agregar todas las keys de validación
   - Implementar traducciones en profile_form.dart
   - Implementar avatar_selector_modal.dart
   
2. **Auth Flow** (1-2 días)
   - Login/Register
   - Email Verification
   - Reset Password

### Fase 2B: Features Secundarios (Semana 2)
3. **Terms & Conditions** (1 día)
4. **Verificación completa** (1 día)
5. **Testing en ambos idiomas** (1 día)

---

## ✅ Checklist de Progreso

### Settings
- [ ] Agregar keys de validación a localization files
- [ ] Implementar en profile_form.dart
- [ ] Implementar en avatar_selector_modal.dart
- [ ] Implementar en settings.dart (SnackBars y AlertDialogs)
- [ ] Testing en ES e EN

### Auth
- [ ] Agregar keys de auth a localization files
- [ ] Implementar en login.dart
- [ ] Implementar en register.dart
- [ ] Implementar en email verification
- [ ] Implementar en reset password
- [ ] Testing en ES e EN

### Otros
- [ ] Terms & Conditions
- [ ] Dashboard (verificación final)
- [ ] Store (verificación final)
- [ ] Validación completa de la app

---

## 📊 Métricas

- **Total de archivos a modificar:** ~15 archivos
- **Total de keys nuevas a agregar:** ~60 keys
- **Total de strings a reemplazar:** ~100+ instancias
- **Tiempo estimado:** 4-6 días de trabajo
- **Cobertura objetivo:** 100% de la UI en ES e EN

---

## 🔧 Herramientas y Recursos

### Archivos de localización:
- `/lib/l10n/app_localizations_en.dart`
- `/lib/l10n/app_localizations_es.dart`
- `/lib/l10n/app_localizations.dart` (clase principal)

### Helper existente:
```dart
final localizations = AppLocalizations.of(context);
// Uso: localizations.keyName o localizations['section']['key']
```

---

**Fin del reporte de auditoría**
