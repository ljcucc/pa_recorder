import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pa_recorder/providers/hello_provider.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  static const String routeName = '/hello';

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hello! This is your first time here.',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await Provider.of<HelloProvider>(context, listen: false).setHasHello(true);
                if (!mounted) return;
                navigator.pushReplacementNamed('/');
              },
              child: const Text('Continue to App'),
            ),
          ],
        ),
      ),
    );
  }
}
