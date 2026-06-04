import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/storage.dart';
import '../widgets/shared_widgets.dart';

class ClientTimelineScreen extends StatefulWidget {
  final String clientId;
  const ClientTimelineScreen({super.key, required this.clientId});

  @override
  State<ClientTimelineScreen> createState() => _ClientTimelineScreenState();
}

class _ClientTimelineScreenState extends State<ClientTimelineScreen> {
  ClientModel? _client;
  List<AppointmentModel> _appointments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    ClientModel? c = await StorageService.getClient(widget.clientId);
    c ??= StorageService.getMockClient(widget.clientId);
    final appts = await StorageService.getAppointments(widget.clientId);
    appts.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _client = c;
      _appointments = appts;
    });
  }

  Future<void> _delete(String id) async {
    await StorageService.deleteAppointment(widget.clientId, id);
    _load();
  }

  String _fmt(String d) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = _client!;

    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: c.name,
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 20),

            // Client info card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const AvatarCircle(color: AppTheme.primary, icon: Icons.person, size: 56, iconSize: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
                        const SizedBox(height: 4),
                        Text('${c.phone}  •  ${c.email}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.slate600)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/client/${c.id}'),
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('Ver Ficha'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.slate200),
                      foregroundColor: AppTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add new button
            PrimaryButton(
              label: 'Adicionar Novo Atendimento',
              icon: Icons.add,
              onPressed: () => context.push('/client/${c.id}/appointment/new').then((_) => _load()),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _appointments.isEmpty
                  ? AppCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                                color: AppTheme.slate100, shape: BoxShape.circle),
                            child: const Icon(Icons.calendar_month_outlined,
                                color: AppTheme.slate400, size: 40),
                          ),
                          const SizedBox(height: 20),
                          const Text('Nenhum Atendimento Registrado',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
                          const SizedBox(height: 8),
                          const Text('Comece adicionando o primeiro atendimento deste cliente',
                              style: TextStyle(fontSize: 15, color: AppTheme.slate600),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final a = _appointments[i];
                        return _AppointmentCard(
                          appt: a,
                          formattedDate: _fmt(a.date),
                          onEdit: () => context
                              .push('/client/${c.id}/appointment/${a.id}/edit')
                              .then((_) => _load()),
                          onDelete: () => _delete(a.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appt;
  final String formattedDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AppointmentCard({
    required this.appt,
    required this.formattedDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(formattedDate,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppTheme.slate500, size: 20),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              ),
            ],
          ),
          if (appt.services.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Row(label: 'Serviços', value: appt.services),
          ],
          if (appt.products.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(label: 'Produtos', value: appt.products),
          ],
          if (appt.professional.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(label: 'Profissional', value: appt.professional),
          ],
          if (appt.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(label: 'Observações', value: appt.notes),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slate600)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, color: AppTheme.slate800)),
        ),
      ],
    );
  }
}
