class BillModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;
  final bool isDemo;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isPaid,
    this.isDemo = false, 
  });

  factory BillModel.fromJson(String id, Map<String, dynamic> json) {
    return BillModel(
      id: id,
      title: json['title'] ?? 'Hóa đơn',
      amount: double.parse((json['amount'] ?? 0).toString()),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isPaid: json['isPaid'] ?? false,
      isDemo: json['isDemo'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
      'isDemo': isDemo,
    };
  }
}