# Implementación del Selector de Avatares

## 📋 Descripción
Sistema completo de selección de avatares desde el endpoint de la API, con modal interactivo y persistencia de la selección al perfil del usuario.

## 🔑 Endpoint Utilizado
```
GET https://main.geniushpro.com/v1/api/avatars/
Headers: Authorization: Bearer {token}
```

### Respuesta del API:
```json
{
    "message": "Lista de avatares obtenida exitosamente.",
    "error": "",
    "data": {
        "avatars": [
            "https://ms.geniushpro.com/avatars/f501b9a7fa481c220d3bd20abe76eb23d1933a32.jpg",
            "https://ms.geniushpro.com/avatars/26221e75ff4065bdc2edc5c08f40329670852824.jpg",
            ...
        ]
    },
    "maintenance": {}
}
```

## 📁 Archivos Creados/Modificados

### 1. **Nuevo:** `lib/features/settings/widgets/profile_skeleton_loader.dart`
Widget de skeleton loader animado para mejorar la experiencia de carga del perfil.

**Características:**
- Animación shimmer con gradiente
- Layout completo del formulario (avatar + 5 campos + botón)
- Colores: `Colors.grey[800]` y `Colors.grey[700]`
- Duración animación: 1500ms con repeat
- Bordes redondeados: 8px (campos) y 12px (botón)
- Avatar circular de 100x100px
- Todos los campos tienen altura de 48px

### 2. **Nuevo:** `lib/services/profile_service.dart`
Servicio para obtener la lista de avatares disponibles desde el API.

**Características:**
- Clase `AvatarsResponseData` para tipado de respuesta
- Método `getAvatars()` con autenticación Bearer
- Manejo de errores con `handleApiCall`
- Logging detallado para debugging

### 3. **Nuevo:** `lib/features/settings/widgets/avatar_selector_modal.dart`
Modal bottom sheet con grid de avatares seleccionables.

**Características:**
- Grid de 3 columnas con avatares circulares
- Indicador visual del avatar seleccionado (borde azul + sombra)
- Estados de carga, error y vacío
- Imágenes lazy-loaded con NetworkImage
- Botón de confirmación con validación
- Tamaños optimizados para mobile
- Loading placeholders durante carga de imágenes
- Error handling con opción de reintentar

**UI/UX:**
- Altura: 70% de la pantalla
- Color de fondo: `#1E1E2C`
- Bordes redondeados superiores: 20px
- Avatares: tamaño circular con `childAspectRatio: 1`
- Spacing entre items: 12px
- Botón confirmación: padding vertical 16px, azul

### 4. **Modificado:** `lib/features/settings/widgets/profile_form.dart`

**Cambios implementados:**

#### a) Imports agregados:
```dart
import 'package:genius_hormo/features/settings/widgets/avatar_selector_modal.dart';
```

#### b) State variables agregadas:
```dart
String? _selectedAvatar;
```

#### c) Inicialización en `initState()`:
```dart
_selectedAvatar = widget.initialData.avatar;
```

#### d) Actualización en `_submitForm()`:
```dart
avatar: _selectedAvatar,  // En lugar de widget.initialData.avatar
```

#### e) UI del avatar en `build()`:
```dart
GestureDetector(
  onTap: _showAvatarSelector,
  child: Stack(
    alignment: Alignment.center,
    children: [
      _buildAvatar(size: 100.0, imageUrl: _selectedAvatar),
      Positioned(
        bottom: 0,
        right: MediaQuery.of(context).size.width / 2 - 62,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF1E1E2C), width: 2),
          ),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 8),
Text(
  'Toca el avatar para cambiarlo',
  style: TextStyle(color: Colors.white60, fontSize: 12),
  textAlign: TextAlign.center,
),
```

#### f) Método para abrir modal:
```dart
void _showAvatarSelector() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AvatarSelectorModal(
      currentAvatarUrl: _selectedAvatar,
      onAvatarSelected: (String avatarUrl) {
        setState(() {
          _selectedAvatar = avatarUrl;
        });
        debugPrint('✅ Avatar seleccionado: $avatarUrl');
      },
    ),
  );
}
```

