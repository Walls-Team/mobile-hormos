# 🎓 Flutter para Devs de React/Angular/Node - Guía Completa

## 🎯 Intro: De JavaScript a Dart

Bienvenido, genio de React/Angular/Node. Flutter usa **Dart**, que es como TypeScript pero más estricto. Aquí está la traducción:

### Comparación Rápida

| **JavaScript/TypeScript** | **Dart (Flutter)** | **Notas** |
|---------------------------|-------------------|-----------|
| `const/let` | `final/var` | `final` = inmutable, `var` = mutable |
| `interface` | `abstract class` | Dart no tiene interfaces puras |
| `async/await` | `async/await` | Igual, pero con `Future<T>` |
| `Promise<T>` | `Future<T>` | Exactamente lo mismo |
| `Array<T>` | `List<T>` | Arrays en Dart |
| `Object` | `Map<String, dynamic>` | JSON objects |
| `import { X } from 'y'` | `import 'package:y/x.dart'` | Imports de paquetes |
| `null` | `null` | Pero Dart tiene **null safety** obligatorio |
| `T \| undefined` | `T?` | Nullable types |
| `!value` | `!value` | Non-null assertion |
| `value?.prop` | `value?.prop` | Optional chaining |

---

## 📁 Arquitectura del Proyecto

Tu proyecto usa **Clean Architecture** + **Feature-based structure**:

```
lib/
├── app/                    # Router y configuración global (como App.tsx en React)
│   ├── app.dart           # MaterialApp (equivalente a <App />)
│   ├── routes.dart        # GoRouter (como React Router)
│   └── route_names.dart   # Constantes de rutas
│
├── core/                   # Shared utilities (@core en Angular)
│   ├── api/               # API helpers (axios interceptors en React)
│   ├── config/            # Configuración (environment variables)
│   ├── di/                # Dependency Injection (GetIt ≈ Angular DI)
│   ├── navigation/        # Servicio de navegación
│   └── deep_link/         # Deep linking (como URL schemes)
│
├── features/              # Módulos por feature (como en Angular)
│   ├── auth/             # Feature de autenticación
│   │   ├── dto/          # Data Transfer Objects (interfaces en TS)
│   │   ├── models/       # Modelos de datos
│   │   ├── pages/        # Screens (componentes de página)
│   │   ├── services/     # API services
│   │   ├── utils/        # Validadores, helpers
│   │   └── widgets/      # Componentes reutilizables (como components/)
│   │
│   ├── dashboard/
│   ├── stats/
│   ├── spike/
│   ├── settings/
│   ├── store/
│   └── faqs/
│
├── providers/            # State management (Context API / Redux)
├── services/             # Servicios globales
├── models/               # Modelos compartidos
├── theme/                # Tema y estilos (CSS/SCSS)
├── utils/                # Utilidades compartidas
├── widgets/              # Componentes compartidos
├── l10n/                 # Internacionalización (i18n)
└── main.dart             # Entry point (index.js en React)
```

---

## 🔥 Conceptos Clave de Flutter

### 1. **Todo es un Widget** (como "Todo es un componente" en React)

```dart
// REACT
function MyButton({ onClick, children }) {
  return <button onClick={onClick}>{children}</button>;
}

// FLUTTER
class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  
  const MyButton({required this.onPressed, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
```

### 2. **StatelessWidget vs StatefulWidget**

| React | Flutter | Cuándo usar |
|-------|---------|-------------|
| Functional Component | `StatelessWidget` | No tiene estado interno |
| Component con `useState` | `StatefulWidget` | Tiene estado interno |

```dart
// StatelessWidget (como functional component sin hooks)
class WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hola!');
  }
}

// StatefulWidget (como component con useState)
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 3. **BuildContext** (como `this.props` o `useContext`)

El `context` tiene información del árbol de widgets. Similar a React Context.

```dart
// REACT
const theme = useContext(ThemeContext);

// FLUTTER
final theme = Theme.of(context);
final navigator = Navigator.of(context);
```

---

## 🛣️ Navegación (Routing)

Tu app usa **go_router** (como React Router):

```dart
// REACT ROUTER
<Route path="/login" element={<LoginScreen />} />
navigate('/dashboard');

// FLUTTER (go_router)
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
context.go('/dashboard');
```

**Navegación programática:**
```dart
// Ir a una ruta
context.go('/dashboard');

// Ir con parámetros
context.push('/user/123');

// Volver atrás
context.pop();

// Reemplazar (como replace en React Router)
context.replace('/login');
```

---

## 🔌 HTTP Requests

Tu proyecto usa el paquete `http` (como axios):

```dart
// AXIOS
const response = await axios.post('/api/login', { email, password });

// FLUTTER
final response = await http.post(
  Uri.parse('$baseUrl/api/login'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'email': email, 'password': password}),
);
```

**Parseando JSON:**
```dart
// JAVASCRIPT
const data = await response.json();

// DART
final Map<String, dynamic> data = json.decode(response.body);
```

---

## 💉 Dependency Injection (GetIt)

Tu proyecto usa **GetIt** (como Angular DI o Context en React):

```dart
// ANGULAR
@Injectable()
export class AuthService { }

constructor(private authService: AuthService) { }

// FLUTTER
// Registrar en dependency_injection.dart
getIt.registerLazySingleton<AuthService>(() => AuthService());

// Usar en cualquier lado
final authService = GetIt.instance<AuthService>();
```

---

## 🎨 Styling

No hay CSS. Todo se hace con clases:

```dart
// CSS
.button {
  background-color: blue;
  padding: 16px;
  border-radius: 8px;
}

