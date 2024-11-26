import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Actividades'),
        backgroundColor: Color(0xFF1E2A47),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('history') // Subcolección con el historial del usuario
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay actividades en tu historial.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final history = snapshot.data!.docs;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(item['title'] ?? 'Sin título'),
                subtitle: Text(
                  'Fecha: ${item['date'] != null ? (item['date'] as Timestamp).toDate() : 'Sin fecha'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
