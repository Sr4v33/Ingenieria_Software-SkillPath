// lib/domain/usecases/auth/sign_in_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
  }) async {
    // Validación básica
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Email inválido'));
    }

    if (password.isEmpty || password.length < 6) {
      return const Left(ValidationFailure('Contraseña muy corta'));
    }

    return await repository.signIn(email, password);
  }
}