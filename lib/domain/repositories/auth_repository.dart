// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn(String email, String password);
  Future<Either<Failure, User>> signUp(String email, String password, String fullName);
  Future<Either<Failure, void>> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}