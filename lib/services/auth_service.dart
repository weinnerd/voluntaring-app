import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar usuario con email y contraseña
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Método para agregar detalles del usuario
  Future<void> addUserDetails({
    required String uid,
    required String name,
    required String age,
    required String phone,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'age': age,
        'phone': phone,
      });
    } catch (e) {
      print('Error al guardar los detalles del usuario: $e');
    }
  }

  // Método para iniciar sesión
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
  Future<String?> getUserRole() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc['role']; // Retorna el rol ('admin' o 'volunteer')
      }
    }
    return null;
  } catch (e) {
    print('Error al obtener el rol del usuario: $e');
    return null;
  }
}
}
