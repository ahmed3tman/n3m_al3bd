import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/features/azkar/cubit/azkar_cubit.dart';
import 'package:jalees/features/azkar/model/azkar_model.dart';
import '../../../../core/theme/app_fonts.dart';

class AzkarCard extends StatefulWidget {
  final AzkarModel azkarModel;
  const AzkarCard({super.key, required this.azkarModel});

  @override
  State<AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  late final AzkarCubit _cubit;
  int? _remaining;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AzkarCubit>();
    _remaining = _cubit.getRemainingFor(widget.azkarModel);
  }

  @override
  void didUpdateWidget(covariant AzkarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.azkarModel.zekr != widget.azkarModel.zekr ||
        oldWidget.azkarModel.category != widget.azkarModel.category ||
        oldWidget.azkarModel.count != widget.azkarModel.count) {
      _remaining = _cubit.getRemainingFor(widget.azkarModel);
    }
  }

  void _decrement() {
    if (_remaining == null) return;
    if (_remaining! > 0) {
      setState(() {
        _remaining = _remaining! - 1;
        _cubit.setRemainingFor(widget.azkarModel, _remaining!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.azkarModel.count ?? 0;
    final isCompleted = (_remaining ?? total) == 0 && total > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نص الذكر
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isCompleted
                      ? Colors.green.withOpacity(0.07)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary)
                            .withOpacity(0.1),
                  ),
                ),
                child: Text(
                  widget.azkarModel.zekr ?? '',
                  textDirection: TextDirection.rtl,
                  style: AppFonts.azkarTextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // الوصف إن وجد
              if (widget.azkarModel.description != null &&
                  widget.azkarModel.description!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.azkarModel.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // الشريط السفلي: العداد على اليسار والراوي ثابت على اليمين (معالجة الأوفر فلو)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  if (total > 0)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _decrement,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isCompleted
                              ? Colors.green.withOpacity(0.10)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.10),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green.shade400
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // دائرة تقدم حول أيقونة الإصبع
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    value: total == 0
                                        ? 0
                                        : ((total - (_remaining ?? total)) /
                                                  total)
                                              .clamp(0.0, 1.0),
                                    strokeWidth: 2.5,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isCompleted
                                          ? Colors.green.shade400
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 14,
                                  color: isCompleted
                                      ? Colors.green.shade400
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCompleted
                                  ? 'تمت القراءة'
                                  : 'متبقي: ${_remaining ?? total}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: isCompleted
                                        ? Colors.green.shade600
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.azkarModel.reference != null &&
                      widget.azkarModel.reference!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.source_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          // اجعل النص مرنًا لتقليصه وإضافة الحذف عند الضيق
                          Flexible(
                            child: Text(
                              widget.azkarModel.reference!,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
