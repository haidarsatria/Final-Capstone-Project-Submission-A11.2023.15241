class TransactionModel {
  final int? id;
  final String date;
  final int totalAmount;
  final String paymentMethod;
  final String customerName;
  final String? receiptPhoto;

  TransactionModel({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
    required this.customerName,
    this.receiptPhoto,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: map['date'],
      totalAmount: map['total_amount'],
      paymentMethod: map['payment_method'],
      customerName: map['customer_name'],
      receiptPhoto: map['receipt_photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'receipt_photo': receiptPhoto,
    };
  }
}
