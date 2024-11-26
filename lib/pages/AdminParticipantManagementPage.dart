import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminParticipantManagementPage extends StatelessWidget {
  final String activityId; // ID de la actividad seleccionada
  final FirestoreService _firestoreService = FirestoreService();

  AdminParticipantManagementPage({required this.activityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Participantes'),
        backgroundColor: Color(0xFF1E2A47),
      ),
      backgroundColor: Color(0xFF1E2A47),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getParticipants(activityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay participantes registrados.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final participants = snapshot.data!;
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final email = participant['email'] ?? 'No especificado';
              final attendanceConfirmed = participant['attendanceConfirmed'] ?? false;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(
                    email,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Asistencia: ${attendanceConfirmed ? 'Confirmada' : 'Pendiente'}',
                  ),
                  trailing: Switch(
                    value: attendanceConfirmed,
                    onChanged: (value) async {
                      await _firestoreService.updateParticipantAttendance(
                        activityId,
                        email,
                        value,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Asistencia confirmada para $email'
                                : 'Asistencia pendiente para $email',
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
    );
  }
}
