import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/entities/profile.dart';
import '../../components/custom_toast.dart';

class ResumeSection extends StatelessWidget {
  final Profile profile;
  final Function(dynamic file)? onUploadPressed;
  final Function(String url)? onViewPressed;

  const ResumeSection({
    super.key,
    required this.profile,
    this.onUploadPressed,
    this.onViewPressed,
  });

  Future<void> _pickAndValidateResume(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final sizeInBytes = file.size;
        final sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 2.0) {
          if (context.mounted) {
            CustomToast.show(
              context,
              message:
                  'Erro: O currículo deve ter no máximo 2MB (Arquivo atual: ${sizeInMb.toStringAsFixed(1)} MB).',
              type: ToastType.error,
            );
          }
          return;
        }

        if (onUploadPressed != null) {
          onUploadPressed!(file);
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.show(
          context,
          message: 'Não foi possível selecionar o arquivo: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResume =
        profile.resumeUrl != null && profile.resumeUrl!.isNotEmpty;
    final accentGreen = const Color(0xFF10B981);
    final mintGreen = const Color(0xFF6CF8BB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Documento de Currículo (PDF)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Máx: 2 MB',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasResume
                      ? mintGreen.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: hasResume
                  ? _buildUploadedView(context, mintGreen)
                  : _buildEmptyView(context, accentGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context, Color accentColor) {
    return Column(
      children: [
        Icon(Icons.post_add_rounded,
            size: 44, color: Colors.white.withOpacity(0.8)),
        const SizedBox(height: 12),
        const Text(
          'Nenhum currículo anexado ainda',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          'Anexe seu currículo em PDF para facilitar a avaliação de donos de hotéis e restaurantes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined,
                color: Colors.white, size: 20),
            label: const Text(
              'Anexar Currículo PDF',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () => _pickAndValidateResume(context),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedView(BuildContext context, Color tintColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tintColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: tintColor),
                  const SizedBox(width: 5),
                  Text(
                    'Currículo PDF Ativo',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tintColor),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.sync_rounded,
                  size: 16, color: Colors.white70),
              label: const Text('Substituir',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () => _pickAndValidateResume(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currículo Profissional do Candidato',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Formato .PDF • Verificado pelo sistema',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined,
                color: Colors.white, size: 18),
            label: const Text('Visualizar ou Baixar Currículo',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (onViewPressed != null && profile.resumeUrl != null) {
                onViewPressed!(profile.resumeUrl!);
              }
            },
          ),
        ),
      ],
    );
  }
}
