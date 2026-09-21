import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String fullName;
  final String documentId;

  RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.documentId,
  });
}

@lazySingleton
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      documentId: params.documentId,
    );
  }
}