// FLUTTER
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Click me'),
)
```

**Tu proyecto tiene estilos predefinidos en:**
- `lib/theme/theme.dart` - Tema global
- `lib/theme/colors_pallete.dart` - Paleta de colores
- `lib/utils/constants.dart` - Estilos reutilizables

---

## 📦 State Management

Tu proyecto usa:
1. **setState()** - Para estado local (como useState)
2. **Provider** - Para estado global (como Context API o Redux)

```dart
// REACT
const [count, setCount] = useState(0);

// FLUTTER
int count = 0;
setState(() => count++);
```

**Provider (estado global):**
```dart
// REACT CONTEXT
const { user } = useContext(UserContext);

// FLUTTER PROVIDER
final user = Provider.of<User>(context);
```

---

## 🌐 Internacionalización (i18n)

Tu proyecto tiene **español e inglés**:

```dart
// Archivo: lib/l10n/app_localizations.dart
AppLocalizations.of(context)!.welcome // "Bienvenido" o "Welcome"
```

Cambiar idioma:
```dart
final languageService = GetIt.instance<LanguageService>();
languageService.changeLanguage('es'); // Español
languageService.changeLanguage('en'); // English
```

---

## 🗄️ Almacenamiento Local

Tu proyecto usa **shared_preferences** (como localStorage o AsyncStorage):

```dart
// JAVASCRIPT
localStorage.setItem('token', token);
const token = localStorage.getItem('token');

// FLUTTER
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', token);
final token = prefs.getString('token');
```

Para datos sensibles (como tokens JWT), usa **flutter_secure_storage**:

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'jwt', value: token);
final token = await storage.read(key: 'jwt');
```

---

## 🔐 Autenticación

Tu `AuthService` tiene estos métodos:

```dart
// Registro
await authService.register(
  username: 'user',
  email: 'user@example.com',
  password: 'pass123',
);

// Login
await authService.login('user@example.com', 'pass123');

// Verificar email
await authService.verifyEmail(email: 'user@example.com', code: '123456');

// Reset password
await authService.requestPasswordReset(email: 'user@example.com');
```

---

## 🎯 Manejo de Errores

Tu proyecto tiene un wrapper `ApiResponse<T>`:

```dart
final response = await authService.login(email, password);

if (response.success) {
  // Login exitoso
  final user = response.data;
  print(user.email);
} else {
  // Error
  print(response.error);
  showErrorDialog(response.message);
}
```

Similar a:
```typescript
// TYPESCRIPT
type ApiResponse<T> = 
  | { success: true; data: T }
  | { success: false; error: string };
```

---

## 🧪 Testing

Flutter tiene testing integrado:

```dart
// lib/features/auth/services/auth_service_test.dart
test('login should return user on success', () async {
  final authService = AuthService();
  final result = await authService.login('test@test.com', 'password');
  
  expect(result.success, true);
  expect(result.data, isNotNull);
});
```

---

## 🚀 Comandos Importantes

```bash
# Instalar dependencias (npm install)
flutter pub get

# Ejecutar la app (npm start)
flutter run

# Ejecutar en modo release
flutter run --release

# Hot reload (ya viene incluido automáticamente)
# Presiona 'r' en la terminal mientras corre

# Hot restart (reload completo)
# Presiona 'R' en la terminal

# Ver dispositivos disponibles
flutter devices

# Limpiar build (rm -rf node_modules)
flutter clean

# Ver dependencias desactualizadas
flutter pub outdated

# Actualizar dependencias
flutter pub upgrade

# Generar código (para riverpod, freezed, etc.)
flutter pub run build_runner build
```

---

## 🐛 Debugging

```dart
// console.log()
print('Hello world');

// console.debug() - más profesional
debugPrint('Debug info');

// Breakpoints
// Usa el debugger de VS Code o Android Studio
```

**DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Tiene inspector de widgets, profiler, network inspector, etc.

---

## 📱 Diferencias Clave con React Native

| React Native | Flutter | Notas |
|-------------|---------|-------|
| JavaScript/TypeScript | Dart | Dart es más tipado |
| Components | Widgets | Todo es un widget |
| StyleSheet | Theme/Styles | Estilos en código |
| Flexbox | Column/Row | Similar pero diferente |
| useState | setState | Manejo de estado |
| useEffect | initState/dispose | Lifecycle hooks |
| AsyncStorage | SharedPreferences | Almacenamiento |
| React Navigation | go_router | Navegación |
| Axios | http package | HTTP requests |

---

## ⚡ Hot Tips

1. **Hot Reload es TU MEJOR AMIGO** - Presiona `r` y ves cambios al instante
2. **Usa const** - `const Text('hello')` mejora performance
3. **final vs var** - Usa `final` siempre que puedas (como `const` en JS)
4. **Null Safety** - Dart obliga null safety, usa `?` y `!` correctamente
5. **BuildContext** - Siempre se pasa como primer parámetro
6. **async/await** - Igual que en JS, pero con `Future<T>`
7. **Streams** - Como Observables en RxJS
8. **Widgets tree** - Piensa en composición, no herencia

---

## 🔨 Próximos Pasos en Tu Proyecto

1. ✅ **Endpoints centralizados** - Ya creado `AppConfig`
2. ⚠️ **Actualizar servicios** - Dashboard, Stats, Spike
3. ❌ **Implementar servicios faltantes** - Store, Settings, FAQs
4. 🚀 **Agregar interceptor HTTP** para logs y refresh token
5. 🧪 **Testing** - Unit y widget tests
6. 📱 **Optimización** - Performance y UX

---

## 📚 Recursos

- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [GetIt DI](https://pub.dev/packages/get_it)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

---

**Recuerda:** Flutter es **declarativo**, como React. Describe lo que quieres ver, no cómo construirlo paso a paso.

¡Ahora eres oficialmente un dev de Flutter! 🎉
