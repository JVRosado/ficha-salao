import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/storage.dart';
import '../widgets/shared_widgets.dart';

class ClientDetailsScreen extends StatefulWidget {
  final String clientId;
  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  ClientModel? _client;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    ClientModel? c = await StorageService.getClient(widget.clientId);
    c ??= StorageService.getMockClient(widget.clientId);
    setState(() {
      _client = c;
      _loading = false;
    });
  }

  String _fmt(String d) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  int? _daysSinceTest() {
    final d = _client?.procedures.lastStrandTestDate ?? '';
    if (d.isEmpty) return null;
    try {
      final diff = DateTime.now().difference(DateTime.parse(d));
      return diff.inDays;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = _client!;
    final days = _daysSinceTest();

    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: 'Detalhes da Ficha',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 24),

            // Client header card
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const AvatarCircle(color: AppTheme.primary, icon: Icons.person, size: 72, iconSize: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
                            Text('Data: ${_fmt(c.date)}',
                                style: const TextStyle(fontSize: 15, color: AppTheme.slate600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/client/${c.id}/edit'),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar Ficha'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.slate200, width: 2),
                            foregroundColor: AppTheme.slate800,
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/client/${c.id}/timeline'),
                          icon: const Icon(Icons.calendar_month_outlined, size: 18),
                          label: const Text('Ver Histórico'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: AppTheme.slate200, thickness: 2),
                  Row(
                    children: [
                      Expanded(child: InfoRow(label: 'Telefone', value: c.phone)),
                      Expanded(child: InfoRow(label: 'Email', value: c.email)),
                      Expanded(child: InfoRow(label: 'Nascimento', value: _fmt(c.birthDate))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Health
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: InfoRow(label: 'Alergias', value: c.health.allergies)),
                      Expanded(child: InfoRow(label: 'Medicamentos', value: c.health.medications)),
                      Expanded(child: InfoRow(label: 'Condições de Pele', value: c.health.skinConditions)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Procedures
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
                  const SizedBox(height: 20),

                  _SubSection(
                    title: 'ALISAMENTO',
                    children: [
                      InfoRow(label: 'Faz alisamento?', value: c.procedures.hasSmoothing),
                      if (c.procedures.hasSmoothing == 'Sim') ...[
                        InfoRow(label: 'Tipo', value: c.procedures.smoothingType),
                        InfoRow(label: 'Última vez', value: c.procedures.smoothingDate),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SubSection(
                    title: 'COLORAÇÃO',
                    children: [
                      InfoRow(label: 'Tem coloração?', value: c.procedures.hasColoring),
                      if (c.procedures.hasColoring == 'Sim') ...[
                        InfoRow(label: 'Cor', value: c.procedures.coloringType),
                        InfoRow(label: 'Última vez', value: c.procedures.coloringDate),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  InfoRow(label: 'Desejo para hoje', value: c.procedures.todayDesire),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: InfoRow(label: 'Foto de inspiração?', value: c.procedures.hasInspirationPhoto)),
                      Expanded(child: InfoRow(label: 'Cortar parte fragilizada?', value: c.procedures.willingToCut)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: InfoRow(label: 'Pré-tratamento?', value: c.procedures.preTreatment)),
                      Expanded(child: InfoRow(label: 'Pós-química?', value: c.procedures.postTreatment)),
                      Expanded(child: InfoRow(label: 'Indicação profissional?', value: c.procedures.professionalAdvice)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Strand test banner
                  _StrandTestBanner(days: days),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Observations
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
                  const SizedBox(height: 16),
                  Text(c.observations,
                      style: const TextStyle(fontSize: 16, color: AppTheme.slate800, height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SubSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SubSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slate600, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(children: children.map((w) => Expanded(child: w)).toList()),
        ],
      ),
    );
  }
}

class _StrandTestBanner extends StatelessWidget {
  final int? days;
  const _StrandTestBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    Color bg, border;
    String msg;

    if (days == null) {
      bg = AppTheme.slate50;
      border = AppTheme.slate200;
      msg = 'Nenhum teste registrado. Validade: 30 dias.';
    } else if (days! > 30) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      msg = 'Realizado há $days dias (EXPIRADO - refazer teste)';
    } else {
      bg = const Color(0xFFF0FDF4);
      border = const Color(0xFFBBF7D0);
      msg = days == 0
          ? 'Realizado hoje ✓'
          : 'Realizado há $days dias (Válido por mais ${30 - days!} dias)';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
                text: 'Teste de Mechas: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.slate800)),
            TextSpan(text: msg, style: const TextStyle(fontSize: 14, color: AppTheme.slate700)),
          ],
        ),
      ),
    );
  }
}
