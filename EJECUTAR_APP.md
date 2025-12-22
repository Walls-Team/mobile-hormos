# 🚀 Cómo Ejecutar la App - INSTRUCCIONES DEFINITIVAS

## ⚠️ IMPORTANTE: Hot Reload NO funciona para cambios estructurales

Los cambios que hice (botón flotante de chat y planes) requieren un **FULL RESTART** de la app.

## ✅ OPCIÓN 1: Ejecutar desde Xcode (RECOMENDADO)

1. **Abre Xcode** (ya debería estar abierto con `Runner.xcworkspace`)

2. **STOP la app actual** si está corriendo:
   - Presiona el botón ⏹️ Stop en Xcode
   - O presiona `Cmd + .` (punto)

3. **LIMPIA el build**:
   - Menú: **Product** → **Clean Build Folder**
   - O presiona: `Shift + Cmd + K`

4. **RUN de nuevo**:
   - Presiona el botón ▶️ **Play** en Xcode
   - O presiona `Cmd + R`

5. **ESPERA a que compile completamente**
   - Verás "Building..." en Xcode
   - Luego "Running..."
   - La app se abrirá en el simulador

## ✅ OPCIÓN 2: Desde Terminal

```bash
cd /Users/luisparedes/Desktop/mobile-hormos

# Matar cualquier instancia de la app
pkill -9 -f "Runner.app"

# Limpiar y ejecutar
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run --debug
```

## 🔍 Verificar que Funciona

### 1. Botón Flotante de Chat (Nuevo)
- Al abrir la app, verás un **botón amarillo flotante** en la esquina inferior derecha
- Tiene un icono de chat 💬
- Toca el botón → Se abre el chat con burbujas estilo Messenger

### 2. Pantalla de Planes
- Ve a **Configuración** (última pestaña del menú inferior)
- Toca **"Planes"**
- Deberías ver **4 cards de planes**:
  - Plan Básico ($9.99 - 30 días)
  - Plan Pro ($24.99 - 90 días)
  - Plan Premium ($44.99 - 180 días)
  - Plan Anual ($79.99 - 365 días)

### 3. Chat desde Configuración
- En Configuración, también hay un botón **"Asistente Virtual"** (amarillo)
- Tócalo para abrir el chat

## 🐛 Si los Planes SIGUEN sin verse:

Revisa la consola de Xcode y busca estos prints:
- `🟢 Navegando a PlansScreen` - Cuando tocas el botón de Planes
- `🔵 PlansScreen build() ejecutándose` - Cuando la pantalla se construye

**Si NO ves estos prints:**
- El problema es la navegación, no el archivo

**Si VES los prints pero la pantalla está vacía:**
- Toma un screenshot y muéstramelo
- Puede ser un problema de z-index o overlay

## 📱 Cambios Implementados

### ✅ Botón Flotante de Chat
- **Ubicación**: Esquina inferior derecha, encima del BottomNavigationBar
- **Color**: Amarillo (#EDE954)
- **Icono**: Chat bubble redondeado
- **Acción**: Abre ChatScreen en navegación completa

### ✅ Debug Agregado
- Prints en consola para verificar que PlansScreen se está ejecutando
- Ayuda a diagnosticar si el problema es navegación o rendering

## 🔧 Troubleshooting

### Error: "Command CodeSign failed"
```bash
./ios/rebuild.sh
flutter run
```

### App no refleja cambios
1. STOP completamente la app
2. Clean build folder en Xcode
3. RUN de nuevo

### Simulador se congela
1. Cierra el simulador
2. `xcrun simctl shutdown all`
3. Abre el simulador de nuevo
4. RUN desde Xcode

## ✅ Checklist Final

- [ ] Xcode está abierto con `Runner.xcworkspace`
- [ ] Simulador iPhone 16 seleccionado
- [ ] Clean Build Folder ejecutado (`Shift + Cmd + K`)
- [ ] App detenida completamente
- [ ] Presionar Play (`Cmd + R`)
- [ ] Esperar a que compile completamente
- [ ] Ver el botón flotante amarillo en la app
- [ ] Ir a Configuración → Planes
- [ ] Ver las 4 cards de planes

## 📞 Si Nada Funciona

1. Toma screenshot de:
   - La pantalla de Planes (vacía)
   - La consola de Xcode (con los logs)
   - El código del archivo `plans_screen.dart`

2. Verifica que estés viendo el archivo correcto:
   ```bash
   cat lib/features/settings/pages/plans_screen.dart | grep "Plan Básico"
   ```
   Debe mostrar "Plan Básico" en el código.

---

**IMPORTANTE: NO uses `flutter run` desde terminal SI Xcode ya está abierto. Usa SOLO Xcode o SOLO terminal, no ambos al mismo tiempo.**
