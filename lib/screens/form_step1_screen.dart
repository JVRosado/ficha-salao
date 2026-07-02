import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class FormStep1Screen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const FormStep1Screen({super.key, this.initialData = const {}});

  @override
  State<FormStep1Screen> createState() => _FormStep1ScreenState();
}

class _FormStep1ScreenState extends State<FormStep1Screen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();

  bool get _isEditing => widget.initialData['editingId'] != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.initialData['name'] ?? '';
    _phoneCtrl.text = widget.initialData['phone'] ?? '';
    _emailCtrl.text = widget.initialData['email'] ?? '';
    _birthCtrl.text = widget.initialData['birthDate'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  void _next() {
    context.push('/new/step2', extra: {
      ...widget.initialData,
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'birthDate': _birthCtrl.text,
    });
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (dt != null) {
      _birthCtrl.text =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: _isEditing ? 'Editar Ficha' : 'Nova Ficha',
              subtitle: 'Etapa 1 de 4',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 20),
            const StepProgressBar(currentStep: 1, totalSteps: 4),
            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    icon: Icons.person_outline,
                    iconColor: Color(0xFF2563EB),
                    iconBg: Color(0xFFDBEAFE),
                    title: 'Dados Básicos',
                  ),
                  const SizedBox(height: 28),

                  const FieldLabel('Nome Completo *'),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(hintText: 'Digite o nome completo'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Telefone *'),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '(00) 00000-0000'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Email *'),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'email@exemplo.com'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Data de Nascimento *'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _birthCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Selecione a data',
                          suffixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.slate400),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'Próxima Etapa',
                    icon: Icons.arrow_forward,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
