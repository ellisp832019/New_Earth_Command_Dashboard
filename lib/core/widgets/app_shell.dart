import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/route_names.dart';
import '../routing/security_route_policy.dart';
import '../theme/app_colours.dart';
import '../modules/module_navigation.dart';
import '../../features/security/application/security_session_controller.dart';
import '../../features/modules/application/module_hub_controller.dart';
import '../windowing/desktop_presence_controller.dart';
import '../windowing/desktop_window_api.dart';
import 'module_switcher_dropdown.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StreamSubscription<String>? _desktopMessageSubscription;

  @override
  void initState() {
    super.initState();
    _desktopMessageSubscription = DesktopPresenceController.instance.messages
        .listen(_showDesktopToast);
  }

  @override
  void dispose() {
    _desktopMessageSubscription?.cancel();
    super.dispose();
  }

  void _showDesktopToast(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('AppShell build: branch=${widget.navigationShell.currentIndex}');
    }
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
                ? _DesktopShell(navigationShell: widget.navigationShell)
                : _MobileShell(navigationShell: widget.navigationShell),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _MobileNavigationBar(navigationShell: widget.navigationShell),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DesktopWindowBar(
                  title: 'New Earth Command Centre',
                  subtitle: 'Local-first command center',
                ),
                Expanded(
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
            _SidebarSection(
              title: 'Home',
              children: [
                _ShellDestination(
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  selected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                const SizedBox(height: 8),
                _SidebarLink(
                  label: 'Company',
                  icon: Icons.domain_outlined,
                  route: RouteNames.companyCommandCentre,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SidebarSection(
              title: 'Control',
              children: [
                _SidebarLink(
                  label: 'Users & Devices',
                  icon: Icons.verified_user_outlined,
                  route: RouteNames.usersDevices,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SidebarSection(
              title: 'Work',
              children: [
                _ShellDestination(
                  label: 'Assets',
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  selected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                const SizedBox(height: 8),
                _ShellDestination(
                  label: 'Treasury',
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet,
                  selected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
                const SizedBox(height: 8),
                _ShellDestination(
                  label: 'Projects',
                  icon: Icons.folder_outlined,
                  selectedIcon: Icons.folder_rounded,
                  selected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
                const SizedBox(height: 8),
                _ShellDestination(
                  label: 'Tasks',
                  icon: Icons.checklist_outlined,
                  selectedIcon: Icons.checklist_rounded,
                  selected: navigationShell.currentIndex == 4,
                  onTap: () => navigationShell.goBranch(4),
                ),
                const SizedBox(height: 8),
                _ShellDestination(
                  label: 'Planner',
                  icon: Icons.today_outlined,
                  selectedIcon: Icons.today_rounded,
                  selected: navigationShell.currentIndex == 5,
                  onTap: () => navigationShell.goBranch(5),
                ),
                const SizedBox(height: 8),
                _ShellDestination(
                  label: 'More',
                  icon: Icons.apps_outlined,
                  selectedIcon: Icons.apps_rounded,
                  selected: navigationShell.currentIndex == 6,
                  onTap: () => navigationShell.goBranch(6),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SidebarSection(
              title: 'Support',
              children: [
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
                _SidebarLink(
                  label: 'Voice',
                  icon: Icons.mic_none_rounded,
                  route: RouteNames.voice,
                ),
                const _AlexaGatewaySidebarLink(),
              ],
            ),
            const SizedBox(height: 14),
            _SidebarSection(
              title: 'Tools',
              children: [
                _SidebarLink(
                  label: 'Search',
                  icon: Icons.search,
                  route: RouteNames.commandPalette,
                ),
                _SidebarLink(
                  label: 'QR Studio',
                  icon: Icons.print_outlined,
                  route: RouteNames.assetQrLabelStudio,
                ),
                _SidebarLink(
                  label: 'Command Deck',
                  icon: Icons.space_dashboard_outlined,
                  route: RouteNames.commandDeck,
                ),
                _SidebarLink(
                  label: 'Experiments',
                  icon: Icons.science_outlined,
                  route: RouteNames.experimentWorkspace,
                ),
                _SidebarLink(
                  label: 'Engineering',
                  icon: Icons.precision_manufacturing_outlined,
                  route: RouteNames.modulePackage(
                    '01_OMEGA_ENGINEERING_STUDIO_MODULE',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SidebarSection(
              title: 'About',
              children: [
                _SidebarLink(
                  label: 'About',
                  icon: Icons.help_outline,
                  route: RouteNames.aboutHelp,
                ),
              ],
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

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColours.darkMutedText.withValues(alpha: 0.7),
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
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
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Treasury',
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
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive = currentPath == route || currentPath.startsWith('$route/');
    final color = isActive
        ? AppColours.darkText
        : AppColours.darkMutedText.withValues(alpha: 0.96);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColours.darkSurfaceRaised.withValues(alpha: 0.96)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? Border.all(
                        color: AppColours.darkSecondary.withValues(alpha: 0.28),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.15,
                        color: color,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopWindowBar extends ConsumerStatefulWidget {
  const _DesktopWindowBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  ConsumerState<_DesktopWindowBar> createState() => _DesktopWindowBarState();
}

class _DesktopWindowBarState extends ConsumerState<_DesktopWindowBar> {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _syncMaximizedState();
  }

  Future<void> _syncMaximizedState() async {
    if (!DesktopWindowApi.isSupported) {
      return;
    }

    final isMaximized = await DesktopWindowApi.isMaximized();
    if (!mounted) {
      return;
    }

    setState(() {
      _isMaximized = isMaximized;
    });
  }

  Future<void> _toggleMaximize() async {
    if (!DesktopWindowApi.isSupported) {
      return;
    }

    if (_isMaximized) {
      await DesktopWindowApi.restore();
    } else {
      await DesktopWindowApi.maximize();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isMaximized = !_isMaximized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedModule = moduleForPath(modules, currentPath);

    return SizedBox(
      height: 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColours.darkBackground.withValues(alpha: 0.78),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColours.darkOutline.withValues(alpha: 0.9),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DesktopDragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 760;

                      return Row(
                        crossAxisAlignment: isCompact
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          const _BrandMark(size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: isCompact
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                              color: AppColours.darkText,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 22,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      ModuleSwitcherDropdown(
                                        modules: modules,
                                        selectedModule: selectedModule,
                                        launchTargetResolver: (module) => ref
                                            .read(
                                              moduleHubStateRepositoryProvider,
                                            )
                                            .loadLaunchTarget(module.id),
                                        onSelected: (module) {
                                          final target = ref
                                              .read(
                                                moduleHubStateRepositoryProvider,
                                              )
                                              .loadLaunchTarget(module.id);
                                          context.go(
                                            moduleLaunchRoute(module, target),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        selectedModule?.description ?? 
                                            widget.subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: AppColours.darkMutedText,
                                            ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                              color: AppColours.darkText,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 22,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: ModuleSwitcherDropdown(
                                              modules: modules,
                                              selectedModule: selectedModule,
                                              launchTargetResolver: (module) =>
                                                  ref
                                                      .read(
                                                        moduleHubStateRepositoryProvider,
                                                      )
                                                      .loadLaunchTarget(
                                                        module.id,
                                                      ),
                                              onSelected: (module) {
                                                final target = ref
                                                    .read(
                                                      moduleHubStateRepositoryProvider,
                                                    )
                                                    .loadLaunchTarget(
                                                      module.id,
                                                    );
                                                context.go(
                                                  moduleLaunchRoute(
                                                    module,
                                                    target,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              selectedModule?.description ??
                                                  widget.subtitle,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: AppColours
                                                        .darkMutedText,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            _DesktopWindowButton(
              icon: Icons.lock_outline,
              tooltip: 'Lock now',
              onPressed: () async {
                ref.read(securitySessionProvider.notifier).lockNow();
                context.go(
                  SecurityRoutePolicy.securityLockFrom(
                    GoRouterState.of(context).uri,
                  ),
                );
              },
            ),
            _DesktopWindowButton(
              icon: Icons.bedtime_outlined,
              tooltip: 'Sleep quietly',
              onPressed: () async {
                await DesktopPresenceController.instance.sleep();
              },
            ),
            _DesktopWindowButton(
              icon: _isMaximized
                  ? Icons.filter_none_rounded
                  : Icons.crop_square_rounded,
              tooltip: _isMaximized ? 'Restore' : 'Maximize',
              onPressed: _toggleMaximize,
            ),
            _DesktopWindowButton(
              icon: Icons.power_settings_new_rounded,
              tooltip: 'Exit completely',
              accent: true,
              onPressed: () async {
                await DesktopPresenceController.instance.requestShutdown();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopWindowButton extends StatelessWidget {
  const _DesktopWindowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final foreground = accent
        ? AppColours.darkAmber
        : AppColours.darkText.withValues(alpha: 0.88);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 56,
          child: Icon(icon, size: 18, color: foreground),
        ),
      ),
    );
  }
}

class _AlexaGatewaySidebarLink extends StatelessWidget {
  const _AlexaGatewaySidebarLink();

  @override
  Widget build(BuildContext context) {
    return _SidebarLink(
      label: 'Alexa',
      icon: Icons.hub_outlined,
      route: RouteNames.alexaVoiceGateway,
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
