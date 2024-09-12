import 'package:flutter/material.dart';
import 'package:pos_printer/utils/global_enum.dart';
import 'package:pos_printer/views/scan_bluetooth.dart';

class SelectPrintModePage extends StatefulWidget {
  const SelectPrintModePage({super.key});

  @override
  State<StatefulWidget> createState() => _SelectPrintModePageState();
}

class _SelectPrintModePageState extends State<SelectPrintModePage> {

  final Map<PosPrintType, String> printTypeNames = {
    PosPrintType.usb: 'USB Printer',
    PosPrintType.bluetooth: 'Bluetooth Printer',
  };

  void _goToRespectivePage(PosPrintType posPrintType) {
    if (posPrintType == PosPrintType.bluetooth) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const ScanBluetoothPage()
        )
      );
    } else if (posPrintType == PosPrintType.usb) {
      //TODO: Navigate to usb page
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Select Print Mode'),
      ),
      body: ListView.builder(
        itemCount: PosPrintType.values.length,
        itemBuilder: (BuildContext context, int index) {
          final printType = PosPrintType.values[index];
          final printTypeName = printTypeNames[printType] ?? printType.toString();

          return GestureDetector(
            onTap: () => _goToRespectivePage(printType),
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(printTypeName),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          );
        },
      )
    );
  }

}