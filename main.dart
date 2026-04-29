import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/menu_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const HotelFoodApp());
}

class HotelFoodApp extends StatelessWidget {
  const HotelFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Dining',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF6B35),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          primary: const Color(0xFFFF6B35),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFFF6B35),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const TableResolverScreen(),
    );
  }
}

class TableResolverScreen extends StatelessWidget {
  const TableResolverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri uri = Uri.base;
    String tableId = uri.queryParameters['table'] ?? '';
    
    if (tableId.isEmpty) {
      return const NoTableScreen();
    }
    
    return MenuScreen(tableId: tableId);
  }
}

class NoTableScreen extends StatelessWidget {
  const NoTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please scan the QR code on your table',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}