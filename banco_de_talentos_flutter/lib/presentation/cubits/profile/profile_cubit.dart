import 'package:banco_de_talentos_flutter/domain/entities/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/update_profile_availability_usecase.dart';
import '../../../domain/usecases/manage_work_experience_usecase.dart';
import '../../../domain/usecases/manage_course_usecase.dart';
import '../../../domain/usecases/update_profile_sectors_usecase.dart';
import '../../../domain/usecases/update_profile_details_usecase.dart';
import '../../../domain/usecases/upload_resume_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileAvailabilityUseCase _updateProfileAvailabilityUseCase;
  final AddWorkExperienceUseCase _addWorkExperienceUseCase;
  final UpdateWorkExperienceUseCase _updateWorkExperienceUseCase;
  final DeleteWorkExperienceUseCase _deleteWorkExperienceUseCase;
  final AddCourseUseCase _addCourseUseCase;
  final UpdateCourseUseCase _updateCourseUseCase;
  final DeleteCourseUseCase _deleteCourseUseCase;
  final UpdateProfileSectorsUseCase _updateProfileSectorsUseCase;
  final UpdateProfileDetailsUseCase _updateProfileDetailsUseCase;
  final UploadResumeUseCase _uploadResumeUseCase;

  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileAvailabilityUseCase,
    this._addWorkExperienceUseCase,
    this._updateWorkExperienceUseCase,
    this._deleteWorkExperienceUseCase,
    this._addCourseUseCase,
    this._updateCourseUseCase,
    this._deleteCourseUseCase,
    this._updateProfileSectorsUseCase,
    this._updateProfileDetailsUseCase,
    this._uploadResumeUseCase,
  ) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await _getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> toggleAvailability(bool isAvailable) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final updatedProfile =
          currentState.profile.copyWith(isAvailable: isAvailable);
      emit(ProfileLoaded(updatedProfile));

      final result = await _updateProfileAvailabilityUseCase(isAvailable);
      result.fold(
        (failure) {
          // Revert on failure
          emit(ProfileLoaded(currentState.profile));
          emit(ProfileError(failure.message));
        },
        (_) => loadProfile(),
      );
    }
  }

  Future<void> addExperience(WorkExperience experience) async {
    emit(ProfileActionLoading());
    final result = await _addWorkExperienceUseCase(experience);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess('Experiência adicionada com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> updateExperience(WorkExperience experience) async {
    emit(ProfileActionLoading());
    final result = await _updateWorkExperienceUseCase(experience);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess('Experiência atualizada com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> deleteExperience(String id) async {
    emit(ProfileActionLoading());
    final result = await _deleteWorkExperienceUseCase(id);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess('Experiência removida com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> addCourse(Course course, String? localFilePath) async {
    emit(ProfileActionLoading());
    final result = await _addCourseUseCase(CourseParams(
      course: course,
      localFilePath: localFilePath,
    ));
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess(
            'Curso/Certificado adicionado com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> updateCourse(Course course, String? localFilePath) async {
    emit(ProfileActionLoading());
    final result = await _updateCourseUseCase(CourseParams(
      course: course,
      localFilePath: localFilePath,
    ));
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess(
            'Curso/Certificado atualizado com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> deleteCourse(String id) async {
    emit(ProfileActionLoading());
    final result = await _deleteCourseUseCase(id);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess(
            'Curso/Certificado removido com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> updateSectors(List<int> sectorIds) async {
    emit(ProfileActionLoading());
    final result = await _updateProfileSectorsUseCase(sectorIds);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess('Setores de atuação atualizados!'));
        loadProfile();
      },
    );
  }

  Future<void> updateProfileDetails(Profile profile) async {
    emit(ProfileActionLoading());
    final result = await _updateProfileDetailsUseCase(profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(const ProfileActionSuccess(
            'Detalhes do perfil atualizados com sucesso!'));
        loadProfile();
      },
    );
  }

  Future<void> uploadResume(dynamic fileInput) async {
    emit(ProfileActionLoading());
    final result = await _uploadResumeUseCase(fileInput);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (url) {
        emit(const ProfileActionSuccess(
            'Currículo em PDF anexado e sincronizado com sucesso!'));
        loadProfile();
      },
    );
  }
}
