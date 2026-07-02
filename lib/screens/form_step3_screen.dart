import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class FormStep3Screen extends StatefulWidget {
  final Map<String, dynamic> prevData;
  const FormStep3Screen({super.key, required this.prevData});

  @override
  State<FormStep3Screen> createState() => _FormStep3ScreenState();
}

class _FormStep3ScreenState extends State<FormStep3Screen> {
  String hasSmoothing = '';
  String smoothingType = '';
  String smoothingDate = '';
  String hasColoring = '';
  String coloringType = '';
  String coloringDate = '';
  String todayDesire = '';
  String hasInspirationPhoto = '';
  String willingToCut = '';
  String preTreatment = '';
  String postTreatment = '';
  String professionalAdvice = '';
  DateTime? lastStrandTestDate;

  final _smoothingTypeCtrl = TextEditingController();
  final _smoothingDateCtrl = TextEditingController();
  final _coloringTypeCtrl = TextEditingController();
  final _coloringDateCtrl = TextEditingController();
  final _desireCtrl = TextEditingController();

  bool get _isEditing => widget.prevData['editingId'] != null;

  @override
  void initState() {
    super.initState();
    final d = widget.prevData;
    hasSmoothing = d['hasSmoothing'] ?? '';
    hasColoring = d['hasColoring'] ?? '';
    hasInspirationPhoto = d['hasInspirationPhoto'] ?? '';
    willingToCut = d['willingToCut'] ?? '';
    preTreatment = d['preTreatment'] ?? '';
    postTreatment = d['postTreatment'] ?? '';
    professionalAdvice = d['professionalAdvice'] ?? '';
    _smoothingTypeCtrl.text = d['smoothingType'] ?? '';
    _smoothingDateCtrl.text = d['smoothingDate'] ?? '';
    _coloringTypeCtrl.text = d['coloringType'] ?? '';
    _coloringDateCtrl.text = d['coloringDate'] ?? '';
    _desireCtrl.text = d['todayDesire'] ?? '';
    final rawTestDate = d['lastStrandTestDate'] as String?;
    if (rawTestDate != null && rawTestDate.isNotEmpty) {
      try {
        lastStrandTestDate = DateTime.parse(rawTestDate);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _smoothingTypeCtrl.dispose();
    _smoothingDateCtrl.dispose();
    _coloringTypeCtrl.dispose();
    _coloringDateCtrl.dispose();
    _desireCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStrandTestDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (dt != null) setState(() => lastStrandTestDate = dt);
  }

  void _next() {
    context.push('/new/step4', extra: {
      ...widget.prevData,
      'hasSmoothing': hasSmoothing,
      'smoothingType': _smoothingTypeCtrl.text,
      'smoothingDate': _smoothingDateCtrl.text,
      'hasColoring': hasColoring,
      'coloringType': _coloringTypeCtrl.text,
      'coloringDate': _coloringDateCtrl.text,
      'todayDesire': _desireCtrl.text,
      'hasInspirationPhoto': hasInspirationPhoto,
      'willingToCut': willingToCut,
      'preTreatment': preTreatment,
      'postTreatment': postTreatment,
      'professionalAdvice': professionalAdvice,
      'lastStrandTestDate': lastStrandTestDate != null
          ? '${lastStrandTestDate!.year}-${lastStrandTestDate!.month.toString().padLeft(2, '0')}-${lastStrandTestDate!.day.toString().padLeft(2, '0')}'
          : '',
    });
  }

  Widget _yesNo(String label, String current, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        YesNoToggle(value: current.isEmpty ? null : current, onChanged: onChanged),
      ],
    );
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
              subtitle: 'Etapa 3 de 4',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 20),
            const StepProgressBar(currentStep: 3, totalSteps: 4),
            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    icon: Icons.water_drop_outlined,
                    iconColor: Color(0xFF7C3AED),
                    iconBg: Color(0xFFEDE9FE),
                    title: 'Procedimentos Capilares',
                  ),
                  const SizedBox(height: 28),

                  // Alisamento
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ALISAMENTO',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slate600,
                                letterSpacing: 1)),
                        const SizedBox(height: 16),
                        _yesNo('Faz algum tipo de alisamento?', hasSmoothing,
                            (v) => setState(() => hasSmoothing = v)),
                        if (hasSmoothing == 'Sim') ...[
                          const SizedBox(height: 16),
                          const FieldLabel('Tipo de alisamento'),
                          TextField(
                            controller: _smoothingTypeCtrl,
                            decoration: const InputDecoration(hintText: 'Ex: Progressiva, Relaxamento...'),
                          ),
                          const SizedBox(height: 16),
                          const FieldLabel('Quando foi a última vez?'),
                          TextField(
                            controller: _smoothingDateCtrl,
                            decoration: const InputDecoration(hintText: 'Ex: Há 3 meses'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Coloração
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COLORAÇÃO',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slate600,
                                letterSpacing: 1)),
                        const SizedBox(height: 16),
                        _yesNo('Tem coloração?', hasColoring,
                            (v) => setState(() => hasColoring = v)),
                        if (hasColoring == 'Sim') ...[
                          const SizedBox(height: 16),
                          const FieldLabel('Cor atual'),
                          TextField(
                            controller: _coloringTypeCtrl,
                            decoration: const InputDecoration(hintText: 'Ex: Castanho, Loiro...'),
                          ),
                          const SizedBox(height: 16),
                          const FieldLabel('Quando foi a última vez?'),
                          TextField(
                            controller: _coloringDateCtrl,
                            decoration: const InputDecoration(hintText: 'Ex: Há 1 mês'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('O que deseja fazer hoje?'),
                  TextField(
                    controller: _desireCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Descreva o serviço desejado...'),
                  ),
                  const SizedBox(height: 20),

                  _yesNo('Tem foto de inspiração?', hasInspirationPhoto,
                      (v) => setState(() => hasInspirationPhoto = v)),
                  const SizedBox(height: 16),
                  _yesNo('Disposta a cortar parte fragilizada?', willingToCut,
                      (v) => setState(() => willingToCut = v)),
                  const SizedBox(height: 16),
                  _yesNo('Tratamento pré-procedimento?', preTreatment,
                      (v) => setState(() => preTreatment = v)),
                  const SizedBox(height: 16),
                  _yesNo('Tratamento pós-química?', postTreatment,
                      (v) => setState(() => postTreatment = v)),
                  const SizedBox(height: 16),
                  _yesNo('Aceita indicação profissional?', professionalAdvice,
                      (v) => setState(() => professionalAdvice = v)),
                  const SizedBox(height: 20),

                  // Strand test date
                  const FieldLabel('Data do Teste de Mechas'),
                  GestureDetector(
                    onTap: _pickStrandTestDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppTheme.slate50,
                        border: Border.all(color: AppTheme.slate200, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastStrandTestDate != null
                                  ? '${lastStrandTestDate!.day.toString().padLeft(2, '0')}/${lastStrandTestDate!.month.toString().padLeft(2, '0')}/${lastStrandTestDate!.year}'
                                  : 'Selecionar data (validade: 30 dias)',
                              style: TextStyle(
                                fontSize: 16,
                                color: lastStrandTestDate != null
                                    ? AppTheme.slate800
                                    : AppTheme.slate400,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, color: AppTheme.slate400),
                        ],
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
