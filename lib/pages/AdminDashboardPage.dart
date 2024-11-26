import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminDashboardPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E2A47),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2A47),
        title: Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Gestión de Actividades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            
            FutureBuilder<int>(
              future: _firestoreService.getActivityCount(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error al cargar actividades',
                    style: TextStyle(color: Colors.white),
                  );
                }
                final count = snapshot.data ?? 0;
                return Text(
                  'Actividades totales: $count',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/manageActivities');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1E2A47),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              icon: Icon(Icons.manage_accounts),
              label: Text('Gestionar Actividades'),
            ),
          ],
        ),
      ),
    );
  }
}
