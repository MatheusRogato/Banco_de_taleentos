import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/injection.dart';
import '../cubits/profile/profile_cubit.dart';
import '../cubits/profile/profile_state.dart';
import '../cubits/sectors/sectors_cubit.dart';
import '../cubits/sectors/sectors_state.dart';
import '../cubits/auth/auth_cubit.dart';
import '../../domain/entities/profile.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/sectors_section.dart';
import '../widgets/profile/experiences_section.dart';
import '../widgets/profile/courses_section.dart';
import '../widgets/profile/resume_section.dart';
import '../components/custom_toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showSectorsDialog(BuildContext context, Profile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProfileCubit>()),
            BlocProvider(
                create: (context) => getIt<SectorsCubit>()..loadSectors()),
          ],
          child: _SectorsMultiSelectDialog(profile: profile),
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Não foi possível abrir o link: $urlString');
      }
    } catch (e) {
      CustomToast.show(
        context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  void _confirmDeleteExperience(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Excluir Experiência'),
        content: const Text(
            'Tem certeza que deseja excluir esta experiência profissional?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileCubit>().deleteExperience(id);
              Navigator.pop(dContext);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCourse(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Excluir Curso'),
        content: const Text(
            'Tem certeza que deseja excluir este curso/certificação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileCubit>().deleteCourse(id);
              Navigator.pop(dContext);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBanner(bool isAvailable) {
    final bannerBg = Colors.white.withOpacity(0.1);
    final bannerBorder = isAvailable
        ? const Color(0xFF6CF8BB).withOpacity(0.5)
        : Colors.white.withOpacity(0.2);
    final bannerText = isAvailable ? const Color(0xFF6CF8BB) : Colors.white70;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bannerBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS ATUAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? 'Disponível para Eventos'
                        : 'Indisponível no Momento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bannerText,
                    ),
                  ),
                ],
              ),
              if (isAvailable)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6CF8BB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          CustomToast.show(
            context,
            message: state.message,
            type: ToastType.success,
          );
        } else if (state is ProfileError) {
          CustomToast.show(
            context,
            message: state.message,
            type: ToastType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = state is ProfileLoaded
            ? state.profile
            : (state is ProfileActionSuccess || state is ProfileActionLoading)
                ? (context.read<ProfileCubit>().state as ProfileLoaded).profile
                : null;

        if (profile == null) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
                child: Text('Erro ao carregar dados do perfil',
                    style: TextStyle(color: Colors.white))),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Currículo Profissional',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () {
                  getIt<AuthCubit>().logout();
                  context.go('/');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(profile: profile),
                  const SizedBox(height: 20),
                  _buildAvailabilityBanner(profile.isAvailable),
                  const SizedBox(height: 24),
                  ResumeSection(
                    profile: profile,
                    onUploadPressed: (fileInput) =>
                        context.read<ProfileCubit>().uploadResume(fileInput),
                    onViewPressed: (url) => _launchURL(context, url),
                  ),
                  const SizedBox(height: 28),
                  SectorsSection(
                    profile: profile,
                    onEditPressed: () => _showSectorsDialog(context, profile),
                  ),
                  const SizedBox(height: 28),
                  ExperiencesSection(
                    experiences: profile.workExperiences,
                    onAddPressed: () => context.push(
                      '/experience-form',
                      extra: {
                        'cubit': context.read<ProfileCubit>(),
                      },
                    ),
                    onEditPressed: (exp) => context.push(
                      '/experience-form',
                      extra: {
                        'cubit': context.read<ProfileCubit>(),
                        'experience': exp,
                      },
                    ),
                    onDeletePressed: (id) =>
                        _confirmDeleteExperience(context, id),
                  ),
                  const SizedBox(height: 28),
                  CoursesSection(
                    courses: profile.courses,
                    onAddPressed: () => context.push(
                      '/course-form',
                      extra: {
                        'cubit': context.read<ProfileCubit>(),
                      },
                    ),
                    onEditPressed: (course) => context.push(
                      '/course-form',
                      extra: {
                        'cubit': context.read<ProfileCubit>(),
                        'course': course,
                      },
                    ),
                    onDeletePressed: (id) => _confirmDeleteCourse(context, id),
                    onCertificatePressed: (url) => _launchURL(context, url),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectorsMultiSelectDialog extends StatefulWidget {
  final Profile profile;

  const _SectorsMultiSelectDialog({required this.profile});

  @override
  State<_SectorsMultiSelectDialog> createState() =>
      _SectorsMultiSelectDialogState();
}

class _SectorsMultiSelectDialogState extends State<_SectorsMultiSelectDialog> {
  final List<int> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.profile.sectors.map((s) => s.id));
  }

  String _translateSector(String enName) {
    switch (enName) {
      case 'Tourism':
        return 'Turismo';
      case 'Hospitality':
        return 'Hotelaria';
      case 'Gastronomy':
        return 'Gastronomia';
      case 'Events':
        return 'Eventos';
      case 'General Services':
        return 'Serviços Gerais';
      case 'Customer Service':
        return 'Atendimento';
      case 'Construction':
        return 'Construção Civil';
      default:
        return enName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Setores de Interesse'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: BlocBuilder<SectorsCubit, SectorsState>(
          builder: (context, state) {
            if (state is SectorsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SectorsError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            if (state is SectorsLoaded) {
              final allSectors = state.sectors;
              return ListView.builder(
                itemCount: allSectors.length,
                itemBuilder: (context, index) {
                  final sector = allSectors[index];
                  final isChecked = _selectedIds.contains(sector.id);

                  return CheckboxListTile(
                    title: Text(_translateSector(sector.name)),
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(sector.id);
                        } else {
                          _selectedIds.remove(sector.id);
                        }
                      });
                    },
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            context.read<ProfileCubit>().updateSectors(_selectedIds);
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
