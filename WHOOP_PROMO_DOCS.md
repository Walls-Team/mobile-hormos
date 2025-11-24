# 🎁 Modal de Promoción WHOOP - Documentación

## ✅ Implementación Completada

Se ha creado un modal atractivo y moderno para promocionar WHOOP que aparece automáticamente cuando el usuario entra a la app.

---

## 🎨 Diseño del Modal

### **Características Visuales**
- ✨ **Diseño moderno** con gradientes oscuros (azul/morado)
- 🎯 **Elementos decorativos** circulares en el fondo
- 💜 **Icono central** con gradiente y sombra brillante
- 🔥 **Botón CTA prominente** con gradiente y animación
- 📱 **Completamente responsive** y adaptativo

### **Estructura del Contenido**
```
┌─────────────────────────────────┐
│                              [X] │
│                                  │
│        [💜 Icono Heart]          │
│                                  │
│     ¡Oferta Exclusiva! 🎁        │
│                                  │
│  ┌──────────────────────────┐   │
│  │ Obtén un WHOOP gratis    │   │
│  │      + 1 mes gratis      │   │
│  │                          │   │
│  │ al unirte a través de    │   │
│  │ nuestro enlace exclusivo │   │
│  └──────────────────────────┘   │
│                                  │
│  [¡Quiero mi WHOOP gratis! →]   │
│                                  │
│         Ahora no                 │
└─────────────────────────────────┘
```

---

## 📁 Archivos Creados

### **1. WhoopPromoModal** 
`/lib/widgets/whoop_promo_modal.dart`

Modal con diseño premium que incluye:
- Gradiente oscuro con círculos decorativos
- Icono central con efecto de brillo
- Título llamativo: "¡Oferta Exclusiva! 🎁"
- Contenedor destacado con la oferta
- Botón CTA con gradiente y flecha
- Botón secundario "Ahora no"
- Funcionalidad para abrir el enlace: `https://join.whoop.com/GENIUS`

### **2. WhoopPromoService**
`/lib/services/whoop_promo_service.dart`

Servicio que gestiona la lógica de cuándo mostrar el modal:
- ✅ Muestra el modal **una vez por sesión**
- ✅ No se muestra si ya apareció en esta sesión
- ✅ Cooldown de **4 horas** entre apariciones
- ✅ Guarda el estado en `SharedPreferences`

**Métodos principales:**
- `shouldShowPromo()` - Verifica si debe mostrar
- `markAsShown()` - Marca como mostrado
- `reset()` - Resetea el estado (para testing)
- `forceShow()` - Fuerza mostrar (para testing)

---

## 🔄 Flujo de Usuario

### **Escenario 1: Primera vez que entra**
1. Usuario hace login
2. Entra al Dashboard (HomeScreen)
3. Aparece cuestionario diario (si aplica)
4. **500ms después** → Aparece modal de WHOOP 🎁
5. Usuario puede:
   - Hacer clic en "¡Quiero mi WHOOP gratis!" → Abre enlace
   - Hacer clic en "Ahora no" → Cierra modal
   - Hacer clic en [X] → Cierra modal

### **Escenario 2: Usuario regresa antes de 4 horas**
1. Usuario abre la app
2. Entra al Dashboard
3. **No aparece** el modal (ya se mostró en esta sesión)

### **Escenario 3: Usuario regresa después de 4 horas**
1. Usuario abre la app
2. Entra al Dashboard
3. **Aparece** el modal de nuevo

---

## ⚙️ Configuración

### **Cambiar Frecuencia de Aparición**

Si quieres cambiar cada cuánto aparece el modal, edita:

```dart
// En /lib/services/whoop_promo_service.dart línea ~35

// De 4 horas a 24 horas (una vez al día):
if (difference.inHours >= 24) {

// O una vez a la semana:
if (difference.inDays >= 7) {

// O siempre que abre la app (no recomendado):
return true; // Comentar todo el if
```

### **Cambiar el Enlace**

Si el enlace cambia, edita:

```dart
// En /lib/widgets/whoop_promo_modal.dart línea ~12

final uri = Uri.parse('https://join.whoop.com/TU-CODIGO-AQUI');
```

### **Personalizar Textos**

Los textos están en español pero puedes cambiarlos:

```dart
// Título
'¡Oferta Exclusiva! 🎁'

// Descripción principal
'Obtén un WHOOP gratis'

// Descripción secundaria
'+ 1 mes gratis'

// Subtexto
'al unirte a través de nuestro enlace exclusivo'

// Botón principal
'¡Quiero mi WHOOP gratis!'

// Botón secundario
'Ahora no'
```

---

## 🎨 Personalizar Diseño

### **Cambiar Colores del Gradiente**

```dart
// En WhoopPromoModal, línea ~39

// Gradiente del fondo:
colors: [
  Color(0xFF1a1a2e),  // Azul oscuro
  Color(0xFF16213e),  // Azul medio
  Color(0xFF0f3460),  // Azul
]

// Gradiente del botón:
colors: [
  Colors.purple.shade500,
  Colors.blue.shade500,
]
```

### **Cambiar Icono Central**

```dart
// Línea ~102
Icon(
  Icons.favorite,  // ← Cambia aquí
  size: 40,
  color: Colors.white,
)

// Otros iconos sugeridos:
// Icons.card_giftcard - Regalo
// Icons.star - Estrella
// Icons.bolt - Rayo
// Icons.celebration - Celebración
// Icons.local_fire_department - Fuego
```

