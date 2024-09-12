import 'package:pos_printer/models/order_item.dart';

import '../utils/global_enum.dart';

class Order {
  String orgName;
  String merchantName;
  String merchantAddress;
  OrderType orderType;
  List<OrderItem> orderItems;
  double nettTotal;
  PaymentType paymentType;
  double amountPaid;
  double change;

  Order({
    required this.orgName,
    required this.merchantName,
    required this.merchantAddress,
    required this.orderType,
    required this.orderItems,
    required this.nettTotal,
    required this.paymentType,
    required this.amountPaid,
    required this.change
  });
}