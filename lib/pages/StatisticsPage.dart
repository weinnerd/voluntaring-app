import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsPage extends StatelessWidget {
  final String userId;

  StatisticsPage({required this.userId});

  Future<Map<String, dynamic>> fetchGlobalStatistics() async {
    try {
      final activitiesSnapshot =
          await FirebaseFirestore.instance.collection('activities').get();

      int totalActivities = activitiesSnapshot.size;
      int totalVolunteers = 0;
      int totalHours = 0;

      for (var activityDoc in activitiesSnapshot.docs) {
        final participantsSnapshot =
            await activityDoc.reference.collection('participants').get();

        totalVolunteers += participantsSnapshot.size;

        // Manejar duración de actividad con validación
        final activityData = activityDoc.data();
        if (activityData.containsKey('duration') &&
            activityData['duration'] is num) {
          final activityDuration = activityData['duration'] as num;
          totalHours += (activityDuration.toInt() * participantsSnapshot.size);
        }
      }

      return {
        'totalActivities': totalActivities,
        'totalVolunteers': totalVolunteers,
        'totalHours': totalHours,
      };
    } catch (e) {
      print('Error al obtener estadísticas globales: $e');
      return {
        'totalActivities': 0,
        'totalVolunteers': 0,
        'totalHours': 0,
      };
    }
  }

  Future<Map<String, dynamic>> fetchPersonalStatistics(String userId) async {
  final activitiesSnapshot = await FirebaseFirestore.instance
      .collection('activities') // Buscar en la colección raíz.
      .get();

  int totalActivities = 0;
  int totalHours = 0;

  for (var activityDoc in activitiesSnapshot.docs) {
    // Buscar en la subcolección 'participants'.
    final participantsSnapshot = await activityDoc.reference
        .collection('participants')
        .where('userId', isEqualTo: userId)
        .get();

    if (participantsSnapshot.docs.isNotEmpty) {
      totalActivities++; // Contar actividades donde el usuario está registrado.

      // Sumar la duración de la actividad.
      final activityDuration = activityDoc.data()['duration'] ?? 0;
      totalHours += (activityDuration as num).toInt();
    }
  }

  return {
    'totalActivities': totalActivities,
    'totalHours': totalHours,
  };
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas'),
        backgroundColor: Color(0xFF1E2A47),
      ),
      backgroundColor: Color(0xFF1E2A47),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchGlobalStatistics(),
          builder: (context, globalSnapshot) {
            if (globalSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!globalSnapshot.hasData) {
              return Center(
                child: Text(
                  'No se pudieron cargar las estadísticas globales.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final globalStats = globalSnapshot.data!;

            return FutureBuilder<Map<String, dynamic>>(
              future: fetchPersonalStatistics(userId),
              builder: (context, personalSnapshot) {
                if (personalSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!personalSnapshot.hasData) {
                  return Center(
                    child: Text(
                      'No se pudieron cargar tus estadísticas.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final personalStats = personalSnapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas Globales:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Actividades totales'),
                          trailing: Text('${globalStats['totalActivities']}'),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Voluntarios totales'),
                          trailing: Text('${globalStats['totalVolunteers']}'),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Horas acumuladas'),
                          trailing: Text('${globalStats['totalHours']}'),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tus Estadísticas:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Actividades realizadas'),
                          trailing: Text('${personalStats['totalActivities']}'),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('Horas acumuladas'),
                          trailing: Text('${personalStats['totalHours']}'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
