import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';

class AppBottomNav extends StatelessWidget {
  final String currentLocation;

  const AppBottomNav({
    super.key,
    required this.currentLocation,
  });

  int _currentIndex() {
    if (currentLocation.startsWith('/home') || currentLocation == '/') {
      return 0;
    }
    if (currentLocation.startsWith('/map')) {
      return 1;
    }
    if (currentLocation.startsWith('/community')) {
      return 2;
    }
    if (currentLocation.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/community');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppElevation.level3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: BottomNavigationBar(
            currentIndex: _currentIndex(),
            onTap: (index) => _onTap(context, index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}