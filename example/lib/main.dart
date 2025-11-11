import 'package:flutter/material.dart';
import 'package:simple_permission_workflow/core/spw_permission.dart';
import 'package:simple_permission_workflow/core/spw_response.dart';
import 'package:simple_permission_workflow/simple_permission_workflow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SimplePermissionWorkflow spw = SimplePermissionWorkflow();

  Widget testDialog(BuildContext context) => AlertDialog(
    title: const Text('Hello 👋'),
    content: const Text('This is an AlertDialog!'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    spw = spw.withRationale(
      buildContext: context,
      rationaleWidget: testDialog(context),
      permanentlyDeniedRationaleWidget: testDialog(context),
      openSettingsOnDismiss: true,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('Testing plugin')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _doAction(),
        tooltip: 'Do action',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _doAction() async {
    SPWResponse spwResponse = await spw.launchWorkflow(SPWPermission.contacts);
    print(spwResponse.granted);
    print(spwResponse.reason);
  }
}
