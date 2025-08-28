import 'package:flutter/material.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';
import 'package:jalees/features/quran/view/screens/quran_screen.dart';
import 'package:jalees/features/bukhari/view/screens/bukhari_screen.dart';
import 'package:jalees/features/azkar/view/screens/azkar_screen.dart';
import '../../../jadwal/view/screens/jadwali_screen.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _screens = const [
    QuranScreen(),
    BukhariScreen(),
    AzkarScreen(),
    JadwaliScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animateTo(_currentIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.04,
              right: MediaQuery.of(context).size.width * 0.04,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.2),
                    width: 1,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicatorPadding: const EdgeInsets.all(6),
                  controller: _tabController,
                  onTap: _onTabTapped,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // خلفية أفتح للأيقونة المفعلة
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(
                    0.4,
                  ), // أبيض باهت
                  labelStyle: const TextStyle(
                    fontFamily: 'GeneralFont',
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // زيادة حجم النص
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'GeneralFont',
                    fontWeight: FontWeight.w500,
                    fontSize: 10, // زيادة حجم النص
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                  tabs: [
                    _buildTab('assets/icons/quran.png', 'القرآن', 0),
                    _buildTab('assets/icons/hadeeth.png', 'أحاديث', 1),
                    _buildTab('assets/icons/azkar.png', 'أذكار', 2),
                    _buildTab('assets/icons/calendar.png', 'جدولي', 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String iconPath, String label, int index) {
    final isSelected = _currentIndex == index;
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(1),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Colors
                            .white // أبيض نقي للمفعل
                      : Colors.white.withOpacity(0.4), // أبيض باهت لغير المفعل
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  iconPath,
                  width: isSelected ? 26 : 24, // زيادة حجم الأيقونة
                  height: isSelected ? 26 : 24, // زيادة حجم الأيقونة
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4), // زيادة المسافة بين الأيقونة والنص
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'GeneralFont',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: isSelected ? 11 : 10, // زيادة حجم النص قليلاً
                color: isSelected
                    ? Colors
                          .white // أبيض نقي للمفعل
                    : Colors.white.withOpacity(0.4), // أبيض باهت لغير المفعل
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
