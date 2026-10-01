import 'address_model.dart';

class OrderItemSnapshot {
  const OrderItemSnapshot({
    required this.productId,
    required this.vendorId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.imageUrl,
  });

  final String productId;
  final String vendorId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'productId': productId,
      'vendorId': vendorId,
      'productName': productName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }
}

class PlaceOrderResult {
  const PlaceOrderResult({required this.orderId});

  final String orderId;
}

class PlaceOrderDraft {
  const PlaceOrderDraft({
    required this.customerId,
    required this.customerEmail,
    required this.customerName,
    required this.address,
    required this.shipping,
  });

  final String customerId;
  final String customerEmail;
  final String customerName;
  final AddressModel address;
  final double shipping;
}
