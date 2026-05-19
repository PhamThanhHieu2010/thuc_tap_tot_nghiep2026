import '../models/transaction.dart';
import 'api_service.dart';

class SeedDataService {
  static final ApiService _api = ApiService();

  static Future<void> seed(String userId, String? familyId) async {
    final targetId = (familyId != null && familyId.isNotEmpty) ? familyId : userId;
    final bool isFamily = (familyId != null && familyId.isNotEmpty);

    final List<TransactionModel> sampleData = [
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Lương tháng (Demo)",
        amount: 25000000,
        date: DateTime.now(),
        type: 'income',
        category: 'Lương',
        isDemo: true,
      ),
      TransactionModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: "Mua sắm quần áo",
        amount: 3200000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'expense',
        category: 'Shopping',
        isDemo: true,
      ),
      TransactionModel(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: "Tiệc cuối tuần",
        amount: 1500000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
        category: 'Ăn uống',
        isDemo: true,
      ),
    ];

    for (var tx in sampleData) {
      await _api.addTransactionByMode(targetId, tx, isFamily);
    }
  }
}