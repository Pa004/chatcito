class Mensaje {
  final String? id;
  final String texto;
  final String autor;
  final String autorId;
  final int timestamp;
  final bool editado;

  Mensaje({
    this.id,
    required this.texto,
    required this.autor,
    required this.autorId,
    required this.timestamp,
    this.editado = false,
  });

  factory Mensaje.fromJson(Map<dynamic, dynamic> json, {String? id}) {
    return Mensaje(
      id: id ?? json['id'] as String?,
      texto: json['texto'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      autorId: json['autorId'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
      editado: json['editado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'texto': texto,
      'autor': autor,
      'autorId': autorId,
      'timestamp': timestamp,
      'editado': editado,
    };
  }

  Mensaje copyWith({String? id, String? texto, bool? editado}) {
    return Mensaje(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      autor: autor,
      autorId: autorId,
      timestamp: timestamp,
      editado: editado ?? this.editado,
    );
  }
}
