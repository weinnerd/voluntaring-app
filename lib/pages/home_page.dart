import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/activity_model.dart';
import 'activity_form_page.dart';
import 'activity_detail_page.dart';
import 'login_page.dart';
import 'AdminDashboardPage.dart';
import 'volunteer_history_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? selectedCategory = 'Todas';
  String? selectedLocation = 'Todas';
  DateTime? selectedDate;
  String searchQuery = '';
  String userRole = 'volunteer'; // Rol predeterminado

  final List<String> categories = [
    'Todas',
    'Educación',
    'Salud',
    'Medio Ambiente',
    'Cultura',
    'Nueva',
  ];

  final List<String> cities = [
    'Todas',
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Santa Marta',
    'Cúcuta',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _firestoreService.getUserRole();
    setState(() {
      userRole = role ?? 'volunteer';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E2A47),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2A47),
        title: Text(
          'Actividades de Voluntariado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (userRole == 'admin') // Botón para el panel de administración
            IconButton(
              icon: Icon(Icons.dashboard, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboardPage()),
                );
              },
            ),
          if (userRole == 'volunteer') // Botón para ver el historial del voluntario
            IconButton(
              icon: Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolunteerHistoryPage()),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Buscador
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar actividades...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filtro por categoría
                    DropdownButton<String>(
                      dropdownColor: Color(0xFF1E2A47),
                      style: TextStyle(color: Colors.white),
                      value: selectedCategory,
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    // Filtro por ubicación
                    DropdownButton<String>(
                      dropdownColor: Color(0xFF1E2A47),
                      style: TextStyle(color: Colors.white),
                      value: selectedLocation,
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),
                    // Filtro por fecha
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.white),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Activity>>(
              stream: _firestoreService.getActivities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay actividades disponibles.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  );
                }

                final activities = snapshot.data!.where((activity) {
                  final matchesSearch = searchQuery.isEmpty ||
                      activity.title.toLowerCase().contains(searchQuery) ||
                      activity.description.toLowerCase().contains(searchQuery);
                  final matchesCategory = selectedCategory == 'Todas' ||
                      activity.category == selectedCategory;
                  final matchesLocation = selectedLocation == 'Todas' ||
                      activity.location == selectedLocation;
                  final matchesDate = selectedDate == null ||
                      activity.dateTime.toLocal().year == selectedDate!.year &&
                      activity.dateTime.toLocal().month == selectedDate!.month &&
                      activity.dateTime.toLocal().day == selectedDate!.day;

                  return matchesSearch &&
                      matchesCategory &&
                      matchesLocation &&
                      matchesDate;
                }).toList();

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(activity.title),
                          subtitle: Text(activity.dateTime.toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityDetailPage(
                                  activity: activity,
                                  userRole: userRole,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para agregar actividad (solo admin)
          if (userRole == 'admin')
            FloatingActionButton(
              heroTag: 'addActivity',
              backgroundColor: Color(0xFF1E2A47),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityFormPage()),
                );
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
          SizedBox(width: 10),
         // Botón para estadísticas
FloatingActionButton(
  heroTag: 'statistics',
  backgroundColor: Color(0xFF1E2A47),
  onPressed: () {
    final user = FirebaseAuth.instance.currentUser; // Obtener usuario autenticado
    if (user != null) {
      Navigator.pushNamed(
        context,
        '/statistics',
        arguments: user.uid, // Pasar el ID del usuario actual
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para ver estadísticas.')),
      );
    }
  },
  child: Icon(Icons.bar_chart, color: Colors.white),
),

        ],
      ),
    );
  }
}
