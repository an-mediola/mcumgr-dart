import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mcumgr_example/scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.location.request();
  await Permission.locationWhenInUse.request();
  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();
  await Permission.storage.request();

  final flutterReactiveBle = FlutterReactiveBle();
  final scanner = Scanner(
    flutterReactiveBle,
    // withServices: [Uuid.parse("8d53dc1d-1db7-4cd3-868b-8a527460aa84")],
  );

  runApp(MyApp(
    flutterReactiveBle: flutterReactiveBle,
    scanner: scanner,
  ));
}

class MyApp extends StatelessWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final Scanner scanner;

  const MyApp({
    Key? key,
    required this.flutterReactiveBle,
    required this.scanner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mcumgr',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        flutterReactiveBle: flutterReactiveBle,
        scanner: scanner,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
    required this.flutterReactiveBle,
    required this.scanner,
  }) : super(key: key);

  final FlutterReactiveBle flutterReactiveBle;
  final Scanner scanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mcumgr'),
      ),
      body: Center(
        child: StreamBuilder<ScannerState>(
          stream: scanner.stream,
          initialData: ScannerState.empty(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            final data = snapshot.data!;
            final items = data.devices
                // .where(
                //   (element) => element.name.toLowerCase().contains('amir'),
                // )
                .toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final device = items[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id),
                  trailing: Text(device.rssi.toString()),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return DeviceScreen(
                          ble: flutterReactiveBle,
                          device: device,
                        );
                      },
                    ));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
