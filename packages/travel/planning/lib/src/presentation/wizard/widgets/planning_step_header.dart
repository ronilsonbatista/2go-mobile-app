import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';
import 'form_course_icons.dart';

class PlanningStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PlanningStepHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.title,
    this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Course back: white circle + dark left chevron (ref asset 716686ac).
            // MaterialIcons must be bundled via app `uses-material-design: true`.
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              shadowColor: Colors.black26,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: FormCourseTokens.backCircleSize,
                  height: FormCourseTokens.backCircleSize,
                  child: Icon(
                    Icons.chevron_left,
                    color: FormCourseTokens.ink,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: TwoGoSpacing.sm),
            Expanded(
              child: _PlaneProgressBar(progress: progress),
            ),
            const SizedBox(width: TwoGoSpacing.sm),
            Text(
              '$currentStep de $totalSteps',
              style: TwoGoTypography.labelMedium.copyWith(
                color: FormCourseTokens.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: TwoGoSpacing.md),
        Text(
          title,
          style: TwoGoTypography.headlineMedium.copyWith(
            color: FormCourseTokens.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            subtitle!,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: FormCourseTokens.label,
            ),
          ),
        ],
      ],
    );
  }
}

class _PlaneProgressBar extends StatelessWidget {
  const _PlaneProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final planeSize = 22.0;
        final travel = (width - planeSize).clamp(0.0, width);
        final dx = travel * progress;

        return SizedBox(
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 13,
                child: Container(
                  height: 2,
                  color: FormCourseTokens.label.withValues(alpha: 0.35),
                ),
              ),
              Positioned(
                left: 0,
                width: dx + planeSize / 2,
                top: 13,
                child: Container(
                  height: 2,
                  color: FormCourseTokens.black,
                ),
              ),
              Positioned(
                left: dx,
                child: const FormProgressPlaneIcon(size: 22),
              ),
            ],
          ),
        );
      },
    );
  }
}
