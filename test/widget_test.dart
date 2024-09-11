// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_printer/main.dart';
import 'package:pos_printer/utils/global_enum.dart';

void main() {

  test('Return list of order type from order type enum', () {
    List<String> getOrderTypes() {
      String _enumToString (OrderType orderType) {
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
      return OrderType.values.map((orderType) => _enumToString(orderType)).toList();
    }

    print(getOrderTypes());
  });
}
