class PayoutRequestModel {
  final String id;
  final int amountCoins;
  final double amountFiat;
  final double platformFee;
  final double finalAmount;
  final String status;
  final String? adminNote;
  final DateTime createdAt;

  PayoutRequestModel({
    required this.id,
    required this.amountCoins,
    required this.amountFiat,
    required this.platformFee,
    required this.finalAmount,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return PayoutRequestModel(
      id: json['id'] ?? "",
      amountCoins: (json['amount_coins'] ?? 0).toInt(),
      amountFiat: (json['amount_fiat'] ?? 0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0).toDouble(),
      finalAmount: (json['final_amount'] ?? 0).toDouble(),
      status: json['status'] ?? "PENDING",
      adminNote: json['admin_note'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
