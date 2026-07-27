class Chat {
  final String id;
  final List<String> participantes;
  final String? ultimoMensaje;
  final int? ultimoTimestamp;

  Chat({
    required this.id,
    required this.participantes,
    this.ultimoMensaje,
    this.ultimoTimestamp,
  });

  factory Chat.fromJson(Map<dynamic, dynamic> json, {required String id}) {
    final participantesMap = json['participantes'] as Map<dynamic, dynamic>? ?? {};
    return Chat(
      id: id,
      participantes: participantesMap.keys.cast<String>().toList(),
      ultimoMensaje: json['ultimoMensaje'] as String?,
      ultimoTimestamp: json['ultimoTimestamp'] as int?,
    );
  }

  String get otroUid {
    return participantes.length >= 2 ? participantes[1] : participantes.first;
  }
}
