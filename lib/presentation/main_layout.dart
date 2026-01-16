import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
          backgroundColor: AppColors.background.withOpacity(0.95),
          items: const [
            BottomNavigationBarItem(label: 'Accueil', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Transac', icon: Icon(Icons.bar_chart)),
            BottomNavigationBarItem(label: 'Épargne', icon: Icon(Icons.savings)),
            BottomNavigationBarItem(label: 'Param.', icon: Icon(Icons.settings)),
          ],
        ),
      ),
    );
  }
}
