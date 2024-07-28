import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:client/features/home/models/fav_song_model.dart';

class UserModel {
  final String id;
  final String token;
  final String name;
  final String email;
  final List<FavSongModel> favorites;

  UserModel({
    required this.id,
    required this.token,
    required this.name,
    required this.email,
    required this.favorites,
  });

  UserModel copyWith({
    String? id,
    String? token,
    String? name,
    String? email,
    List<FavSongModel>? favorites,
  }) {
    return UserModel(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      email: email ?? this.email,
      favorites: favorites ?? this.favorites,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'token': token,
      'name': name,
      'email': email,
      'favorites': favorites.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? "",
      token: map['token'] ?? "",
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      favorites: List<FavSongModel>.from(
        (map['favorites'] ?? []).map<FavSongModel>(
          (x) => FavSongModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, token: $token, name: $name, email: $email, favorites: $favorites)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.token == token &&
        other.name == name &&
        other.email == email &&
        listEquals(other.favorites, favorites);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        token.hashCode ^
        name.hashCode ^
        email.hashCode ^
        favorites.hashCode;
  }
}
