import 'package:flutter/material.dart';
import 'package:pa_recorder/pages/new_record_page.dart';
import 'package:pa_recorder/pages/browse_records_page.dart';
import 'package:pa_recorder/data/record_repository.dart'; // For Record class
import 'package:pa_recorder/pages/edit_record_page.dart'; // For EditRecordPage
import 'package:pa_recorder/pages/welcome_page.dart';
import 'package:pa_recorder/pages/settings_page.dart';
import 'package:gap/gap.dart';

class AdaptiveNavigationScaffold extends StatefulWidget {
  const AdaptiveNavigationScaffold({
    super.key,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() =>
      _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState
    extends State<AdaptiveNavigationScaffold> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newIndex = ModalRoute.of(context)?.settings.arguments;
    if (newIndex is int && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  late final List<Widget> _pages = <Widget>[
    const WelcomePage(),
    const BrowseRecordsPage(),
    const SettingsPage(),
  ];

  Future<void> _handleNewRecordAction() async {
    final newRecord = await Navigator.push<Record?>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewRecordPage(),
      ),
    );

    if (newRecord != null) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRecordPage(record: newRecord),
        ),
      );
      // After returning from EditRecordPage, the BrowseRecordsPage (child) should refresh
      // because it watches DirectoryProvider and RecordRepository (implicitly via didChangeDependencies).
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Large screen: NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  groupAlignment: -1.0,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Welcome'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_open),
                      label: Text('Browse'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  leading: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: _handleNewRecordAction,
                        elevation: 0.0,
                        highlightElevation: 0.0,
                        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                        child: const Icon(Icons.add),
                      ),
                      const Gap(16), // Gap after FAB
                    ],
                  ),
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          );
        } else {
          // Small screen: BottomNavigationBar
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                // No special action for index 1 (now Info page)
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Welcome',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_open),
                  label: 'Browse',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _handleNewRecordAction,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }
      },
    );
  }
}
