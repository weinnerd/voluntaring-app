import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verifica si el usuario está inscrito
  Future<bool> isUserRegistered(String activityId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final participantSnapshot = await _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .doc(user.uid)
          .get();

      return participantSnapshot.exists;
    } catch (e) {
      print('Error al verificar inscripción: $e');
      return false;
    }
  }

  // Registra al usuario en la actividad
  Future<String> registerForActivity(String activityId, String email) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Debes iniciar sesión para registrarte en esta actividad.';
      }

      final participantRef = _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .doc(user.uid);

      final participantSnapshot = await participantRef.get();

      if (participantSnapshot.exists) {
        return 'Ya estás registrado en esta actividad.';
      }

      await participantRef.set({
        'userId': user.uid,
        'email': email,
        'registeredAt': FieldValue.serverTimestamp(),
        'attendanceConfirmed': false,
      });

      return 'Te has registrado exitosamente en la actividad.';
    } catch (e) {
      print('Error al inscribirse en la actividad: $e');
      return 'Hubo un error al intentar registrarte.';
    }
  }
}
