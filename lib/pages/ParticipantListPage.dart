import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantListPage extends StatelessWidget {
  final String activityId;

  ParticipantListPage({required this.activityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes'),
        backgroundColor: Color(0xFF1E2A47),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .doc(activityId)
            .collection('participants')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ocurrió un error al cargar los participantes.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay participantes registrados.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final participants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index].data() as Map<String, dynamic>;
              final name = participant['name'] ?? 'Sin nombre';
              final email = participant['email'] ?? 'Sin email';
              final status = participant['status'] ?? 'Pendiente'; // Estado predeterminado

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF1E2A47),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      SizedBox(height: 4),
                      Text(
                        'Estado: $status',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: status == 'Asistió'
                              ? Colors.green
                              : status == 'Ausente'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      try {
                        if (value == 'Asistió') {
                          await participants[index].reference.update({'status': 'Asistió'});
                        } else if (value == 'Ausente') {
                          await participants[index].reference.update({'status': 'Ausente'});
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Estado actualizado a $value.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar el estado.')),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Asistió', child: Text('Asistió')),
                      PopupMenuItem(value: 'Ausente', child: Text('Ausente')),
                    ],
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
