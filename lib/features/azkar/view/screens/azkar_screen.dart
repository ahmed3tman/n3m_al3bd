import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import 'package:n3m_al3bd/core/share/widgets/custom_search_bar.dart';
import 'package:n3m_al3bd/core/share/widgets/custom_reset_button.dart';
import 'package:n3m_al3bd/features/azkar/view/screens/azkar_category_screen.dart';
import 'package:n3m_al3bd/features/azkar/view/widgets/azkar_category_card.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_cubit.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_state.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit()..getAzkar(),
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text('الأذكار'),
          centerTitle: true,
          actions: [
            BlocBuilder<AzkarCubit, AzkarState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16.0),
                  child: CustomResetButton(
                    onTap: () async {
                      await AzkarCubit.get(context).clearAllRemaining();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: CustomSearchBar(
                hintText: 'ابحث في الأذكار...',
                onChanged: (val) => setState(() => search = val),
                margin: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: BlocBuilder<AzkarCubit, AzkarState>(
                builder: (context, state) {
                  if (state is GetAzkarLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetAzkarErrorState) {
                    return Center(child: Text(state.error));
                  } else {
                    final cubit = AzkarCubit.get(context);

                    // 1. Get all unique categories
                    final allCategories = <String>{
                      ...cubit.azkar
                          .map((e) => e.category)
                          .whereType<String>()
                          .where((c) => c.trim().isNotEmpty),
                    }.toList()..sort((a, b) => a.compareTo(b));

                    // 2. Filter categories based on search
                    final query = search.trim();
                    final filteredCategories = allCategories.where((cat) {
                      if (query.isEmpty) return true;

                      // Match category name
                      if (cat.contains(query)) return true;

                      // Or match any Azkar content within this category
                      final azkarInCategory = cubit.azkar.where(
                        (a) => a.category == cat,
                      );
                      return azkarInCategory.any(
                        (a) =>
                            (a.zekr?.contains(query) ?? false) ||
                            (a.description?.contains(query) ?? false) ||
                            (a.reference?.contains(query) ?? false),
                      );
                    }).toList();

                    if (filteredCategories.isEmpty) {
                      return const Center(child: Text('لا توجد نتائج'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 items per row
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1, // Adjust for card height
                          ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];

                        // Calculate counts for this category
                        final categoryAzkar = cubit.azkar
                            .where((a) => a.category == category)
                            .toList();
                        final totalCount = categoryAzkar.length;
                        final remainingCount = categoryAzkar
                            .where((a) => cubit.getRemainingFor(a) > 0)
                            .length;

                        return AzkarCategoryCard(
                          categoryName: category,
                          totalCount: totalCount,
                          remainingCount: remainingCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: cubit, // Pass existing cubit
                                  child: AzkarCategoryScreen(
                                    categoryName: category,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
