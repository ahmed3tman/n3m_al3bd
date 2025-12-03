import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import 'package:n3m_al3bd/features/quran/view/screens/quran_screen.dart';
import 'package:n3m_al3bd/features/azkar/view/screens/azkar_screen.dart';
import '../../../salaty/view/screens/salaty_screen.dart';
import 'package:n3m_al3bd/features/quran/data/page_mapping_repository.dart';
import 'package:n3m_al3bd/features/quran/data/line_mapping_repository.dart';

import 'package:n3m_al3bd/core/share/widgets/custom_drawer.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  bool _isBottomBarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    SalatyScreen(),
    QuranScreen(),
    AzkarScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animateTo(_currentIndex);

    // Pre-load Quran mapping data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PageMappingRepository.ensureLoaded();
      LineMappingRepository.ensureLoaded();
    });
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
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: const CustomDrawer(),
        body: NotificationListener<OpenDrawerNotification>(
          onNotification: (_) {
            _scaffoldKey.currentState?.openDrawer();
            return true;
          },
          child: Stack(
            children: [
              // Custom Drawer Icon
              Positioned(
                top: 50,
                right: 24,
                child: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 28,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
              // Listen for scrolls from child screens and toggle bottom bar visibility.
              Positioned.fill(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    // Only react to vertical scrolling
                    if (notification.metrics.axis == Axis.vertical) {
                      if (notification.direction == ScrollDirection.reverse) {
                        // Scrolling down -> hide
                        if (_isBottomBarVisible) {
                          setState(() => _isBottomBarVisible = false);
                        }
                      } else if (notification.direction ==
                          ScrollDirection.forward) {
                        // Scrolling up -> show
                        if (!_isBottomBarVisible) {
                          setState(() => _isBottomBarVisible = true);
                        }
                      }
                    }
                    return false; // allow notification to continue bubbling
                  },
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
              ),
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width * 0.04,
                right: MediaQuery.of(context).size.width * 0.04,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  // Slide down out of view when hidden
                  offset: _isBottomBarVisible
                      ? Offset.zero
                      : const Offset(0, 1.6),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isBottomBarVisible ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_isBottomBarVisible,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.6),
                            width: 1.5,
                          ),
                          color: Theme.of(
                            context,
                          ).bottomNavigationBarTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TabBar(
                          indicatorPadding: const EdgeInsets.all(6),
                          controller: _tabController,
                          onTap: _onTabTapped,
                          indicator: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.15)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelColor: Theme.of(
                            context,
                          ).bottomNavigationBarTheme.selectedItemColor,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).bottomNavigationBarTheme.unselectedItemColor,
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
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          dividerColor: Colors.transparent,
                          tabs: [
                            _buildTab('assets/icons/calendar.png', 'صلاتي', 0),
                            _buildTab('assets/icons/quran.png', 'قرآني', 1),
                            _buildTab('assets/icons/azkar.png', 'أذكاري', 2),
                          ],
                        ),
                      ),
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
                      ? Theme.of(
                          context,
                        ).bottomNavigationBarTheme.selectedItemColor!
                      : Theme.of(
                          context,
                        ).bottomNavigationBarTheme.unselectedItemColor!,
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
                    ? Theme.of(
                        context,
                      ).bottomNavigationBarTheme.selectedItemColor
                    : Theme.of(
                        context,
                      ).bottomNavigationBarTheme.unselectedItemColor,
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
