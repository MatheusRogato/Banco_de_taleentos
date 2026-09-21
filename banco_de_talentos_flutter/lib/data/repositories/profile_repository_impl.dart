import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../core/errors/failures.dart';
import '../../core/errors/supabase_error_parser.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/work_experience.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/sector.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/supabase_datasource.dart';
import '../datasources/local_profile_datasource.dart';
import '../models/work_experience_model.dart';
import '../models/course_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseDatasource datasource;
  final LocalProfileDatasource localDatasource;
  final sb.SupabaseClient supabaseClient;

  ProfileRepositoryImpl(
    this.datasource,
    this.localDatasource,
    this.supabaseClient,
  );

  String? get _currentUserId => supabaseClient.auth.currentUser?.id;

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      final profileModel = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profileModel);
      return Right(profileModel);
    } catch (e) {
      try {
        final cachedProfile = await localDatasource.getLastProfile();
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
        return Left(ServerFailure(
            'Sem conexão e sem dados em cache: ${SupabaseErrorParser.parse(e)}'));
      } catch (cacheErr) {
        return Left(ServerFailure(
            'Erro ao carregar do cache offline: ${SupabaseErrorParser.parse(cacheErr)}'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileAvailability(
      bool isAvailable) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      await datasource.updateProfileAvailability(userId, isAvailable);
      final cachedProfile = await localDatasource.getLastProfile();
      if (cachedProfile != null) {
        await localDatasource
            .cacheProfile(cachedProfile.copyWith(isAvailable: isAvailable));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileSectors(
      List<int> sectorIds) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      await datasource.updateProfileSectors(userId, sectorIds);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileDetails(Profile profile) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      await datasource.updateProfileDetails(
        userId,
        profile.fullName,
        profile.phone,
        profile.city,
        profile.bio,
      );
      final updatedProfile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(updatedProfile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, WorkExperience>> addWorkExperience(
      WorkExperience experience) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      final model = WorkExperienceModel(
        id: '',
        profileId: userId,
        jobTitle: experience.jobTitle,
        company: experience.company,
        startDate: experience.startDate,
        endDate: experience.endDate,
        isCurrent: experience.isCurrent,
        description: experience.description,
      );
      final addedModel = await datasource.addWorkExperience(model);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return Right(addedModel);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateWorkExperience(
      WorkExperience experience) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      final model = WorkExperienceModel(
        id: experience.id,
        profileId: userId,
        jobTitle: experience.jobTitle,
        company: experience.company,
        startDate: experience.startDate,
        endDate: experience.endDate,
        isCurrent: experience.isCurrent,
        description: experience.description,
      );
      await datasource.updateWorkExperience(model);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkExperience(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      await datasource.deleteWorkExperience(id);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, Course>> addCourse(
      Course course, String? localFilePath) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      final model = CourseModel(
        id: '',
        profileId: userId,
        name: course.name,
        institution: course.institution,
        status: course.status,
        certificateUrl: course.certificateUrl,
      );
      final addedModel = await datasource.addCourse(model, localFilePath);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return Right(addedModel);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateCourse(
      Course course, String? localFilePath) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      final model = CourseModel(
        id: course.id,
        profileId: userId,
        name: course.name,
        institution: course.institution,
        status: course.status,
        certificateUrl: course.certificateUrl,
      );
      await datasource.updateCourse(model, localFilePath);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(ServerFailure('Usuário não autenticado'));
    }

    try {
      await datasource.deleteCourse(id);
      final profile = await datasource.getProfile(userId);
      await localDatasource.cacheProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, List<Sector>>> getSectors() async {
    try {
      final sectors = await datasource.getSectors();
      return Right(sectors);
    } catch (e) {
      return Left(ServerFailure(SupabaseErrorParser.parse(e)));
    }
  }

  @override
  Future<Either<Failure, String>> uploadResume(dynamic fileInput) async {
    final userId = _currentUserId;
    if (userId == null) {
      return const Left(
          ServerFailure('Usuário não autenticado para enviar currículo.'));
    }

    try {
      final resumeUrl = await datasource.uploadResume(userId, fileInput);
      final cachedProfile = await localDatasource.getLastProfile();
      if (cachedProfile != null) {
        await localDatasource
            .cacheProfile(cachedProfile.copyWith(resumeUrl: resumeUrl));
      }

      return Right(resumeUrl);
    } catch (e) {
      return Left(ServerFailure(
          'Erro ao enviar currículo: ${SupabaseErrorParser.parse(e)}'));
    }
  }
}
