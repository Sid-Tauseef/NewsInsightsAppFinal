import 'package:flutter/material.dart';
import 'package:client/screens/HomeScreen.dart';
import 'package:client/screens/RecommendScreen.dart';
import 'package:client/screens/OcrScreen.dart';
import 'package:client/screens/CategoryScreen.dart';
import 'package:client/screens/ProfileScreen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  
  // Wrap each screen with a unique key for AnimatedSwitcher.
  final List<Widget> _screens = [
    HomeScreen(key: ValueKey(0)),
    RecommendationScreen(key: ValueKey(1)),
    OcrScreen(key: ValueKey(2)),
    CategoryScreen(key: ValueKey(3)),
    Profile(key: ValueKey(4)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // extend the body behind the bottom nav bar
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Wrap screens with AnimatedSwitcher for smooth transitions
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Stack(
      children: [
        // Positioned widget with side margins for a reduced width look
        Positioned(
          left: 16,
          right: 16,
          bottom: 16, // minimal gap from bottom to maintain floating feel
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: "Home",
                    isActive: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  _NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: "Picks",
                    isActive: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  _NavItem(
                    icon: Icons.camera_alt_outlined,
                    activeIcon: Icons.camera_alt_rounded,
                    label: "Scan",
                    isActive: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  _NavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search_rounded,
                    label: "Search",
                    isActive: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outlined,
                    activeIcon: Icons.person_rounded,
                    label: "Profile",
                    isActive: _selectedIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    Colors.purple.shade100,
                    Colors.blue.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? Colors.purple.shade600 : Colors.grey.shade600,
                key: ValueKey(isActive),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1 : 0,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
