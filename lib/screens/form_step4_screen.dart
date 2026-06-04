import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../utils/storage.dart';
import '../widgets/shared_widgets.dart';

class FormStep4Screen extends StatefulWidget {
  final Map<String, dynamic> prevData;
  const FormStep4Screen({super.key, required this.prevData});

  @override
  State<FormStep4Screen> createState() => _FormStep4ScreenState();
}

class _FormStep4ScreenState extends State<FormStep4Screen> {
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final d = widget.prevData;
    final client = ClientModel(
      id: StorageService.generateId(),
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      birthDate: d['birthDate'] ?? '',
      date: DateTime.now().toIso8601String().substring(0, 10),
      health: HealthInfo(
        allergies: d['allergies'] ?? '',
        medications: d['medications'] ?? '',
        skinConditions: d['skinConditions'] ?? '',
      ),
      procedures: ProcedureInfo(
        hasSmoothing: d['hasSmoothing'] ?? '',
        smoothingType: d['smoothingType'] ?? '',
        smoothingDate: d['smoothingDate'] ?? '',
        hasColoring: d['hasColoring'] ?? '',
        coloringType: d['coloringType'] ?? '',
        coloringDate: d['coloringDate'] ?? '',
        todayDesire: d['todayDesire'] ?? '',
        hasInspirationPhoto: d['hasInspirationPhoto'] ?? '',
        willingToCut: d['willingToCut'] ?? '',
        preTreatment: d['preTreatment'] ?? '',
        postTreatment: d['postTreatment'] ?? '',
        professionalAdvice: d['professionalAdvice'] ?? '',
        lastStrandTestDate: d['lastStrandTestDate'] ?? '',
      ),
      observations: _obsCtrl.text,
    );

    await StorageService.saveClient(client);
    if (mounted) context.go('/success');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: 'Nova Ficha',
              subtitle: 'Etapa 4 de 4',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 20),
            const StepProgressBar(currentStep: 4, totalSteps: 4),
            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    icon: Icons.description_outlined,
                    iconColor: Color(0xFFD97706),
                    iconBg: Color(0xFFFEF3C7),
                    title: 'Observações Adicionais',
                  ),
                  const SizedBox(height: 28),

                  const FieldLabel('Observações (opcional)'),
                  TextField(
                    controller: _obsCtrl,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText:
                          'Adicione informações relevantes: preferências do cliente, sensibilidades, cuidados especiais, etc.',
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '💡 Dica: Use este espaço para registrar preferências de produtos, histórico de reações, pedidos especiais, ou qualquer observação útil para futuras visitas.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF1D4ED8)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'Finalizar e Salvar',
                    icon: Icons.check,
                    color: const Color(0xFF22C55E),
                    onPressed: _submit,
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
