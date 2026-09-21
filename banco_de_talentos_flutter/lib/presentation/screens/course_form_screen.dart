import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/course.dart';
import '../cubits/profile/profile_cubit.dart';
import '../components/custom_toast.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _institutionController = TextEditingController();

  String _status = 'completed';
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      final course = widget.course!;
      _nameController.text = course.name;
      _institutionController.text = course.institution;
      _status = course.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      CustomToast.show(
        context,
        message: 'Erro ao selecionar arquivo: $e',
        type: ToastType.error,
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final course = Course(
      id: widget.course?.id ?? '',
      profileId: widget.course?.profileId ?? '',
      name: _nameController.text.trim(),
      institution: _institutionController.text.trim(),
      status: _status,
      certificateUrl: widget.course?.certificateUrl,
    );

    if (widget.course != null) {
      context.read<ProfileCubit>().updateCourse(course, _selectedFilePath);
    } else {
      context.read<ProfileCubit>().addCourse(course, _selectedFilePath);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Curso' : 'Novo Curso'),
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Curso / Certificação',
                    hintText: 'Ex: Inglês Instrumental, Atendimento ao Cliente',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Nome do curso'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _institutionController,
                  decoration: InputDecoration(
                    labelText: 'Instituição',
                    hintText: 'Ex: SENAC, Pronatec',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Instituição'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'Status do Curso',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Concluído'),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('Em Andamento'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprovante / Certificado',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Formatos aceitos: PDF, JPG, PNG (Max 5MB)',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Selecionar Arquivo'),
                            onPressed: _pickFile,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedFileName ??
                                  (widget.course?.certificateUrl != null
                                      ? 'Certificado já enviado'
                                      : 'Nenhum arquivo selecionado'),
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: _selectedFileName == null ? FontStyle.italic : null,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      isEditing ? 'Salvar Alterações' : 'Salvar Curso',
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
