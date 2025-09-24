// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';

// import 'package:pa_recorder/main.dart';
// import 'package:pa_recorder/directory_provider.dart';
// import 'package:pa_recorder/data/record_repository.dart';
// import 'package:pa_recorder/data/file_system_record_repository.dart';
// import 'package:pa_recorder/pages/browse_records_page.dart'; // Add this import

void main() {
//   group('PARecorderApp Widget Tests', () {
//     testWidgets('App starts and displays BrowseRecordsPage',
//         (WidgetTester tester) async {
//       // Build our app and trigger a frame.
//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (context) => DirectoryProvider()),
//             Provider<RecordRepository>(
//               create: (context) => FileSystemRecordRepository(
//                 context.read<DirectoryProvider>(),
//               ),
//             ),
//           ],
//           child: const PARecorderApp(),
//         ),
//       );

//       // Verify that BrowseRecordsPage is displayed.
//       expect(find.byType(BrowseRecordsPage), findsOneWidget);
//       expect(find.text('Browse Records'), findsOneWidget);
//     });
//   });
}
