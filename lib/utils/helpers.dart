import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pos_printer/models/order_item.dart';
import 'package:pos_printer/utils/secret.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/order.dart';
import 'global_enum.dart';

String formatErrorMsg({required error, required stacktrace}) {
  return 'Error:\n$error\nStacktrace:\n$stacktrace';
}

String enumToString({required StringType stringType, OrderType? orderType, PaymentType? paymentType, bool upperCase = false}) {
  try {
    if (orderType == null && paymentType == null) {
      throw 'Please provide either the OrderType or PaymentType';
    }

    String enumString = orderType != null ? orderType.toString() : paymentType.toString();
    String name = enumString.split('.').last;
    RegExp regExp = RegExp('([a-z])([A-Z])');
    late String formatted;
    if (stringType == StringType.withDash) {
      formatted = name.replaceAllMapped(regExp, (match) {
        return '${match.group(1)}-${match.group(2)}';
      });
      formatted = formatted.split('-').map((word) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }).join('-');
    } else if (stringType == StringType.noDash) {
      formatted = name.replaceAllMapped(regExp, (match) {
        return '${match.group(1)} ${match.group(2)}';
      });
    }
    if (upperCase) {
      formatted = formatted.toUpperCase();
    }
    return formatted;
  } catch (e) {
    rethrow;
  }
}

List<String> getOrderTypes() {
  try {
    return OrderType.values.map((orderType) => enumToString(stringType: StringType.withDash, orderType: orderType)).toList();
  } catch (e) {
    rethrow;
  }

}

List<String> getPaymentTypes() {
  try {
    return PaymentType.values.map((paymentType) => enumToString(stringType: StringType.noDash, upperCase: true, paymentType: paymentType)).toList();
  } catch (e) {
    rethrow;
  }
}

double calculateNettTotal({List<OrderItem>? orderItems}) {
  try {
    double nettTotal = 0.00;
    if (orderItems != null) {
      for (var item in orderItems) {
        nettTotal += item.price*item.quantity;
      }
    }

    return nettTotal;
  } catch (e) {
    rethrow;
  }
}

double calculateOrderChange({PaymentType? paymentType, double? nettTotal, double? amountPaid}) {
  try {
    double change = 0.00;

    if (paymentType == PaymentType.cash) {
      if (nettTotal == null) {
        throw 'Please provide the order nett total';
      }

      if (amountPaid == null) {
        throw 'Please provide the amount paid by the customer';
      }

      change += nettTotal-amountPaid;
    } else if (paymentType == PaymentType.sgqr) {
      change = 0.00;
    }

    return change;
  } catch (e) {
    rethrow;
  }
}

Future<List<int>> createReceipt(
    PaperSize paper,
    CapabilityProfile profile,
    Order order
    ) async {
  final Generator ticket = Generator(paper, profile);
  List<int> bytes = [];

  bytes += ticket.text(
      order.orgName,
      styles: const PosStyles(
          align: PosAlign.center, bold: true, height: PosTextSize.size2),
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
  String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(
      DateTime.now());
  bytes +=
      ticket.text(formattedDate, styles: const PosStyles(align: PosAlign.left));
  bytes +=
      ticket.text('Order No: ', styles: const PosStyles(align: PosAlign.left));
  bytes += ticket.text('Type: ${enumToString(stringType: StringType.withDash, orderType: order.orderType)}',
      styles: const PosStyles(align: PosAlign.left));
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
          styles: const PosStyles(align: PosAlign.left),
          containsChinese: true
      ),
      PosColumn(
          text: item.price.toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.left)
      ),
    ]);
  }
  bytes += ticket.hr();

  // nett total, cash/sgqr, change
  bytes += ticket.row([
    PosColumn(
        text: 'Nett Total',
        width: 10,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
    PosColumn(
        text: '\$${order.nettTotal}',
        width: 2,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
  ]);
  bytes += ticket.row([
    PosColumn(
      text: enumToString(stringType: StringType.noDash, paymentType: order.paymentType),
      width: 10,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
    PosColumn(
        text: '\$${order.amountPaid}',
        width: 2,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
  ]);
  bytes += ticket.row([
    PosColumn(
        text: 'CHANGE',
        width: 10,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
    PosColumn(
        text: '\$${order.change}',
        width: 2,
        styles: const PosStyles(align: PosAlign.left, bold: true)
    ),
  ]);

  // thank you text
  bytes += ticket.text('');
  bytes += ticket.text('Thank you & Please come again!', styles: const PosStyles(align: PosAlign.center));
  bytes += ticket.text(companyUrl, styles: const PosStyles(align: PosAlign.center));

  // feed
  bytes += ticket.text('');
  bytes += ticket.text('');
  bytes += ticket.text('');
  bytes += ticket.text('');
  bytes += ticket.text('');

  return bytes;
}

void posPrint({
  required PosPrintType posPrintType,
  required Order order,
  //TODO: implement usb printing
}) async {
  if (posPrintType == PosPrintType.bluetooth) {
    const PaperSize paper = PaperSize.mm58;
    final profile = await CapabilityProfile.load();
    bool res = await PrintBluetoothThermal.writeBytes(await createReceipt(paper, profile, order));
    Fluttertoast.showToast(msg: res.toString());
  } else if (posPrintType == PosPrintType.usb) {
    //TODO: implement usb printing here
  }

}