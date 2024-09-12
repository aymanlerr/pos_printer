import 'package:flutter/material.dart';
import 'package:pos_printer/models/order.dart';
import 'package:pos_printer/models/order_item.dart';
import 'package:pos_printer/utils/global_enum.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../utils/helpers.dart';

class PrinterFormPage extends StatefulWidget {
  const PrinterFormPage({super.key, required this.posPrintType});

  final PosPrintType posPrintType;

  @override
  State<StatefulWidget> createState() => _PrinterFormPageState();
}

class _PrinterFormPageState extends State<PrinterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController(text: '888 Plaza');
  final _merchantNameController = TextEditingController(text: "Aiman's Burger");
  final _merchantAddressController = TextEditingController(text: 'Singapore 730888');
  final _orderNoController = TextEditingController(text: '1');
  OrderType _selectedOrderType = OrderType.dineIn;
  List<OrderItem> orderItems = [];
  PaymentType _selectedPaymentType = PaymentType.cash;
  final _amountPaidController = TextEditingController(text: '0.00');
  bool _isPaymentTypeCash = true;

  @override
  void dispose() {
    super.dispose();
    _orgNameController.dispose();
    _merchantNameController.dispose();
    _merchantAddressController.dispose();
    _orderNoController.dispose();
    _amountPaidController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isPageSetupCorrectly();
  }

  Widget generateFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _orgNameController,
            decoration: const InputDecoration(
              labelText: 'Organization Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the organization name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _merchantNameController,
            key: _formKey,
            decoration: const InputDecoration(
              labelText: 'Merchant Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the merchant name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _merchantAddressController,
            key: _formKey,
            decoration: const InputDecoration(
              labelText: 'Merchant Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the merchant address';
              }
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _orderNoController,
            key: _formKey,
            decoration: const InputDecoration(
              labelText: 'Order No.',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the order no.';
              }
              return null;
            },
          ),
          DropdownButtonFormField<OrderType>(
            value: _selectedOrderType,
            decoration: const InputDecoration(
                labelText: 'Select Order Type'
            ),
            onChanged: (OrderType? newValue) {
              setState(() {
                if (newValue != null) {
                  _selectedOrderType = newValue;
                }
              });
            },
            validator: (OrderType? value) {
              if (value == null) {
                return 'Please select an order type';
              }
              return null;
            },
            items: OrderType.values.map((OrderType orderType) {
              return DropdownMenuItem<OrderType>(
                value: orderType,
                child: Text(getOrderTypes()[OrderType.values.indexOf(orderType)]),
              );
            }).toList(),
          ),
          //TODO: create form fields to easily add order items
          DropdownButtonFormField<PaymentType>(
            value: _selectedPaymentType,
            decoration: const InputDecoration(
                labelText: 'Select Payment Type'
            ),
            onChanged: (PaymentType? newValue) {
              setState(() {
                if (newValue != null) {
                  _selectedPaymentType = newValue;
                  _isPaymentTypeCash = newValue == PaymentType.cash ? true : false;
                }
              });
            },
            validator: (PaymentType? value) {
              if (value == null) {
                return 'Please select a payment type';
              }
              return null;
            },
            items: PaymentType.values.map((PaymentType paymentType) {
              return DropdownMenuItem<PaymentType>(
                value: paymentType,
                child: Text(getPaymentTypes()[PaymentType.values.indexOf(paymentType)]),
              );
            }).toList(),
          ),
          TextFormField(
            enabled: _isPaymentTypeCash,
            keyboardType: TextInputType.number,
            controller: _amountPaidController,
            key: _formKey,
            decoration: const InputDecoration(
              labelText: 'Amount Paid by Customer',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the amount paid by customer';
              }
              return null;
            },
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // create Order
                  final double nettTotal = calculateNettTotal(orderItems: orderItems);
                  final double amountPaid = double.parse(_amountPaidController.text);
                  final double change = calculateOrderChange(paymentType: _selectedPaymentType, nettTotal: nettTotal, amountPaid: amountPaid);
                  final Order order = Order(
                      orgName: _orgNameController.text,
                      merchantName: _merchantNameController.text,
                      merchantAddress: _merchantAddressController.text,
                      orderType: _selectedOrderType,
                      orderItems: orderItems,
                      nettTotal: nettTotal,
                      paymentType: _selectedPaymentType,
                      amountPaid: amountPaid,
                      change: change
                  );
                  if (widget.posPrintType == PosPrintType.bluetooth) {
                    posPrint(posPrintType: widget.posPrintType, order: order);
                  } else if (widget.posPrintType == PosPrintType.usb) {
                    posPrint(posPrintType: widget.posPrintType, order: order, );
                  }

                }
              },
              child: const Text('Print')
          )
        ],
      ),
    );
  }

  Future<void> _showErrorDialog({required String errorMsg}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Printer Form Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMsg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go to previous page which is scan bluetooth printers
              },
            ),
          ],
        );
      },
    );
  }

  void _isPageSetupCorrectly() async {
    if (widget.posPrintType == PosPrintType.bluetooth) {
      if (!await PrintBluetoothThermal.connectionStatus) {
        await _showErrorDialog(errorMsg: 'Bluetooth Printer not connected');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Printer Form'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
              generateFormFields(),
          ],
        ),
      ),
    );
  }
}