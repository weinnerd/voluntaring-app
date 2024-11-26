import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime dateTime;
  final String status; // Estado de la actividad
  final int maxVolunteers; // Número máximo de voluntarios

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.dateTime,
    required this.status,
    required this.maxVolunteers, // Asegurar que esté incluido
  });

  factory Activity.fromMap(Map<String, dynamic> data, String documentId) {
    return Activity(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'En curso', // Valor predeterminado para estado
      maxVolunteers: data['maxVolunteers'] ?? 0, // Valor predeterminado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'dateTime': dateTime,
      'status': status, // Asegurar que se incluye el estado
      'maxVolunteers': maxVolunteers, // Agregar este campo al mapa
    };
  }
}
