import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/custom_search_bar.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_cubit.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_state.dart';
import 'package:n3m_al3bd/features/azkar/view/widgets/azkar_card.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  String search = '';
  String selectedCategory = 'الكل';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit()..getAzkar(),
      child: GradientScaffold(
        appBar: AppBar(title: const Text('الأذكار'), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      hintText: 'ابحث في الأذكار...',
                      onChanged: (val) => setState(() => search = val),
                      margin: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<AzkarCubit, AzkarState>(
                    builder: (context, state) {
                      final scheme = Theme.of(context).colorScheme;
                      final primary = scheme.primary;
                      return Tooltip(
                        message: 'إعادة تعيين العدادات',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await AzkarCubit.get(context).clearAllRemaining();
                              setState(() {});
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primary.withOpacity(0.18),
                                    primary.withOpacity(0.28),
                                  ],
                                ),
                                border: Border.all(
                                  color: primary.withOpacity(0.40),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.restart_alt_rounded,
                                color: primary,
                                size: 22,
                                semanticLabel: 'إعادة تعيين العدادات',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
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

                    // Build categories list (unique) with 'All' as the first item
                    final categories = <String>{
                      ...cubit.azkar
                          .map((e) => e.category)
                          .whereType<String>()
                          .where((c) => c.trim().isNotEmpty),
                    }.toList()..sort((a, b) => a.compareTo(b));
                    final allCategories = ['الكل', ...categories];

                    // Apply filters: if searching, search across ALL azkar; otherwise filter by category
                    final query = search.trim();
                    final isSearching = query.isNotEmpty;
                    final filteredAzkar = cubit.azkar.where((azkar) {
                      final matchesCategory = isSearching
                          ? true
                          : (selectedCategory == 'الكل'
                                ? true
                                : (azkar.category == selectedCategory));

                      if (!matchesCategory) return false;

                      if (!isSearching) return true;

                      return (azkar.category?.contains(query) ?? false) ||
                          (azkar.description?.contains(query) ?? false) ||
                          (azkar.zekr?.contains(query) ?? false) ||
                          (azkar.count?.toString().contains(query) ?? false) ||
                          (azkar.reference?.contains(query) ?? false);
                    }).toList();

                    return Column(
                      children: [
                        // Categories horizontal chips
                        SizedBox(
                          height: 45,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              //  vertical: 1,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: allCategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = allCategories[index];
                              final isSelected = selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => selectedCategory = cat);
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline
                                              .withOpacity(0.4),
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        // List of azkar
                        Expanded(
                          child: filteredAzkar.isEmpty
                              ? const Center(child: Text('لا توجد نتائج'))
                              : ListView.builder(
                                  itemCount: filteredAzkar.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredAzkar[index];
                                    return KeyedSubtree(
                                      key: ValueKey(
                                        '${cubit.resetEpoch}-${item.category ?? ''}-${item.zekr ?? ''}-${item.count ?? ''}',
                                      ),
                                      child: AzkarCard(azkarModel: item),
                                    );
                                  },
                                ),
                        ),
                      ],
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
