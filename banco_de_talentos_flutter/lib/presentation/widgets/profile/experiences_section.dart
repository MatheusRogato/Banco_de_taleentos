import 'package:flutter/material.dart';
import '../../../domain/entities/work_experience.dart';

class ExperiencesSection extends StatelessWidget {
  final List<WorkExperience> experiences;
  final Function(WorkExperience) onEditPressed;
  final Function(String) onDeletePressed;
  final VoidCallback onAddPressed;

  const ExperiencesSection({
    super.key,
    required this.experiences,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Experiência Profissional',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Adicionar',
                  style: TextStyle(color: Colors.white)),
              onPressed: onAddPressed,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (experiences.isEmpty)
          const Text(
            'Nenhuma experiência profissional cadastrada.',
            style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontStyle: FontStyle.italic),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: experiences.length,
            itemBuilder: (context, index) {
              final exp = experiences[index];
              final isLast = index == experiences.length - 1;

              String dateStr = '';
              if (exp.startDate != null) {
                final startYear = exp.startDate!.year;
                final endYear =
                    exp.isCurrent ? 'Presente' : (exp.endDate?.year ?? '');
                dateStr = '$startYear — $endYear';
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6CF8BB),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 16, color: Colors.white70),
                                      onPressed: () => onEditPressed(exp),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16, color: Colors.redAccent),
                                      onPressed: () => onDeletePressed(exp.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              exp.jobTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              exp.company,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            if (exp.description != null &&
                                exp.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                exp.description!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
