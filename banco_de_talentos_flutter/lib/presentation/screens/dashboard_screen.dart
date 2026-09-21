import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../cubits/profile/profile_cubit.dart';
import '../cubits/profile/profile_state.dart';
import '../widgets/dashboard/availability_card.dart';
import '../widgets/dashboard/stats_grid.dart';
import '../widgets/dashboard/journey_preview.dart';
import '../components/custom_toast.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildStatusBanner(BuildContext context, bool isAvailable) {
    final Color tintColor =
        isAvailable ? const Color(0xFF6CF8BB) : Colors.white60;
    final Color borderTintColor = isAvailable
        ? const Color(0xFF6CF8BB).withOpacity(0.4)
        : Colors.white.withOpacity(0.15);
    final String statusText = isAvailable
        ? 'Seu perfil está visível para os recrutadores de Coruripe e região. Fique de olho no seu WhatsApp!'
        : 'Seu perfil está oculto nas buscas. Ative o modo "Estou Livre" acima para ser encontrado por hotéis e restaurantes!';
    final IconData icon = isAvailable ? Icons.radar : Icons.radar_outlined;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isAvailable ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderTintColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: tintColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: isAvailable ? Colors.white : Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
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
        if (state is ProfileError) {
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
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (state is ProfileError && state is! ProfileLoaded) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar perfil: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = (state as ProfileLoaded).profile;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: CustomScrollView(
              slivers: [
                // Top AppBar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 100.0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(
                        left: 20.0, top: 32.0, bottom: 12.0),
                    title: Row(
                      children: [
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bem-vindo',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            ),
                            Text(
                              'Olá, ${profile.fullName.split(' ').first}!',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvailabilityCard(isAvailable: profile.isAvailable),
                        const SizedBox(height: 20),
                        _buildStatusBanner(context, profile.isAvailable),
                        const SizedBox(height: 20),
                        StatsGrid(
                          experiencesCount: profile.workExperiences.length,
                          coursesCount: profile.courses.length,
                        ),
                        const SizedBox(height: 28),
                        JourneyPreview(profile: profile),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
