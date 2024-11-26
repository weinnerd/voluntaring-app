import 'package:flutter/material.dart';
import 'package:volunteering_app/screens/activities_page.dart';
import '../services/firestore_service.dart';
import '../models/activity_model.dart';
import 'activity_form_page.dart';
import 'activity_detail_page.dart';

class AdminActivityListPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Actividades'),
        backgroundColor: Color(0xFF1E2A47),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityFormPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFF1E2A47),
      body: StreamBuilder<List<Activity>>(
        stream: _firestoreService.getActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay actividades disponibles.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final activities = snapshot.data!;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(
                    activity.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Fecha: ${activity.dateTime.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Editar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityFormPage(activity: activity),
                          ),
                        );
                      } else if (value == 'Eliminar') {
                        await _firestoreService.deleteActivity(activity.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Actividad eliminada')),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Editar',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'Eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
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
              );
            },
          );
        },
      ),
    );
  }
}
