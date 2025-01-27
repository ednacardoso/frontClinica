class Usuario {
  final int id;
  final String descricao;

  Usuario({required this.id, required this.descricao});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      descricao: json['descricao'],
    );
  }
}
