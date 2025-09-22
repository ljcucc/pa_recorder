import 'package:flutter/material.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/pages/new_record_page.dart';
import 'package:pa_recorder/data/record_repository.dart'; // For Record class
import 'package:pa_recorder/pages/edit_record_page.dart'; // For EditRecordPage
import 'package:provider/provider.dart';

class AdaptiveNavigationScaffold extends StatefulWidget {
  final Widget child;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.child,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  int _selectedIndex = 0;

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
            appBar: AppBar(
              title: const Text('PA Recorder'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    await context.read<DirectoryProvider>().selectDirectory();
                    // The child (BrowseRecordsPage) will react to this change via its watch on DirectoryProvider.
                  },
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (index == 0) {
                      // Browse Records
                      // The child is already BrowseRecordsPage, so no explicit navigation needed here.
                    } else if (index == 1) {
                      // New Record
                      _handleNewRecordAction();
                    }
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_open),
                      label: Text('Browse'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add),
                      label: Text('New Record'),
                    ),
                    // Add more destinations as needed
                  ],
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _handleNewRecordAction,
              child: const Icon(Icons.add),
            ),
          );
        } else {
          // Small screen: BottomNavigationBar
          return Scaffold(
            appBar: AppBar(
              title: const Text('PA Recorder'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    await context.read<DirectoryProvider>().selectDirectory();
                    // The child (BrowseRecordsPage) will react to this change via its watch on DirectoryProvider.
                  },
                ),
              ],
            ),
            body: widget.child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 0) {
                  // Browse Records
                  // The child is already BrowseRecordsPage, so no explicit navigation needed here.
                } else if (index == 1) {
                  // New Record
                  _handleNewRecordAction();
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_open),
                  label: 'Browse',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'New Record',
                ),
                // Add more items as needed
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _handleNewRecordAction,
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
