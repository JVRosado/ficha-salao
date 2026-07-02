import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/shared_widgets.dart';

class FormStep2Screen extends StatefulWidget {
  final Map<String, dynamic> step1Data;
  const FormStep2Screen({super.key, required this.step1Data});

  @override
  State<FormStep2Screen> createState() => _FormStep2ScreenState();
}

class _FormStep2ScreenState extends State<FormStep2Screen> {
  final _allergiesCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _skinCtrl = TextEditingController();

  bool get _isEditing => widget.step1Data['editingId'] != null;

  @override
  void initState() {
    super.initState();
    _allergiesCtrl.text = widget.step1Data['allergies'] ?? '';
    _medsCtrl.text = widget.step1Data['medications'] ?? '';
    _skinCtrl.text = widget.step1Data['skinConditions'] ?? '';
  }

  @override
  void dispose() {
    _allergiesCtrl.dispose();
    _medsCtrl.dispose();
    _skinCtrl.dispose();
    super.dispose();
  }

  void _next() {
    context.push('/new/step3', extra: {
      ...widget.step1Data,
      'allergies': _allergiesCtrl.text,
      'medications': _medsCtrl.text,
      'skinConditions': _skinCtrl.text,
    });
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
              subtitle: 'Etapa 2 de 4',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 20),
            const StepProgressBar(currentStep: 2, totalSteps: 4),
            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    icon: Icons.favorite_outline,
                    iconColor: Color(0xFFDC2626),
                    iconBg: Color(0xFFFEE2E2),
                    title: 'Informações de Saúde',
                  ),
                  const SizedBox(height: 28),

                  const FieldLabel('Alergias *'),
                  TextField(
                    controller: _allergiesCtrl,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(hintText: "Descreva alergias conhecidas ou digite 'Nenhuma'"),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Medicamentos em Uso *'),
                  TextField(
                    controller: _medsCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: "Liste medicamentos contínuos ou digite 'Nenhum'"),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Condições de Pele/Couro Cabeludo *'),
                  TextField(
                    controller: _skinCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: "Descreva condições especiais ou digite 'Normal'"),
                    style: const TextStyle(fontSize: 16),
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
