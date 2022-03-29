import 'dart:convert';
import 'package:collection/collection.dart';

List<Pokemon> pokemonFromJson(String str) => List<Pokemon>.from(json.decode(str).map((x) => Pokemon.fromMap(x)));

class Pokemon {
  final int id;
  final int gen;
  final Names names;
  final List<String> types;
  Pokemon({
    required this.id,
    required this.gen,
    required this.names,
    required this.types,
  });

  Pokemon copyWith({
    int? id,
    int? gen,
    Names? names,
    List<String>? types,
  }) {
    return Pokemon(
      id: id ?? this.id,
      gen: gen ?? this.gen,
      names: names ?? this.names,
      types: types ?? this.types,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gen': gen,
      'names': names.toMap(),
      'types': types,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id']?.toInt(),
      gen: map['gen']?.toInt(),
      names: Names.fromMap(map['names']),
      types: List<String>.from(map['types']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pokemon.fromJson(String source) => Pokemon.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pokemon(id: $id, gen: $gen, names: $names, types: $types)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Pokemon && other.id == id && other.gen == gen && other.names == names && listEquals(other.types, types);
  }

  @override
  int get hashCode {
    return id.hashCode ^ gen.hashCode ^ names.hashCode ^ types.hashCode;
  }
}

class Names {
  final String en;
  final String jp;
  Names({
    required this.en,
    required this.jp,
  });

  Names copyWith({
    String? en,
    String? jp,
  }) {
    return Names(
      en: en ?? this.en,
      jp: jp ?? this.jp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'en': en,
      'jp': jp,
    };
  }

  factory Names.fromMap(Map<String, dynamic> map) {
    return Names(
      en: map['en'],
      jp: map['jp'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Names.fromJson(String source) => Names.fromMap(json.decode(source));

  @override
  String toString() => 'Names(en: $en, jp: $jp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Names && other.en == en && other.jp == jp;
  }

  @override
  int get hashCode => en.hashCode ^ jp.hashCode;
}
