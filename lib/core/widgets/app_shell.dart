import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/route_names.dart';
import '../theme/app_colours.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _ShellBackground(),
          SafeArea(
            child: isWide
                ? _DesktopShell(navigationShell: navigationShell)
                : _MobileShell(navigationShell: navigationShell),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _MobileNavigationBar(navigationShell: navigationShell),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColours.darkBackground.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColours.darkText.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 38,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Row(
              children: [
                _Sidebar(navigationShell: navigationShell),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return navigationShell;
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 136,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColours.darkBackground.withValues(alpha: 0.76),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        border: Border(
          right: BorderSide(
            color: AppColours.darkOutline.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _BrandMark(size: 54),
            const SizedBox(height: 18),
            _ShellDestination(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              selected: navigationShell.currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),
            const SizedBox(height: 8),
            _ShellDestination(
              label: 'Assets',
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              selected: navigationShell.currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),
            const SizedBox(height: 8),
            _ShellDestination(
              label: 'Projects',
              icon: Icons.folder_outlined,
              selectedIcon: Icons.folder_rounded,
              selected: navigationShell.currentIndex == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
            const SizedBox(height: 8),
            _ShellDestination(
              label: 'Tasks',
              icon: Icons.checklist_outlined,
              selectedIcon: Icons.checklist_rounded,
              selected: navigationShell.currentIndex == 3,
              onTap: () => navigationShell.goBranch(3),
            ),
            const SizedBox(height: 8),
            _ShellDestination(
              label: 'Planner',
              icon: Icons.today_outlined,
              selectedIcon: Icons.today_rounded,
              selected: navigationShell.currentIndex == 4,
              onTap: () => navigationShell.goBranch(4),
            ),
            const SizedBox(height: 8),
            _ShellDestination(
              label: 'More',
              icon: Icons.apps_outlined,
              selectedIcon: Icons.apps_rounded,
              selected: navigationShell.currentIndex == 5,
              onTap: () => navigationShell.goBranch(5),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColours.darkOutline.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            _SidebarLink(
              label: 'Journal',
              icon: Icons.menu_book_outlined,
              route: RouteNames.journal,
            ),
            _SidebarLink(
              label: 'Learning',
              icon: Icons.school_outlined,
              route: RouteNames.learning,
            ),
            _SidebarLink(
              label: 'Content',
              icon: Icons.campaign_outlined,
              route: RouteNames.content,
            ),
            _SidebarLink(
              label: 'Business',
              icon: Icons.handshake_outlined,
              route: RouteNames.business,
            ),
            _SidebarLink(
              label: 'Wellbeing',
              icon: Icons.favorite_border,
              route: RouteNames.wellbeing,
            ),
            _SidebarLink(
              label: 'Inbox',
              icon: Icons.inbox_outlined,
              route: RouteNames.inbox,
            ),
            const SizedBox(height: 16),
            Text(
              'Local-first',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Assets',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination extends StatelessWidget {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColours.darkText : AppColours.darkMutedText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColours.darkSurfaceRaised.withValues(alpha: 0.96)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? Border.all(
                    color: AppColours.darkSecondary.withValues(alpha: 0.34),
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  const _SidebarLink({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: TextButton.icon(
        onPressed: () => context.push(route),
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: AppColours.darkMutedText,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          minimumSize: const Size.fromHeight(36),
          alignment: Alignment.centerLeft,
          textStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.15),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163B5B), Color(0xFF0E1D2F)],
        ),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColours.darkSecondary.withValues(alpha: 0.22),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              height: size * 0.18,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(100, 28)),
                gradient: LinearGradient(
                  colors: [Color(0xFF2D93F4), Color(0xFF9EE4F6)],
                ),
              ),
            ),
          ),
          Icon(Icons.spa_rounded, color: Colors.white, size: size * 0.46),
          Positioned(top: 12, left: 15, child: _BrandStar(size: size * 0.07)),
          Positioned(top: 16, right: 14, child: _BrandStar(size: size * 0.08)),
        ],
      ),
    );
  }
}

class _BrandStar extends StatelessWidget {
  const _BrandStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ShellBackground extends StatelessWidget {
  const _ShellBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF030A15), Color(0xFF071423), Color(0xFF0C1D2A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            left: -120,
            child: _GlowOrb(
              size: 380,
              color: AppColours.darkSecondary.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            right: -180,
            bottom: -160,
            child: _GlowOrb(
              size: 420,
              color: AppColours.darkPrimary.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 120,
            right: 180,
            child: _GlowOrb(
              size: 240,
              color: AppColours.darkGlow.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
