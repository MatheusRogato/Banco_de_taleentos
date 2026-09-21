import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String profileId;
  final String name;
  final String institution;
  final String status;
  final String? certificateUrl;

  const Course({
    required this.id,
    required this.profileId,
    required this.name,
    required this.institution,
    required this.status,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [
        id,
        profileId,
        name,
        institution,
        status,
        certificateUrl,
      ];
}
