
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:jolutrip_app/core/errors/failures.dart';

enum ImageSource { gallery, camera }

abstract class ImagePickerRepository {
  Future<Either<Failure, Uint8List>> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  });
}