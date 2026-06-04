import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class SearchClientScreen extends StatelessWidget {
  const SearchClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            PageHeader(
              title: 'Nova Ficha',
              onBack: () => context.pop(),
            ),
            const SizedBox(height: 48),

            // New Client button - full card
            Expanded(
              child: Center(
                child: _NewClientCard(
                  onTap: () => context.push('/new/step1'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewClientCard extends StatefulWidget {
  final VoidCallback onTap;
  const _NewClientCard({required this.onTap});

  @override
  State<_NewClientCard> createState() => _NewClientCardState();
}

class _NewClientCardState extends State<_NewClientCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(_pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _pressed ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text('Novo Cliente',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
            const SizedBox(height: 8),
            const Text(
              'Criar ficha de anamnese para novo cliente',
              style: TextStyle(fontSize: 16, color: AppTheme.slate600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
