import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/storage.dart';
import '../widgets/shared_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ClientSummary> _allClients = [];
  List<ClientSummary> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.getClientSummaries();
    setState(() {
      _allClients = list;
      _filtered = list;
      _loading = false;
    });
  }

  void _onSearch(String v) {
    setState(() {
      _filtered = _allClients
          .where((c) => c.name.toLowerCase().contains(v.toLowerCase()))
          .toList();
    });
  }

  String _formatDate(String d) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            PageHeader(
              title: 'Histórico de Clientes',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 24),

            // Search bar
            AppCard(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar cliente por nome...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.slate400, size: 26),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? const AppCard(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Nenhum cliente encontrado',
                                style: TextStyle(fontSize: 18, color: AppTheme.slate600),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final c = _filtered[i];
                            return _ClientTile(
                              client: c,
                              formattedDate: _formatDate(c.lastVisit),
                              onTap: () => context.push('/client/${c.id}/timeline'),
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

class _ClientTile extends StatefulWidget {
  final ClientSummary client;
  final String formattedDate;
  final VoidCallback onTap;

  const _ClientTile({
    required this.client,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  State<_ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<_ClientTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? AppTheme.purple : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.1 : 0.06),
              blurRadius: _hovered ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.purple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppTheme.purple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.client.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
                  const SizedBox(height: 4),
                  Text(widget.client.phone,
                      style: const TextStyle(fontSize: 15, color: AppTheme.slate600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Última visita',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500)),
                const SizedBox(height: 4),
                Text(widget.formattedDate,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.slate700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
