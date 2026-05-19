class ReceiptData {
  final String operationNumber;
  final String date;
  final String fromAccount;
  final String toAccount;
  final String receiverName;
  final String phone;
  final String note;
  final double amount;

  const ReceiptData({
    required this.operationNumber,
    required this.date,
    required this.fromAccount,
    required this.toAccount,
    required this.receiverName,
    this.phone = 'N/A',
    this.note = 'N/A',
    required this.amount,
  });
}
