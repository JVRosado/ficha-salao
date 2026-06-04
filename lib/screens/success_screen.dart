import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 64),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Ficha Salva com Sucesso!',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A ficha de anamnese foi registrada e está disponível para consulta.',
                      style: TextStyle(fontSize: 17, color: Color(0xFF475569)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.home_outlined,
                            label: 'Voltar ao Início',
                            subtitle: 'Tela principal',
                            onTap: () => context.go('/'),
                            bgColor: const Color(0xFFF1F5F9),
                            iconBg: const Color(0xFF1E293B),
                            labelColor: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.description_outlined,
                            label: 'Nova Ficha',
                            subtitle: 'Criar outra ficha',
                            onTap: () => context.go('/search'),
                            bgColor: const Color(0xFF3B82F6),
                            iconBg: Colors.white,
                            labelColor: Colors.white,
                            iconColor: const Color(0xFF3B82F6),
                            subtitleColor: const Color(0xFFBFDBFE),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconBg;
  final Color labelColor;
  final Color? iconColor;
  final Color? subtitleColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.bgColor,
    required this.iconBg,
    required this.labelColor,
    this.iconColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: labelColor)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 13, color: subtitleColor ?? const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
