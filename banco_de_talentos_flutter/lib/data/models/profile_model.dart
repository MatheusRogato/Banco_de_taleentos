import '../../domain/entities/profile.dart';
import 'sector_model.dart';
import 'work_experience_model.dart';
import 'course_model.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.role,
    required super.fullName,
    super.documentId,
    super.phone,
    required super.city,
    required super.isAvailable,
    super.bio,
    super.resumeUrl,
    super.sectors,
    super.workExperiences,
    super.courses,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    List<SectorModel> parsedSectors = [];
    if (json['profile_sectors'] != null) {
      final list = json['profile_sectors'] as List;
      parsedSectors = list
          .map((item) {
            if (item['sectors'] != null) {
              return SectorModel.fromJson(
                  item['sectors'] as Map<String, dynamic>);
            }
            return null;
          })
          .whereType<SectorModel>()
          .toList();
    } else if (json['sectors'] != null) {
      final list = json['sectors'] as List;
      parsedSectors = list
          .map((item) => SectorModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<WorkExperienceModel> parsedExperiences = [];
    if (json['work_experiences'] != null) {
      final list = json['work_experiences'] as List;
      parsedExperiences = list
          .map((item) =>
              WorkExperienceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<CourseModel> parsedCourses = [];
    if (json['courses'] != null) {
      final list = json['courses'] as List;
      parsedCourses = list
          .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'candidate',
      fullName: json['full_name'] as String? ?? 'New User',
      documentId: json['document_id'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String? ?? 'Coruripe',
      isAvailable: json['is_available'] as bool? ?? true,
      bio: json['bio'] as String?,
      resumeUrl: json['resume_url'] as String?,
      sectors: parsedSectors,
      workExperiences: parsedExperiences,
      courses: parsedCourses,
    );
  }

  @override
  ProfileModel copyWith({
    String? id,
    String? role,
    String? fullName,
    String? documentId,
    String? phone,
    String? city,
    bool? isAvailable,
    String? bio,
    String? resumeUrl,
    List<dynamic>? sectors,
    List<dynamic>? workExperiences,
    List<dynamic>? courses,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      documentId: documentId ?? this.documentId,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      isAvailable: isAvailable ?? this.isAvailable,
      bio: bio ?? this.bio,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      sectors: sectors != null
          ? List<SectorModel>.from(sectors)
          : this.sectors as List<SectorModel>,
      workExperiences: workExperiences != null
          ? List<WorkExperienceModel>.from(workExperiences)
          : this.workExperiences as List<WorkExperienceModel>,
      courses: courses != null
          ? List<CourseModel>.from(courses)
          : this.courses as List<CourseModel>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'document_id': documentId,
      'phone': phone,
      'city': city,
      'is_available': isAvailable,
      'bio': bio,
      'resume_url': resumeUrl,
      'sectors': sectors.map((s) => (s as SectorModel).toJson()).toList(),
      'work_experiences': workExperiences
          .map((e) => (e as WorkExperienceModel).toJson())
          .toList(),
      'courses': courses.map((c) => (c as CourseModel).toJson()).toList(),
    };
  }
}