---

## 🧪 Testing

### **Forzar que Aparezca el Modal**

Si quieres probar el modal sin esperar:

```dart
// En cualquier lugar donde tengas acceso al servicio:
final whoopService = GetIt.instance<WhoopPromoService>();
await whoopService.reset(); // Resetea el estado
whoopService.forceShow();   // Fuerza la próxima aparición
```

### **Mostrar Modal Manualmente**

Para testing rápido:

```dart
// En cualquier Widget con BuildContext:
import 'package:genius_hormo/widgets/whoop_promo_modal.dart';

// Dentro de un método:
await WhoopPromoModal.show(context);
```

### **Verificar Logs**

Al mostrar el modal verás en consola:

```
🎁 WHOOP Promo: Primera vez, mostrando modal
✅ WHOOP Promo: Marcado como mostrado
```

Cuando no debe mostrarse:

```
🎁 WHOOP Promo: Ya se mostró en esta sesión
```

O:

```
🎁 WHOOP Promo: Solo han pasado 120 minutos, no mostrar
```

---

## 📱 Dónde Aparece

Actualmente el modal aparece en:
- ✅ **HomeScreen** (Dashboard) - Después del cuestionario diario

### **Agregar a Otras Pantallas**

Si quieres que también aparezca en otras pantallas:

```dart
import 'package:genius_hormo/services/whoop_promo_service.dart';
import 'package:genius_hormo/widgets/whoop_promo_modal.dart';
import 'package:get_it/get_it.dart';

// En el initState o después de cargar:
Future.delayed(const Duration(seconds: 2), () async {
  if (mounted) {
    final whoopService = GetIt.instance<WhoopPromoService>();
    final shouldShow = await whoopService.shouldShowPromo();
    
    if (shouldShow && mounted) {
      await WhoopPromoModal.show(context);
      await whoopService.markAsShown();
    }
  }
});
```

---

## 🎯 Analytics (Opcional)

Si quieres trackear cuántas personas hacen clic:

```dart
// En WhoopPromoModal, después de abrir el enlace:

await launchUrl(uri, mode: LaunchMode.externalApplication);

// Agregar analytics aquí:
// analytics.logEvent('whoop_promo_clicked');
// Firebase.logEvent('clicked_whoop_offer');
```

---

## 🚫 Desactivar Temporalmente

Si quieres desactivar el modal sin borrar código:

```dart
// En /lib/services/whoop_promo_service.dart

Future<bool> shouldShowPromo() async {
  return false; // ← Siempre retorna false
  
  // El resto del código queda igual
  // Solo comenta o descomenta esta línea
}
```

---

## 🔒 Consideraciones

### **Privacidad**
- El modal NO guarda información personal
- Solo guarda un timestamp de cuándo se mostró
- No trackea si el usuario hizo clic o no
- No envía datos a ningún servidor

### **Performance**
- El modal es ligero (~100 líneas de código)
- No afecta el rendimiento de la app
- Se carga solo cuando es necesario
- No hace llamadas a APIs

### **UX**
- No interrumpe flujos críticos
- Aparece después del cuestionario diario
- Fácil de cerrar (3 opciones: X, "Ahora no", tap afuera)
- Cooldown de 4 horas evita ser intrusivo

---

## 📊 Estadísticas de Uso (Sugeridas)

Puedes agregar tracking para medir:
- Cuántas veces se muestra
- Cuántas veces se hace clic
- Tasa de conversión
- Horario de mayor interacción

---

## 🎨 Variaciones de Diseño

### **Versión Minimalista**
Si prefieres algo más simple, puedes:
- Quitar los círculos decorativos
- Usar color sólido en vez de gradiente
- Simplificar el botón

### **Versión Animada**
Para más impacto visual:
- Agregar AnimatedContainer
- Fade in/scale animation al aparecer
- Pulso en el botón CTA

### **Versión con Imagen**
Si tienes imagen de WHOOP:
```dart
// Reemplazar el icono circular con:
Image.network(
  'URL_DE_IMAGEN_WHOOP',
  height: 100,
)
```

---

## 🐛 Troubleshooting

### **Modal no aparece**
1. Verifica logs en consola
2. Asegúrate de que el servicio esté registrado en GetIt
3. Verifica que no se haya mostrado hace menos de 4 horas
4. Usa `reset()` para forzar

### **Enlace no se abre**
1. Verifica que `url_launcher` esté instalado
2. En iOS: verifica LSApplicationQueriesSchemes en Info.plist
3. Revisa permisos de la app

### **Modal aparece demasiado seguido**
1. Verifica la lógica en `shouldShowPromo()`
2. Aumenta el cooldown de 4 horas a más tiempo
3. Verifica que `markAsShown()` se esté llamando

---

## ✅ Checklist de Verificación

- [x] Servicio registrado en GetIt
- [x] Modal se muestra en HomeScreen
- [x] Enlace funciona correctamente
- [x] Cooldown de 4 horas implementado
- [x] Diseño responsive y atractivo
- [x] Fácil de cerrar
- [x] Logs para debugging

---

## 🎉 Resultado Final

El usuario verá un modal atractivo con:
- 🎁 Mensaje claro de la oferta
- 🔥 Diseño premium y moderno
- 💜 Colores llamativos pero elegantes
- 👆 Fácil de interactuar
- ⏰ No invasivo (aparece esporádicamente)

**El modal está listo para producción.** 🚀
