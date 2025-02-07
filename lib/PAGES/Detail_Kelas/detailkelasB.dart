import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 2; // Default to home (middle item)
  late AnimationController _animationController;
  late List<Animation<double>> _bounceAnimations;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.newspaper, label: 'Berita'),
    NavItem(icon: Icons.chat_bubble, label: 'Chat'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.calendar_today, label: 'Absen'),
    NavItem(icon: Icons.grade, label: 'Grade'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceAnimations = List.generate(
      _navItems.length,
      (index) => Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.8,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: List.generate(_navItems.length, (index) {
          return BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _bounceAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: index == _selectedIndex 
                      ? _bounceAnimations[index].value 
                      : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: index == _selectedIndex
                          ? Colors.purple.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _navItems[index].icon,
                      color: index == _selectedIndex 
                          ? Colors.purple 
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
            label: _navItems[index].label,
          );
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}