### 5. **Modificado:** `lib/features/settings/settings.dart`

**Cambios implementados:**

#### a) Import agregado:
```dart
import 'package:genius_hormo/features/settings/widgets/profile_skeleton_loader.dart';
```

#### b) Skeleton loader en estado de carga:
```dart
Widget _buildProfileForm() {
  if (_isLoadingProfile) {
    return const ProfileSkeletonLoader();  // Antes: CircularProgressIndicator
  }
  // ... resto del código
}
```

**Mejora de UX:**
- Reemplazado CircularProgressIndicator simple por skeleton loader completo
- Muestra estructura del formulario mientras carga
- Animación shimmer profesional
- Evita "salto feo" cuando aparece el contenido real

## 🎯 Flujo de Usuario

1. Usuario navega a **Settings** > **Profile** → **Ve skeleton loader animado**
2. Ve su avatar actual (o placeholder si no tiene)
3. Ve texto "Toca el avatar para cambiarlo" debajo del avatar
4. Toca el avatar → se abre modal bottom sheet
5. Modal carga avatares del API con loading indicator
6. Ve grid de 11 avatares en 3 columnas
7. Selecciona un avatar → se marca con borde azul
8. Toca "Confirmar Selección" → modal se cierra
9. Avatar actualizado se ve en el formulario
10. Toca "Save Data" → avatar se guarda en el perfil

## 🎨 Diseño Mobile-First

### Tamaños:
- **Avatar en formulario:** 100x100 px
- **Ícono de editar:** 16px dentro de círculo de 28px
- **Avatares en grid:** Automático (33% del ancho - spacing)
- **Modal altura:** 70% de la pantalla
- **Texto ayuda:** 12px, color gris claro

### Espaciado:
- Grid spacing: 12px entre items
- Padding modal: 16px
- Padding header: 20px
- Padding botón: 16px vertical

### Colores:
- Fondo modal: `#1E1E2C`
- Borde selección: `Colors.blue`
- Sombra selección: `Colors.blue` con opacity 0.5
- Botón: `Colors.blue`
- Placeholder avatar: `Colors.grey[800]`
- Ícono placeholder: `Colors.grey[600]`
- Texto ayuda: `Colors.white60`

## ✅ Características Implementadas

- ✅ **Skeleton loader animado** para carga del perfil (shimmer effect)
- ✅ Servicio de avatares con autenticación
- ✅ Modal responsive con grid de 3 columnas
- ✅ Indicador visual de selección
- ✅ Estados de carga, error y vacío
- ✅ Lazy loading de imágenes con placeholders mejorados
- ✅ Placeholder para avatar null
- ✅ Ícono de editar sobre el avatar
- ✅ Persistencia de avatar seleccionado
- ✅ Integración con formulario de perfil
- ✅ Callback onAvatarSelected
- ✅ Validación antes de confirmar
- ✅ Logging para debugging
- ✅ BoxFit.cover para eliminar bordes negros en avatares

## 🔧 Testing

### Casos de prueba:
1. ✅ Avatar null → muestra placeholder con ícono
2. ✅ Abrir modal → carga avatares correctamente
3. ✅ Seleccionar avatar → marca visualmente
4. ✅ Confirmar selección → cierra modal y actualiza UI
5. ✅ Guardar perfil → avatar se persiste en API
6. ✅ Error de red → muestra mensaje y botón reintentar
7. ✅ Sin token → muestra error apropiado

## 📝 Notas Técnicas

- El modal es `isScrollControlled: true` para ocupar 70% de la pantalla
- Se usa `backgroundColor: Colors.transparent` para efecto de overlay
- NetworkImage maneja cache automáticamente
- Los avatares son URLs absolutas desde `ms.geniushpro.com`
- El ícono de editar tiene borde del mismo color del fondo para separarlo visualmente
- El botón de confirmación se deshabilita si no hay avatar seleccionado

## 🚀 Próximas Mejoras (Opcional)

- [ ] Opción de buscar/filtrar avatares
- [ ] Preview en tamaño completo al tocar un avatar
- [ ] Animaciones de transición
- [ ] Categorías de avatares
- [ ] Upload de avatar personalizado
- [ ] Caché local de avatares
