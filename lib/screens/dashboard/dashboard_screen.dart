import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'tabs/home_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/ai_assistant_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/admin_home_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/manager_home_tab.dart';
import 'tabs/team_tab.dart';
import 'tabs/analytics_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final role = user?.role ?? 'user';

        final tabs = _getTabsForRole(role);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: tabs),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavigationItems(role),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getTabsForRole(String role) {
    switch (role) {
      case 'admin':
        return [
          const AdminHomeTab(),
          const ProjectsTab(),
          const AdminUsersTab(),
          const ProfileTab(),
        ];
      case 'manager':
        return [
          const AnalyticsTab(),
          const ProjectsTab(),
          const TeamTab(),
          const ProfileTab(),
        ];
      case 'user':
      default:
        return [
          const HomeTab(),
          const ProjectsTab(),
          const AIAssistantTab(),
          const ProfileTab(),
        ];
    }
  }

  List<Widget> _buildNavigationItems(String role) {
    switch (role) {
      case 'admin':
        return [
          _buildNavItem(
            0,
            Icons.dashboard_outlined,
            Icons.dashboard,
            'Dashboard',
          ),
          _buildNavItem(1, Icons.folder_outlined, Icons.folder, 'Projects'),
          _buildNavItem(2, Icons.people_outline, Icons.people, 'Users'),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
        ];
      case 'manager':
        return [
          _buildNavItem(
            0,
            Icons.analytics_outlined,
            Icons.analytics,
            'Analytics',
          ),
          _buildNavItem(1, Icons.folder_outlined, Icons.folder, 'Projects'),
          _buildNavItem(2, Icons.group_outlined, Icons.group, 'Team'),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
        ];
      case 'user':
      default:
        return [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
          _buildNavItem(1, Icons.folder_outlined, Icons.folder, 'Projects'),
          _buildNavItem(2, Icons.psychology_outlined, Icons.psychology, 'AI'),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
        ];
    }
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingS),
            decoration: BoxDecoration(
              color: isActive
                  ? AppConstants.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppConstants.primaryColor : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppConstants.primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
