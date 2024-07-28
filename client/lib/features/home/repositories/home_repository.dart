import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/server_constants.dart';
import '../../../core/failure/failure.dart';
import '../models/song_model.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<Failure, String>> uploadSong({
    required File audioFile,
    required File thumbnailFile,
    required String songName,
    required String artist,
    required String colorHexCode,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ServerConstants.serverURL}/song/upload"),
      );

      request
        ..files.addAll([
          await http.MultipartFile.fromPath("song", audioFile.path),
          await http.MultipartFile.fromPath("thumbnail", thumbnailFile.path),
        ])
        ..fields.addAll({
          "song_name": songName,
          "artist": artist,
          "color_hex_code": colorHexCode,
        })
        ..headers.addAll({
          "x-auth-token": token,
        });

      final response = await request.send();

      if (response.statusCode != 201) {
        return Left(Failure(await response.stream.bytesToString()));
      }

      return Right(await response.stream.bytesToString());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<SongModel>>> getAllSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse("${ServerConstants.serverURL}/song/list"),
        headers: {
          "x-auth-token": token,
          "Content-Type": "application/json",
        },
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Failure(resBodyMap["detail"]));
      }

      List<SongModel> songs = [];
      resBodyMap = resBodyMap as List;

      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${ServerConstants.serverURL}/song/favorite"),
        headers: {
          "x-auth-token": token,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "song_id": songId,
        }),
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Failure(resBodyMap["detail"]));
      }

      return Right(resBodyMap["message"]);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<SongModel>>> getAllFavSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse("${ServerConstants.serverURL}/song/list/favorites"),
        headers: {
          "x-auth-token": token,
          "Content-Type": "application/json",
        },
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Failure(resBodyMap["detail"]));
      }

      List<SongModel> songs = [];
      resBodyMap = resBodyMap as List;

      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map["song"]));
      }
      return Right(songs);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
