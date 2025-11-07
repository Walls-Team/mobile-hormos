// import 'dart:async';
// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final GoRouter _router = GoRouter(
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const DefaultScreen(),
//       ),
//       GoRoute(
//         path: '/book/:bookId',
//         builder: (context, state) {
//           final bookId = state.pathParameters['bookId'] ?? 'None';
//           return CustomScreen(bookId: bookId);
//         },
//       ),
//       GoRoute(
//         path: '/book',
//         redirect: (context, state) => '/book/None', // Redirige a /book/None
//       ),
//     ],
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(child: Text('Error: ${state.error}')),
//     ),
//   );

//   StreamSubscription<Uri>? _linkSubscription;

//   @override
//   void initState() {
//     super.initState();
//     initDeepLinks();
//   }

//   @override
//   void dispose() {
//     _linkSubscription?.cancel();
//     super.dispose();
//   }

//   Future<void> initDeepLinks() async {
//     _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
//       debugPrint('onAppLink: $uri');
//       debugPrint('Fragment: ${uri.fragment}');
//       debugPrint('Path: ${uri.path}');
//       openAppLink(uri);
//     });
//   }

//   void openAppLink(Uri uri) {
//     // Usa Go Router para navegar en lugar de pushNamed
//     _router.go(uri.fragment);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//       title: 'My App Links',
//     );
//   }
// }

// class DefaultScreen extends StatelessWidget {
//   const DefaultScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Default Screen')),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SelectableText('''
//             Launch an intent to get to the second screen.
            
//             Test with: xcrun simctl openurl booted "myapplinks:///book/hello"
//             '''),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navegar programáticamente
//                 context.go('/book/flutter-test');
//               },
//               child: const Text('Test Navigation'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CustomScreen extends StatelessWidget {
//   final String bookId;

//   const CustomScreen({super.key, required this.bookId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Second Screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Opened with parameter: $bookId'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 context.go('/'); // Volver al home
//               },
//               child: const Text('Back to Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:genius_hormo/app/app.dart';

// void main() {
//   runApp(const MyApp());
// }


import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  await setupDependencies();
  
  runApp(const GeniusHormoApp());
}
