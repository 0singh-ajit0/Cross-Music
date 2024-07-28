import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/server_constants.dart';
import '../../../core/failure/failure.dart';
import '../../../core/models/user_model.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<Failure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ServerConstants.serverURL}/auth/signup"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );
      final responseBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        return Left(Failure(responseBodyMap["detail"]));
      }

      return Right(UserModel.fromMap(responseBodyMap));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ServerConstants.serverURL}/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final responseBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(responseBodyMap["detail"]));
      }

      return Right(UserModel.fromMap(responseBodyMap["user"]).copyWith(
        token: responseBodyMap["token"],
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${ServerConstants.serverURL}/auth/"),
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      );

      final responseBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(Failure(responseBodyMap["detail"]));
      }

      return Right(UserModel.fromMap(responseBodyMap).copyWith(
        token: token,
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
