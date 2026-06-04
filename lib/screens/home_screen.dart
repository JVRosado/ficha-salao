import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            const Column(
              children: [
                Text(
                  'Fichas de Anamnese',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Sistema de gestão para salão de beleza',
                  style: TextStyle(fontSize: 18, color: AppTheme.slate600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Buttons grid
            Row(
              children: [
                Expanded(
                  child: _MenuCard(
                    icon: Icons.description_outlined,
                    label: 'Nova Ficha',
                    subtitle: 'Criar nova ficha de anamnese',
                    color: AppTheme.primary,
                    borderColor: AppTheme.primary,
                    onTap: () => context.push('/search'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _MenuCard(
                    icon: Icons.history,
                    label: 'Consultar Histórico',
                    subtitle: 'Ver fichas anteriores',
                    color: AppTheme.purple,
                    borderColor: AppTheme.purple,
                    onTap: () => context.push('/history'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.diagonal3Values(_hovered ? 0.97 : 1.0, _hovered ? 0.97 : 1.0, 1.0),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _hovered ? widget.borderColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.07),
              blurRadius: _hovered ? 24 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              child: Icon(widget.icon, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              widget.label,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.slate800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 15, color: AppTheme.slate600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
