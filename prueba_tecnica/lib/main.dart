import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:prueba_tecnica/screens/home-page.dart';
import 'package:prueba_tecnica/screens/login-page.dart';
import 'package:prueba_tecnica/screens/recargas_page.dart';
import 'package:prueba_tecnica/screens/profile_page.dart';
import 'package:prueba_tecnica/screens/historial_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puntored App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final String token;
  final String nombreUsuario;

  const MainScreen({
    super.key,
    required this.token,
    required this.nombreUsuario,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        token: widget.token,
        nombreUsuario: widget.nombreUsuario,
        onRealizarRecarga: _irARecargasPage,
      ),
      RecargasPage(token: widget.token),
      HistorialPage(token: widget.token),
      ProfilePage(
        token: widget.token,
        nombreUsuario: widget.nombreUsuario,
      ),
    ];
  }

  void _irARecargasPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Iconsax.mobile), label: 'Recargas'),
          BottomNavigationBarItem(
              icon: Icon(Iconsax.clock), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Perfil"),
        ],
      ),
    );
  }
}
