import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_printer/utils/global_enum.dart';

import '../utils/helpers.dart';

class PrintFormPage extends StatefulWidget {
  const PrintFormPage({super.key, required this.printer});

  final PrinterBluetooth printer;

  @override
  State<StatefulWidget> createState() => _PrintFormPageState();
}

class _PrintFormPageState extends State<PrintFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController(text: 'Food Canopy');
  final _merchantNameController = TextEditingController();
  final _merchantAddressController = TextEditingController();
  final _orderNoController = TextEditingController();
  OrderType _selectedOrderType = OrderType.dineIn;

  final _orderNettTotalController = TextEditingController(text: calculateNettTotal(null).toString());
  final _orderPaymentTypeController = TextEditingController();
  final _orderPaymentTypeValueController = TextEditingController();
  final _orderChangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                _selectedOrderType = newValue!;
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
          //TODO: create formfields to easily add order items

          TextFormField(
            readOnly: true,
            controller: _orderNettTotalController,
            key: _formKey,
            decoration: const InputDecoration(
              labelText: 'Nett Total',
              border: OutlineInputBorder(),
            ),
          ),



        ],
      ),
    );
  }

}