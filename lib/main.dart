import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteering_app/pages/FeedbackFormPage.dart';
import 'package:volunteering_app/pages/UserProfilePage.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/AdminDashboardPage.dart';
import 'pages/ManageActivitiesPage.dart';
import 'pages/StatisticsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyB35sdalFgdUMS88_P9xtnHHOpZPlFyBRQ",
        authDomain: "volunterringapp.firebaseapp.com",
        projectId: "volunterringapp",
        storageBucket: "volunterringapp.appspot.com",
        messagingSenderId: "468033057050",
        appId: "1:468033057050:web:fba3c415baa5bf4e80fca3",
        measurementId: "G-TJWNTB5RK5",
      ),
    );
    runApp(MyApp());
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volunteering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1E2A47), // Fondo global de la app
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E2A47), // Color de la barra superior
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Texto blanco predeterminado
        ),
      ),
      initialRoute: '/login', // Ruta inicial
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/adminDashboard': (context) => AdminDashboardPage(),
        '/manageActivities': (context) => ManageActivitiesPage(userRole: ''),
        '/profile': (context) => UserProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/feedback') {
          final activityId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => FeedbackFormPage(activityId: activityId),
          );
        }
        if (settings.name == '/statistics') {
          final userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => StatisticsPage(userId: userId),
          );
        }
        return null; // Ruta no encontrada
      },
    );
  }
}
