import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phone);
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp(
    String phone,
    String code,
  );
}
