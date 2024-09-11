import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../printer_form/order.dart';
import '../printer_form/order_item.dart';

class ScanBluetoothPage extends StatefulWidget {
  const ScanBluetoothPage({super.key, required this.title});

  final String title;

  @override
  State<ScanBluetoothPage> createState() => _ScanBluetoothPageState();
}

class _ScanBluetoothPageState extends State<ScanBluetoothPage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    printerManager.scanResults.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
  }

  Future<List<int>> _demoReceipt(
      PaperSize paper,
      CapabilityProfile profile,
      Order order
      ) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

    bytes += ticket.text(
        order.orgName,
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
        containsChinese: true // Specify the charset to handle non-ASCII characters
    );
    bytes += ticket.text(
        order.merchantName,
        styles: const PosStyles(align: PosAlign.center),
        containsChinese: true // Specify the charset to handle non-ASCII characters
    );
    bytes += ticket.text(
        order.merchantAddress,
        styles: const PosStyles(align: PosAlign.center),
        containsChinese: true // Specify the charset to handle non-ASCII characters
    );
    bytes += ticket.text('Tax Invoice');
    bytes += ticket.text('');

    // Format the current date and time
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bytes += ticket.text(formattedDate, styles: const PosStyles(align: PosAlign.left));
    bytes += ticket.text('Order No: ', styles: const PosStyles(align: PosAlign.left));
    bytes += ticket.text('Type: ${order.orderType}', styles: const PosStyles(align: PosAlign.left));
    bytes += ticket.text('');

    // table of orders
    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Item', width: 8),
      PosColumn(text: 'Price', width: 2),
    ]);
    bytes += ticket.hr();

    for (OrderItem item in order.orderItems) {
      bytes += ticket.row([
        PosColumn(
            text: item.quantity.toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.left)
        ),
        PosColumn(
            text: item.name,
            width: 8,
            styles: const PosStyles(align: PosAlign.left)
        ),
        PosColumn(
            text: item.price.toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.left)
        ),
      ]);
    }
    bytes += ticket.hr();
    bytes += ticket.row([
      // PosColumn(
      //     text: 'Total',
      //     width: 10,
      //     styles: const PosStyles(align: PosAlign.left, bold: true)
      // ),
      // PosColumn(
      //     text: order.orderItems.fold(0, (prev, item) => prev + item.price).toString(),
      //     width: 2,
      //     styles: const PosStyles(align: PosAlign.left, bold: true)
      // ),
    ]);



    // ticket.cut();
    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm58;
    final profile = await CapabilityProfile.load();
    // final PosPrintResult res = await printerManager.printTicket(await _demoReceipt(paper, profile));
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(res.msg),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => _testPrint(_devices[index]),
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
                            Text(_devices[index].name ?? ''),
                            Text(_devices[index].address!),
                            const Text(
                                'Click to print a test receipt'
                            )
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
      floatingActionButton: StreamBuilder<bool>(
          stream: printerManager.isScanningStream,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                onPressed: _stopScanDevices,
                tooltip: 'Stop scan',
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                onPressed: _startScanDevices,
                tooltip: 'Scan',
                child: const Icon(Icons.search),
              );
            }
          }
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}