import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../utils/storage.dart';
import '../widgets/shared_widgets.dart';

class AddAppointmentScreen extends StatefulWidget {
  final String clientId;
  final String? appointmentId;
  const AddAppointmentScreen({
    super.key,
    required this.clientId,
    this.appointmentId,
  });

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _servicesCtrl = TextEditingController();
  final _productsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _profCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final appts = await StorageService.getAppointments(widget.clientId);
    final a = appts.firstWhere((a) => a.id == widget.appointmentId,
        orElse: () => AppointmentModel(
            id: '', clientId: '', date: '', services: '', products: '', notes: '', professional: ''));
    if (a.id.isEmpty) return;
    setState(() {
      _servicesCtrl.text = a.services;
      _productsCtrl.text = a.products;
      _notesCtrl.text = a.notes;
      _profCtrl.text = a.professional;
      try {
        _date = DateTime.parse(a.date);
      } catch (_) {}
    });
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (dt != null) setState(() => _date = dt);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final appt = AppointmentModel(
      id: widget.appointmentId ?? StorageService.generateId(),
      clientId: widget.clientId,
      date: '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
      services: _servicesCtrl.text,
      products: _productsCtrl.text,
      notes: _notesCtrl.text,
      professional: _profCtrl.text,
    );
    await StorageService.saveAppointment(widget.clientId, appt);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _servicesCtrl.dispose();
    _productsCtrl.dispose();
    _notesCtrl.dispose();
    _profCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointmentId != null;
    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: isEdit ? 'Editar Atendimento' : 'Novo Atendimento',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    icon: Icons.calendar_month_outlined,
                    iconColor: Color(0xFF2563EB),
                    iconBg: Color(0xFFDBEAFE),
                    title: 'Dados do Atendimento',
                  ),
                  const SizedBox(height: 28),

                  const FieldLabel('Data do Atendimento'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                              style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B)),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Serviços Realizados'),
                  TextField(
                    controller: _servicesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Ex: Corte, Hidratação, Coloração...'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Produtos Utilizados'),
                  TextField(
                    controller: _productsCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Ex: Máscara de hidratação XYZ...'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Profissional Responsável'),
                  TextField(
                    controller: _profCtrl,
                    decoration: const InputDecoration(hintText: 'Nome do profissional'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  const FieldLabel('Observações'),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(hintText: 'Anotações sobre o atendimento...'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: _loading ? 'Salvando...' : 'Salvar Atendimento',
                    icon: Icons.check,
                    onPressed: _loading ? () {} : _save,
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
