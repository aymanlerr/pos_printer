import 'package:pos_printer/printer_form/order.dart';
import 'package:pos_printer/printer_form/order_item.dart';

import 'global_enum.dart';

List<String> getOrderTypes() {
  String enumToString (OrderType orderType) {
    // Convert the enum value to a string
    String enumString = orderType.toString();

    // Extract the enum name after the dot
    String name = enumString.split('.').last;

    // Convert camel case to human-readable format
    // Split by uppercase letters and join with hyphens
    RegExp regExp = RegExp('([a-z])([A-Z])');
    String formatted = name.replaceAllMapped(regExp, (match) {
      return '${match.group(1)}-${match.group(2)}';
    });

    // Capitalize the first letter of each word
    formatted = formatted.split('-').map((word) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join('-');

    return formatted;
  }
  return OrderType.values.map((orderType) => enumToString(orderType)).toList();
}

double calculateNettTotal(List<OrderItem>? orderItems) {
  double nettTotal = 0.0;

  if (orderItems != null) {
    for (var item in orderItems) {
      nettTotal += item.price;
    }
  }

  return nettTotal;
}