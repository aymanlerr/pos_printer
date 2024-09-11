import 'package:pos_printer/order_item.dart';

class Order {
  String orgName;
  String merchantName;
  String merchantAddress;
  String orderType;
  List<OrderItem> orderItems;

  Order({required this.orgName, required this.merchantName, required this.merchantAddress, required this.orderType, required this.orderItems});
}