import 'dart:convert';

class PokemonData {
  PokemonData({
    required this.id,
    required this.gen,
    required this.names,
    required this.types,
  });

  factory PokemonData.fromRawJson(String str) => PokemonData.fromJson(json.decode(str) as Map<String, dynamic>);

  factory PokemonData.fromJson(Map<String, dynamic> json) => PokemonData(
        id: json['id'] as int,
        gen: json['gen'] as int,
        names: Names.fromJson(json['names'] as Map<String, dynamic>),
        types: List<String>.from(json['types'].map((x) => x)),
      );

  final int id;
  final int gen;
  final Names names;
  final List<String> types;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'id': id,
        'gen': gen,
        'names': names.toJson(),
        'types': List<String>.from(types.map((x) => x)),
      };
}

class Names {
  Names({
    required this.en,
    required this.jp,
  });

  factory Names.fromRawJson(String str) => Names.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Names.fromJson(Map<String, dynamic> json) => Names(
        en: json['en'] as String,
        jp: json['jp'] as String,
      );

  final String en;
  final String jp;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'en': en,
        'jp': jp,
      };
}
