import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import 'package:n3m_al3bd/core/share/widgets/custom_reset_button.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_cubit.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_state.dart';
import 'package:n3m_al3bd/features/azkar/view/widgets/azkar_card.dart';

class AzkarCategoryScreen extends StatelessWidget {
  final String categoryName;

  const AzkarCategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 16.0),
                child: CustomResetButton(
                  tooltip: 'إعادة تعيين القسم',
                  onTap: () async {
                    await AzkarCubit.get(context).resetCategory(categoryName);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AzkarCubit, AzkarState>(
        builder: (context, state) {
          final cubit = AzkarCubit.get(context);

          // Filter by category
          final categoryAzkar = cubit.azkar
              .where((element) => element.category == categoryName)
              .toList();

          // Sort: Incomplete first, Completed last
          categoryAzkar.sort((a, b) {
            final remainingA = cubit.getRemainingFor(a);
            final remainingB = cubit.getRemainingFor(b);

            // Force total to be at least 1
            final totalA = (a.count == null || a.count == 0) ? 1 : a.count!;
            final totalB = (b.count == null || b.count == 0) ? 1 : b.count!;

            final isCompletedA = remainingA == 0 && totalA > 0;
            final isCompletedB = remainingB == 0 && totalB > 0;

            if (isCompletedA && !isCompletedB) return 1; // A goes after B
            if (!isCompletedA && isCompletedB) return -1; // A goes before B
            return 0;
          });

          if (categoryAzkar.isEmpty) {
            return const Center(child: Text('لا توجد أذكار في هذا القسم'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: categoryAzkar.length,
            itemBuilder: (context, index) {
              final item = categoryAzkar[index];
              final remaining = cubit.getRemainingFor(item);
              final total = (item.count == null || item.count == 0)
                  ? 1
                  : item.count!;
              final isCompleted = remaining == 0 && total > 0;

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isCompleted ? 0.5 : 1.0,
                child: KeyedSubtree(
                  key: ValueKey(
                    '${cubit.resetEpoch}-${item.category ?? ''}-${item.zekr ?? ''}-${item.count ?? ''}',
                  ),
                  child: AzkarCard(azkarModel: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
