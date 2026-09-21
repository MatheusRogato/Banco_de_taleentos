import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/work_experience.dart';
import '../cubits/profile/profile_cubit.dart';
import '../components/custom_toast.dart';

class WorkExperienceFormScreen extends StatefulWidget {
  final WorkExperience? experience;

  const WorkExperienceFormScreen({super.key, this.experience});

  @override
  State<WorkExperienceFormScreen> createState() => _WorkExperienceFormScreenState();
}

class _WorkExperienceFormScreenState extends State<WorkExperienceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      final exp = widget.experience!;
      _jobTitleController.text = exp.jobTitle;
      _companyController.text = exp.company;
      _descriptionController.text = exp.description ?? '';
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _isCurrent = exp.isCurrent;
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      CustomToast.show(
        context,
        message: 'Selecione primeiro a data de início',
        type: ToastType.warning,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      CustomToast.show(
        context,
        message: 'Data de início é obrigatória',
        type: ToastType.warning,
      );
      return;
    }

    if (!_isCurrent && _endDate == null) {
      CustomToast.show(
        context,
        message: 'Data de término é obrigatória se não for trabalho atual',
        type: ToastType.warning,
      );
      return;
    }

    final experience = WorkExperience(
      id: widget.experience?.id ?? '',
      profileId: widget.experience?.profileId ?? '',
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      startDate: _startDate,
      endDate: _isCurrent ? null : _endDate,
      isCurrent: _isCurrent,
      description: _descriptionController.text.trim(),
    );

    if (widget.experience != null) {
      context.read<ProfileCubit>().updateExperience(experience);
    } else {
      context.read<ProfileCubit>().addExperience(experience);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experience != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Experiência' : 'Nova Experiência'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(
                    labelText: 'Cargo',
                    hintText: 'Ex: Garçom, Auxiliar de Cozinha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Cargo'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    labelText: 'Empresa',
                    hintText: 'Ex: Hotel Vila Galé',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Empresa'),
                ),
                const SizedBox(height: 16),

                CheckboxListTile(
                  title: const Text('Trabalho atual'),
                  value: _isCurrent,
                  onChanged: (value) {
                    setState(() {
                      _isCurrent = value ?? false;
                      if (_isCurrent) {
                        _endDate = null;
                      }
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _startDate == null
                              ? 'Início'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                        onPressed: () => _selectStartDate(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _isCurrent
                              ? 'Presente'
                              : _endDate == null
                                  ? 'Término'
                                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                        onPressed: _isCurrent ? null : () => _selectEndDate(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descrição das Atividades',
                    hintText: 'Descreva suas principais responsabilidades...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 36),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Salvar Alterações' : 'Adicionar Experiência',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
