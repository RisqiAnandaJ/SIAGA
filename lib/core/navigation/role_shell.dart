import 'package:flutter/material.dart';

import '../../features/pamdal/absensi_jadwal_page.dart';
import '../../features/pamdal/incident_pages.dart';
import '../../features/pamdal/pamdal_home_page.dart';
import '../../features/pamdal/patrol_page.dart';
import '../../features/pic/pic_dashboard_page.dart';
import '../../features/pic/pic_incident_pages.dart';
import '../../features/pic/pic_operational_page.dart';
import '../../features/pic/pic_report_page.dart';
import '../../features/pic/personnel_pages.dart';
import '../../features/pimpinan/pimpinan_incident_report_pages.dart';
import '../../features/pimpinan/pimpinan_pages.dart';
import '../state/session.dart';
import '../theme/siaga_colors.dart';
import '../widgets/siaga_dock.dart';

/// Kerangka berperan: satu dock persisten, konten tab berganti sesuai peran.
class RoleShell extends StatelessWidget {
  const RoleShell({super.key});

  List<Widget> _pages(UserRole role) => switch (role) {
    UserRole.pamdal => const [
      PamdalHomePage(),
      AbsensiJadwalPage(),
      PatrolPage(),
      MyIncidentsPage(),
    ],
    UserRole.picPamdal => const [
      PicDashboardPage(),
      PicOperationalPage(),
      PicIncidentListPage(),
      PersonnelDirectoryPage(),
      PicReportPage(),
    ],
    UserRole.pimpinan => const [
      ExecutiveSummaryPage(),
      MonitoringPage(),
      ExecutiveIncidentPage(),
      ExecutiveReportPage(),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final role = session.role ?? UserRole.pamdal;
    final pages = _pages(role);
    final tab = session.tab.clamp(0, pages.length - 1);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: SiagaColors.abyssalNavy,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey('$role-$tab'),
                  child: pages[tab],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SiagaDock(
                items: dockItemsFor(role),
                index: tab,
                onTap: session.selectTab,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
