class Usuario {
  final String uid;
  final String email;
  final String nombre;
  final String? fcmToken;

  Usuario({
    required this.uid,
    required this.email,
    required this.nombre,
    this.fcmToken,
  });

  factory Usuario.fromJson(Map<dynamic, dynamic> json, {required String uid}) {
    return Usuario(
      uid: uid,
      email: json['email'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nombre': nombre,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}
