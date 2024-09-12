import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_printer/views/printer_form_page.dart';
import 'package:pos_printer/utils/global_enum.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ScanBluetoothPage extends StatefulWidget {
  const ScanBluetoothPage({super.key});

  @override
  State<ScanBluetoothPage> createState() => _ScanBluetoothPageState();
}

class _ScanBluetoothPageState extends State<ScanBluetoothPage> {
  List<BluetoothInfo> _devices = [];
  bool connected = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _startScanPairedDevices() async {
    setState(() {
      _devices = [];
    });
    _devices = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothConnect,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Select Bluetooth Printer'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              if (connected) {
                await PrintBluetoothThermal.disconnect;
                setState(() {
                  connected = false;
                });
                Fluttertoast.showToast(msg: 'Paired device disconnected');
              } else {
                bool connected = await PrintBluetoothThermal.connect(macPrinterAddress: _devices[index].macAdress);
                Fluttertoast.showToast(msg: 'Connection Successful');
                if (connected) {
                  if (!mounted) return;
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const PrinterFormPage(posPrintType: PosPrintType.bluetooth)
                        )
                    );
                } else {
                  Fluttertoast.showToast(msg: 'Connection Failed');
                }
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.print),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(_devices[index].name),
                            Text(_devices[index].macAdress),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        },
      ) ,
      floatingActionButton: FloatingActionButton(onPressed: () {
        _startScanPairedDevices();
      })// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}