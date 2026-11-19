import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Result of the Onde Chegada / Partida sheet (calendar + hour pills).
class DestinationDateTimeSelection {
  const DestinationDateTimeSelection({
    required this.date,
    required this.time,
  });

  final DateTime date;

  /// `HH:mm` (hour on the hour).
  final String time;
}

/// Course date+time panel: month calendar + horizontal **Horário previsto**
/// hour pills (selected = black fill / white label).
///
/// Presented via [showGeneralDialog] at a **fixed height** with fade + short
/// slide — never as a bottom sheet that grows while laying out.
class DestinationDateTimeSheet extends StatefulWidget {
  const DestinationDateTimeSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialTime,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String initialTime;
  final String primaryLabel;
  final String secondaryLabel;

  /// Hours `00:00` … `23:00` for the horizontal pill strip.
  static const hourOptions = <String>[
    '00:00',
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
  ];

  /// Fixed panel height so open animation never morphs size (Form-Onde).
  static const double panelHeight = 560;

  static Future<DestinationDateTimeSelection?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required String initialTime,
    required String primaryLabel,
    required String secondaryLabel,
  }) {
    return showGeneralDialog<DestinationDateTimeSelection>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final media = MediaQuery.of(ctx);
        final height = panelHeight.clamp(420.0, media.size.height * 0.78);
        final bottomPad = media.padding.bottom;

        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                FormCourseTokens.pageGutter,
                0,
                FormCourseTokens.pageGutter,
                FormCourseTokens.pageGutter + bottomPad,
              ),
              child: SizedBox(
                height: height.toDouble(),
                width: double.infinity,
                child: DestinationDateTimeSheet(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  initialTime: initialTime,
                  primaryLabel: primaryLabel,
                  secondaryLabel: secondaryLabel,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            // Short slide of the already-final-sized panel — no height grow.
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<DestinationDateTimeSheet> createState() =>
      _DestinationDateTimeSheetState();
}

class _DestinationDateTimeSheetState extends State<DestinationDateTimeSheet> {
  late DateTime _selectedDate;
  late String _selectedTime;
  final _hourScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedTime = _normalizeHour(widget.initialTime);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _hourScroll.dispose();
    super.dispose();
  }

  static String _normalizeHour(String raw) {
    final parts = raw.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
    final clamped = hour.clamp(0, 23);
    return '${clamped.toString().padLeft(2, '0')}:00';
  }

  void _scrollToSelected() {
    if (!_hourScroll.hasClients) return;
    final index = DestinationDateTimeSheet.hourOptions.indexOf(_selectedTime);
    if (index < 0) return;
    // Approximate pill width + gap (~76).
    final offset = (index * 76.0) - 40;
    _hourScroll.jumpTo(offset.clamp(0.0, _hourScroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(FormCourseTokens.sheetRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: Colors.black26,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                FormCourseTokens.pageGutter,
                FormCourseTokens.sheetTopPadding + TwoGoSpacing.sm,
                FormCourseTokens.pageGutter,
                TwoGoSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: FormCourseTokens.black,
                        onPrimary: FormCourseTokens.surface,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      onDateChanged: (date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                  ),
                  const SizedBox(height: TwoGoSpacing.md),
                  Row(
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: TwoGoSpacing.xs),
                      Text(
                        'Horário previsto',
                        style: TwoGoTypography.titleMedium.copyWith(
                          color: FormCourseTokens.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TwoGoSpacing.sm),
                  SingleChildScrollView(
                    controller: _hourScroll,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final hour
                            in DestinationDateTimeSheet.hourOptions) ...[
                          _HourPill(
                            label: hour,
                            selected: hour == _selectedTime,
                            onTap: () {
                              setState(() => _selectedTime = hour);
                            },
                          ),
                          const SizedBox(width: TwoGoSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FormCourseTokens.pageGutter,
              TwoGoSpacing.sm,
              FormCourseTokens.pageGutter,
              TwoGoSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      widget.secondaryLabel,
                      style: TwoGoTypography.titleMedium.copyWith(
                        color: FormCourseTokens.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TwoGoSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          DestinationDateTimeSelection(
                            date: _selectedDate,
                            time: _selectedTime,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: FormCourseTokens.lime,
                        foregroundColor: FormCourseTokens.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TwoGoRadius.full),
                        ),
                        textStyle: TwoGoTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(widget.primaryLabel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourPill extends StatelessWidget {
  const _HourPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FormCourseTokens.black : FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? FormCourseTokens.black
                  : FormCourseTokens.label.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            label,
            style: TwoGoTypography.labelLarge.copyWith(
              color: selected
                  ? FormCourseTokens.surface
                  : FormCourseTokens.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
