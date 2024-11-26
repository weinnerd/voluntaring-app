import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el rol del usuario actual
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
      return null;
    }
  }
// Obtener el stream de una actividad específica
Stream<Activity> getActivityStream(String id) {
  try {
    return _firestore.collection('activities').doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Activity.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
      } else {
        throw Exception('Actividad no encontrada');
      }
    });
  } catch (e) {
    print('Error al obtener el stream de la actividad: $e');
    throw Exception('Error al obtener el stream de la actividad');
  }
}

  // Agregar nueva actividad
  Future<void> addActivity(Activity activity) async {
    try {
      await _firestore.collection('activities').add(activity.toMap());
    } catch (e) {
      print('Error al agregar actividad: $e');
    }
  }
  Future<int> getActivityCount() async {
  try {
    final snapshot = await _firestore.collection('activities').get();
    return snapshot.docs.length;
  } catch (e) {
    print('Error al contar actividades: $e');
    return 0;
  }
}
// Obtener historial de participación de un voluntario
Stream<List<Map<String, dynamic>>> getUserParticipationHistory(String userId) {
  return _firestore
      .collection('participants')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return doc.data();
    }).toList();
  });
}

// Obtener perfil del usuario
Future<Map<String, dynamic>?> getUserProfile(String userId) async {
  try {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  } catch (e) {
    print('Error al obtener el perfil del usuario: $e');
    return null;
  }
}


  // Actualizar actividad existente
  Future<void> updateActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .update(activity.toMap());
    } catch (e) {
      print('Error al actualizar actividad: $e');
    }
  }

  // Eliminar actividad
  Future<void> deleteActivity(String id) async {
    try {
      await _firestore.collection('activities').doc(id).delete();
    } catch (e) {
      print('Error al eliminar actividad: $e');
    }
  }

  // Obtener actividades en tiempo real
  Stream<List<Activity>> getActivities() {
    return _firestore.collection('activities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Inscribirse en una actividad
Future<String> registerForActivity(String activityId, String email) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Debes iniciar sesión para registrarte en esta actividad.';
    }

    final participantRef = FirebaseFirestore.instance
        .collection('activities') // Colección principal
        .doc(activityId) // Documento de la actividad
        .collection('participants') // Sub-colección de participantes
        .doc(user.uid); // Documento único por participante

    final participantSnapshot = await participantRef.get();

    if (participantSnapshot.exists) {
      return 'Ya estás registrado en esta actividad.';
    }

    await participantRef.set({
      'userId': user.uid, // ID único del usuario
      'email': email, // Correo del usuario
      'registeredAt': FieldValue.serverTimestamp(), // Fecha de registro
      'attendanceConfirmed': false, // Valor predeterminado para asistencia
    });

    return 'Te has registrado exitosamente en la actividad.';
  } catch (e) {
    print('Error al inscribirse en la actividad: $e');
    return 'Hubo un error al intentar registrarte.';
  }
}
Future<String> confirmAttendance(String activityId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Debes iniciar sesión para confirmar tu asistencia.';
    }

    final participantRef = FirebaseFirestore.instance
        .collection('activities')
        .doc(activityId)
        .collection('participants')
        .doc(user.uid);

    final participantSnapshot = await participantRef.get();

    if (!participantSnapshot.exists) {
      return 'No estás registrado en esta actividad.';
    }

    await participantRef.update({
      'attendanceConfirmed': true,
    });

    return 'Asistencia confirmada exitosamente.';
  } catch (e) {
    print('Error al confirmar asistencia: $e');
    return 'Hubo un error al confirmar tu asistencia.';
  }
}
  // Registrar feedback post-evento
  Future<void> submitFeedback(String activityId, String feedback) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('activities')
          .doc(activityId)
          .collection('feedback')
          .add({
        'feedback': feedback,
        'userId': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al enviar feedback: $e');
    }
  }

  // Obtener feedback de una actividad
  Stream<List<Map<String, dynamic>>> getFeedback(String activityId) {
    return _firestore
        .collection('activities')
        .doc(activityId)
        .collection('feedback')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }


  // Registrar asistencia
  Future<void> updateParticipantAttendance(
      String activityId, String email, bool attendance) async {
    try {
      final participantsRef = _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .where('email', isEqualTo: email);

      final snapshot = await participantsRef.get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'attendanceConfirmed': attendance,
        });
      }
    } catch (e) {
      print('Error al actualizar la asistencia: $e');
    }
  }
  Future<String> finalizeActivity(String activityId) async {
  try {
    final participantsSnapshot = await _firestore
        .collection('activities')
        .doc(activityId)
        .collection('participants')
        .where('attendanceConfirmed', isEqualTo: true)
        .get();

    if (participantsSnapshot.docs.isEmpty) {
      return 'No hay participantes confirmados para esta actividad.';
    }

    // Actualiza el historial de los voluntarios
    for (var doc in participantsSnapshot.docs) {
      final participant = doc.data();
      final userId = participant['userId'];

      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('history')
            .add({
          'activityId': activityId,
          'title': (await _firestore.collection('activities').doc(activityId).get())
              .data()?['title'],
          'date': FieldValue.serverTimestamp(),
        });
      }
    }

    // Marca la actividad como finalizada
    await _firestore.collection('activities').doc(activityId).update({
      'status': 'finalizada',
    });

    return 'Actividad finalizada exitosamente.';
  } catch (e) {
    print('Error al finalizar actividad: $e');
    return 'Hubo un error al finalizar la actividad.';
  }
}




  // Obtener historial del voluntario
Future<List<Map<String, dynamic>>> getVolunteerHistory() async {
  try {
    final user = _auth.currentUser;
    if (user == null) return [];

    final historySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('date', descending: true)
        .get();

    return historySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Error al obtener el historial del usuario: $e');
    return [];
  }
}


  // Obtener participantes de una actividad
  Stream<List<Map<String, dynamic>>> getParticipants(String activityId) {
    return _firestore
        .collection('activities')
        .doc(activityId)
        .collection('participants')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Contar participantes de una actividad
  Future<int> getParticipantCount(String activityId) async {
    try {
      final participants = await _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .get();

      return participants.docs.length;
    } catch (e) {
      print('Error al contar participantes: $e');
      return 0;
    }
  }
}
 
