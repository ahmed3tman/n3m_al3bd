import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_cubit.dart';
import 'package:n3m_al3bd/features/azkar/model/azkar_model.dart';
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
    final total =
        (widget.azkarModel.count == null || widget.azkarModel.count == 0)
        ? 1
        : widget.azkarModel.count!;
    final isCompleted = (_remaining ?? total) == 0 && total > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.6,
            ),
            width: 1.5,
          ),
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
              // 1. Reference (Narrator) at the top
              if (widget.azkarModel.reference != null &&
                  widget.azkarModel.reference!.isNotEmpty) ...[
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.source_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.azkarModel.reference!,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 2. Zekr Text
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

              // 3. Description (if any)
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

              // 4. Count Button (Bottom Center)
              if (total > 0)
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _decrement,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.15),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green.shade400
                              : Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isCompleted
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  value: total == 0
                                      ? 0
                                      : ((total - (_remaining ?? total)) /
                                                total)
                                            .clamp(0.0, 1.0),
                                  strokeWidth: 3,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted
                                        ? Colors.green.shade400
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.green.shade600,
                                )
                              else
                                Text(
                                  '${_remaining ?? total}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isCompleted ? 'تمت القراءة' : 'اضغط للتسبيح',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: isCompleted
                                      ? Colors.green.shade700
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
