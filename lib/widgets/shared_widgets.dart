import 'package:flutter/material.dart';
import '../theme.dart';

// Gradient background scaffold
class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgFrom, AppTheme.bgTo],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

// Progress bar for multi-step form
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const StepProgressBar({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            height: 10,
            decoration: BoxDecoration(
              color: i < currentStep ? AppTheme.primary : AppTheme.slate200,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

// Header with back button
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Row(
            children: [
              Icon(Icons.arrow_back, color: AppTheme.slate600, size: 24),
              SizedBox(width: 8),
              Text('Voltar',
                  style: TextStyle(color: AppTheme.slate600, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(fontSize: 16, color: AppTheme.slate600)),
            ],
          ),
        ),
        const SizedBox(width: 80),
      ],
    );
  }
}

// White card
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(28),
      child: child,
    );
  }
}

// Primary button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

// Section header with icon
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.slate800)),
      ],
    );
  }
}

// Label + value info row
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.slate500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.slate800)),
      ],
    );
  }
}

// Yes/No toggle buttons
class YesNoToggle extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const YesNoToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Sim', 'Não'].map((opt) {
        final selected = value == opt;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.white,
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.slate200,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppTheme.slate800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Form field label
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.slate700)),
    );
  }
}

// Avatar circle
class AvatarCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;

  const AvatarCircle({
    super.key,
    required this.color,
    required this.icon,
    this.size = 64,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}
