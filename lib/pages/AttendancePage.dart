import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AttendancePage extends StatelessWidget {
  final String activityId;
  final FirestoreService _firestoreService = FirestoreService();

  AttendancePage({required this.activityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirmar Asistencia')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getParticipants(activityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay participantes registrados.'));
          }

          final participants = snapshot.data!;
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return ListTile(
                title: Text(participant['email']),
                trailing: Checkbox(
                  value: participant['attendanceConfirmed'] ?? false,
                  onChanged: (value) async {
                    await _firestoreService.updateParticipantAttendance(
                      activityId,
                      participant['email'],
                      value!,
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
