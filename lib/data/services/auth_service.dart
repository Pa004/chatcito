import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> registrar({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _usersRef.child(cred.user!.uid).set({
      'email': email,
      'nombre': nombre,
    });
    return cred;
  }

  Future<UserCredential> iniciarSesion({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  Future<void> actualizarFcmToken(String? token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || token == null) return;
    await _usersRef.child(uid).update({'fcmToken': token});
  }
}
