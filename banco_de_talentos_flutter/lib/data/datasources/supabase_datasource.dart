import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:injectable/injectable.dart';
import '../models/profile_model.dart';
import '../models/work_experience_model.dart';
import '../models/course_model.dart';
import '../models/sector_model.dart';

abstract class SupabaseDatasource {
  Future<sb.AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<sb.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String documentId,
  });

  Future<void> signOut();

  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfileAvailability(String userId, bool isAvailable);
  Future<void> updateProfileSectors(String userId, List<int> sectorIds);
  Future<void> updateProfileDetails(
      String userId, String fullName, String? phone, String city, String? bio);

  Future<WorkExperienceModel> addWorkExperience(WorkExperienceModel experience);
  Future<void> updateWorkExperience(WorkExperienceModel experience);
  Future<void> deleteWorkExperience(String id);

  Future<CourseModel> addCourse(CourseModel course, String? localFilePath);
  Future<void> updateCourse(CourseModel course, String? localFilePath);
  Future<void> deleteCourse(String id);

  Future<List<SectorModel>> getSectors();

  Future<String> uploadResume(String userId, dynamic fileInput);
}

@LazySingleton(as: SupabaseDatasource)
class SupabaseDatasourceImpl implements SupabaseDatasource {
  final sb.SupabaseClient supabase;

  SupabaseDatasourceImpl(this.supabase);

  @override
  Future<sb.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<sb.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String documentId,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'document_id': documentId,
      },
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select(
            '*, work_experiences(*), courses(*), profile_sectors(sectors(*))')
        .eq('id', userId)
        .single();

    return ProfileModel.fromJson(response);
  }

  @override
  Future<void> updateProfileAvailability(
      String userId, bool isAvailable) async {
    await supabase
        .from('profiles')
        .update({'is_available': isAvailable}).eq('id', userId);
  }

  @override
  Future<void> updateProfileDetails(String userId, String fullName,
      String? phone, String city, String? bio) async {
    await supabase.from('profiles').update({
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'bio': bio,
    }).eq('id', userId);
  }

  @override
  Future<void> updateProfileSectors(String userId, List<int> sectorIds) async {
    await supabase.from('profile_sectors').delete().eq('profile_id', userId);

    if (sectorIds.isNotEmpty) {
      final insertData = sectorIds
          .map((sectorId) => {
                'profile_id': userId,
                'sector_id': sectorId,
              })
          .toList();

      await supabase.from('profile_sectors').insert(insertData);
    }
  }

  @override
  Future<WorkExperienceModel> addWorkExperience(
      WorkExperienceModel experience) async {
    final response = await supabase
        .from('work_experiences')
        .insert(experience.toJson())
        .select()
        .single();

    return WorkExperienceModel.fromJson(response);
  }

  @override
  Future<void> updateWorkExperience(WorkExperienceModel experience) async {
    await supabase
        .from('work_experiences')
        .update(experience.toJson())
        .eq('id', experience.id);
  }

  @override
  Future<void> deleteWorkExperience(String id) async {
    await supabase.from('work_experiences').delete().eq('id', id);
  }

  @override
  Future<CourseModel> addCourse(
      CourseModel course, String? localFilePath) async {
    String? certificateUrl = course.certificateUrl;

    if (localFilePath != null) {
      certificateUrl =
          await _uploadCertificate(course.profileId, localFilePath);
    }

    final courseData = course.toJson();
    if (certificateUrl != null) {
      courseData['certificate_url'] = certificateUrl;
    }

    final response =
        await supabase.from('courses').insert(courseData).select().single();

    return CourseModel.fromJson(response);
  }

  @override
  Future<void> updateCourse(CourseModel course, String? localFilePath) async {
    String? certificateUrl = course.certificateUrl;

    if (localFilePath != null) {
      certificateUrl =
          await _uploadCertificate(course.profileId, localFilePath);
    }

    final courseData = course.toJson();
    if (certificateUrl != null) {
      courseData['certificate_url'] = certificateUrl;
    }

    await supabase.from('courses').update(courseData).eq('id', course.id);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await supabase.from('courses').delete().eq('id', id);
  }

  @override
  Future<List<SectorModel>> getSectors() async {
    final response = await supabase.from('sectors').select().order('name');

    final list = response as List;
    return list
        .map((item) => SectorModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String?> _uploadCertificate(String userId, String filePath) async {
    final file = File(filePath);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
    final storagePath = '$userId/$fileName';

    try {
      await supabase.storage.from('certificates').upload(
            storagePath,
            file,
            fileOptions:
                const sb.FileOptions(cacheControl: '3600', upsert: false),
          );

      return supabase.storage.from('certificates').getPublicUrl(storagePath);
    } catch (e) {
      try {
        await supabase.storage.from('documents').upload(
              storagePath,
              file,
              fileOptions:
                  const sb.FileOptions(cacheControl: '3600', upsert: false),
            );
        return supabase.storage.from('documents').getPublicUrl(storagePath);
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<String> uploadResume(String userId, dynamic fileInput) async {
    final storagePath = '$userId/resume.pdf';

    if (fileInput is File) {
      await supabase.storage.from('resumes').upload(
            storagePath,
            fileInput,
            fileOptions:
                const sb.FileOptions(cacheControl: '3600', upsert: true),
          );
    } else if (fileInput is String) {
      final file = File(fileInput);
      await supabase.storage.from('resumes').upload(
            storagePath,
            file,
            fileOptions:
                const sb.FileOptions(cacheControl: '3600', upsert: true),
          );
    } else if (fileInput is Uint8List || fileInput is List<int>) {
      final bytes = fileInput is Uint8List
          ? fileInput
          : Uint8List.fromList(fileInput as List<int>);
      await supabase.storage.from('resumes').uploadBinary(
            storagePath,
            bytes,
            fileOptions:
                const sb.FileOptions(cacheControl: '3600', upsert: true),
          );
    } else {
      try {
        final path = (fileInput as dynamic).path as String?;
        final bytes = (fileInput as dynamic).bytes as Uint8List?;
        if (bytes != null) {
          await supabase.storage.from('resumes').uploadBinary(
                storagePath,
                bytes,
                fileOptions:
                    const sb.FileOptions(cacheControl: '3600', upsert: true),
              );
        } else if (path != null) {
          final file = File(path);
          await supabase.storage.from('resumes').upload(
                storagePath,
                file,
                fileOptions:
                    const sb.FileOptions(cacheControl: '3600', upsert: true),
              );
        } else {
          throw Exception(
              'Formato de arquivo não compatível para upload no storage.');
        }
      } catch (e) {
        throw Exception(
            'Falha ao processar arquivo do currículo para envio: $e');
      }
    }

    final publicUrl =
        supabase.storage.from('resumes').getPublicUrl(storagePath);
    await supabase
        .from('profiles')
        .update({'resume_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }
}
