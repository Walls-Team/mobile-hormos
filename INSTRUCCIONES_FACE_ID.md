# 📱 Instrucciones para Probar Face ID

## 🚀 Pasos para Habilitar y Probar Face ID

### 1️⃣ **Primer Login**
1. Abre la app
2. Haz clic en "Log in"
3. Ingresa tu email y contraseña
4. Haz clic en "Iniciar sesión"
5. **IMPORTANTE:** Después del login exitoso, aparecerá un diálogo preguntando:
   - "🔐 Habilitar Face ID"
   - "¿Deseas habilitar Face ID para iniciar sesión más rápido en el futuro?"
6. Haz clic en "**Habilitar**"
7. **CRÍTICO:** Te pedirá autenticarte con Face ID (o Touch ID/Huella)
8. Autentica con Face ID
9. Si todo sale bien, verás mensaje: "✅ Face ID habilitado exitosamente"

### 2️⃣ **Verificar en Consola**
Después de habilitar, en la consola de Flutter deberías ver:
```
💾 Guardando credenciales biométricas...
   Email: tu@email.com
   ✅ Email guardado
   ✅ Password guardado
   ✅ Flag de habilitación guardado
🔍 Verificación de guardado:
   Email guardado: ✅
   Habilitación guardada: ✅
✅ Autenticación biométrica habilitada exitosamente
```

### 3️⃣ **Cerrar Sesión**
1. Ve a Settings (⚙️)
2. Scroll hasta abajo
3. Haz clic en "Cerrar Sesión"
4. Esto te llevará de vuelta a la pantalla de Welcome

### 4️⃣ **Verificar Botón de Face ID en Welcome**
En la pantalla de Welcome, **deberías ver**:
```
━━━━━━━━━━━━━━━━━━━━━
         o
━━━━━━━━━━━━━━━━━━━━━

[👤 Continuar con Face ID]
tu@email.com

[Log in]

[Register]
```

Si **NO ves** el botón "Continuar con Face ID", revisa la consola:
```
🔍 BiometricLoginButton: Verificando disponibilidad...
   Biometría habilitada: true
   Email guardado: tu@email.com
   Tipo de biometría: Face ID
   👁️ Botón se mostrará: true
```

### 5️⃣ **Login Rápido con Face ID**
1. Haz clic en "**Continuar con Face ID**"
2. Te pedirá autenticarte con Face ID
3. Autentica con Face ID
4. **Login automático** ✨
5. Irás directo al Dashboard

## 🔧 Troubleshooting

### ❌ Problema: No aparece el diálogo de "Habilitar Face ID"
**Posibles causas:**
- Ya habías habilitado Face ID anteriormente
- La biometría no está disponible en tu dispositivo

**Solución:**
1. Ve a Settings
2. Verifica si hay un switch de "Face ID" o "Touch ID"
3. Si está activado, desactívalo
4. Cierra sesión
5. Vuelve a hacer login

### ❌ Problema: No aparece el botón en Welcome
**Posibles causas:**
- Face ID no se habilitó correctamente
- Las credenciales no se guardaron

**Solución:**
1. Revisa los logs de consola durante el login
2. Verifica que veas los mensajes de "✅ Email guardado"
3. Si no los ves, hay un error al guardar en secure storage
4. En iOS Simulator, verifica que Face ID esté configurado:
   - `Features > Face ID > Enrolled`

### ❌ Problema: Face ID funciona pero no guarda credenciales
**Diagnóstico:**
```
# En consola deberías ver durante habilitación:
💾 Guardando credenciales biométricas...

# Si NO ves esto, el problema está en la función enableBiometricAuth
```

**Solución:**
1. Ve a Settings
2. Busca el switch de Face ID
3. Intenta habilitarlo manualmente desde ahí
4. Ingresa tu contraseña cuando te lo pida

## 📱 Configuración de iOS Simulator

### Habilitar Face ID en Simulator:
1. Simulator menu → `Features` → `Face ID` → `Enrolled`

### Simular autenticación exitosa:
1. Cuando la app pida Face ID
2. Simulator menu → `Features` → `Face ID` → `Matching Face`

### Simular autenticación fallida:
1. Simulator menu → `Features` → `Face ID` → `Non-matching Face`

## 🔍 Verificar Estado en Settings

En la pantalla de Settings, deberías ver:

```
┌─────────────────────────────────┐
│ [Connect Device]                │
├─────────────────────────────────┤
│ 👤 Face ID                      │
│ Inicio rápido habilitado    [●] │ ← Switch activado
└─────────────────────────────────┘
```

Si el switch está desactivado:
- Haz clic para activarlo
- Te pedirá email y contraseña
- Autentica con Face ID
- Se habilitará

## 🐛 Debug Mode

Si necesitas más información, busca estos logs en consola:

### Al abrir Welcome:
```
🔍 BiometricLoginButton: Verificando disponibilidad...
```

### Al habilitar Face ID:
```
💾 Guardando credenciales biométricas...
🔍 Verificación de guardado:
```

### Al hacer login biométrico:
```
🔐 Iniciando login con credenciales biométricas...
✅ Login biométrico exitoso
```

## ✅ Checklist de Verificación

- [ ] Face ID está configurado en iOS Simulator (`Features > Face ID > Enrolled`)
- [ ] Hice login con email/contraseña
- [ ] Vi el diálogo "¿Habilitar Face ID?"
- [ ] Hice clic en "Habilitar"
- [ ] Vi el mensaje "✅ Face ID habilitado exitosamente"
- [ ] Vi los logs de guardado en consola
- [ ] Cerré sesión
- [ ] Veo el botón "Continuar con Face ID" en Welcome
- [ ] El botón muestra mi email debajo
- [ ] Al hacer clic, puedo autenticar con Face ID
- [ ] Login automático funciona
- [ ] En Settings veo el switch de Face ID activado

## 📞 Si Aún No Funciona

Si seguiste todos los pasos y aún no funciona, revisa:

1. **Consola de Flutter** - Busca errores o warnings
2. **iOS Simulator** - Verifica que Face ID esté enrolled
3. **flutter_secure_storage** - Puede tener problemas de permisos
4. **Hot Reload** - Haz un hot restart (R) no hot reload (r)
5. **Reinstalar** - Borra la app del simulator y reinstala

## 🎯 Flujo Esperado

```
Login con email/password
         ↓
[Diálogo: ¿Habilitar Face ID?]
         ↓
    [Habilitar]
         ↓
[Autentica con Face ID]
         ↓
"✅ Face ID habilitado"
         ↓
   [Cerrar Sesión]
         ↓
  Welcome Screen
         ↓
[👤 Continuar con Face ID]
         ↓
[Autentica con Face ID]
         ↓
Login automático ✨
         ↓
    Dashboard
```
