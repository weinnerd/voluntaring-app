import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';
import 'FeedbackFormPage.dart';

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;
  final FirestoreService _firestoreService = FirestoreService();
  final String userRole; 
  
  ActivityDetailPage({required this.activity, required this.userRole});

  Future<bool> isUserRegistered(String activityId, String userId) async {
    final participantSnapshot = await FirebaseFirestore.instance
        .collection('activities')
        .doc(activityId)
        .collection('participants')
        .doc(userId)
        .get();

    return participantSnapshot.exists;
  }

  Future<void> registerUserForActivity(BuildContext context, String activityId, String userId, String email) async {
    try {
      final participantRef = FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .doc(userId);

      await participantRef.set({
        'userId': userId,
        'email': email,
        'registeredAt': FieldValue.serverTimestamp(),
        'attendanceConfirmed': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has inscrito exitosamente en esta actividad.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inscribirse: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = 'usuario_actual_id'; 
    final userEmail = 'usuario_actual_email'; 

    return Scaffold(
      backgroundColor: Color(0xFF1E2A47),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2A47),
        title: Text(
          'Detalles de la Actividad',
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
      body: StreamBuilder<Activity>(
        stream: _firestoreService.getActivityStream(activity.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No se encontró la actividad.'),
            );
          }

          final updatedActivity = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    updatedActivity.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),

                  
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Fecha: ${updatedActivity.dateTime.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Hora: ${updatedActivity.dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Ubicación: ${updatedActivity.location}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Categoría: ${updatedActivity.category}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                 
if (userRole == 'admin') ...[
  ElevatedButton(
    onPressed: () async {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(activity.id)
          .collection('participants')
          .doc(userId) 
          .update({'attendanceConfirmed': true}); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscripción confirmada')),
      );
    },
    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
    child: Text('Aceptar inscripción'),
  ),
  ElevatedButton(
    onPressed: () async {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(activity.id)
          .collection('participants')
          .doc(userId)
          .delete(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscripción cancelada')),
      );
    },
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    child: Text('Cancelar inscripción'),
  ),
],
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('activities')
      .doc(activity.id)
      .collection('feedback')
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Text(
        'No hay feedback para esta actividad.',
        style: TextStyle(color: Colors.white),
      );
    }

    final feedbackDocs = snapshot.data!.docs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback recibido:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ...feedbackDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Card(
            color: Colors.white,
            child: ListTile(
              title: Text(data['email'] ?? 'Anónimo'),
              subtitle: Text(data['feedback'] ?? 'Sin comentarios'),
              trailing: Text(
                data['submittedAt'] != null
                    ? (data['submittedAt'] as Timestamp).toDate().toString()
                    : 'Sin fecha',
              ),
            ),
          );
        }).toList(),
      ],
    );
  },
),

                  FutureBuilder<bool>(
                    future: isUserRegistered(updatedActivity.id, userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error al verificar la inscripción.',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      final isRegistered = snapshot.data ?? false;

                      if (isRegistered) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FeedbackFormPage(activityId: updatedActivity.id),
                              ),
                            );
                          },
                          child: Text('Enviar Feedback'),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: () async {
                            await registerUserForActivity(
                              context,
                              updatedActivity.id,
                              userId,
                              userEmail,
                            );
                          },
                          child: Text('Inscribirme'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
