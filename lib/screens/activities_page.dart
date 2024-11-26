import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import '../pages/activity_detail_page.dart'; // Asegúrate de importar el archivo correspondiente

String userRole = 'volunteer'; // Rol predeterminado

class ActivitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Actividades"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              // Implementar lógica de filtro
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('activities').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final activities = snapshot.data!.docs
              .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                title: Text(activity.title),
                subtitle: Text(activity.dateTime.toString()),
                trailing: Icon(Icons.arrow_forward),
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ActivityDetailPage(
        activity: activity,
        userRole: userRole, // Asegúrate de incluir esto
      ),
    ),
  );
},
              );
            },
          );
        },
      ),
    );
  }
}
