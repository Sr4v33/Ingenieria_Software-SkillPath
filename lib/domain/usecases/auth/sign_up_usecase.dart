// lib/domain/usecases/auth/sign_up_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validaciones
    if (fullName.trim().isEmpty) {
      return const Left(ValidationFailure('El nombre es requerido'));
    }

    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Email inválido'));
    }

    if (password.isEmpty || password.length < 6) {
      return const Left(ValidationFailure('La contraseña debe tener al menos 6 caracteres'));
    }

    return await repository.signUp(email, password, fullName);
  }
}