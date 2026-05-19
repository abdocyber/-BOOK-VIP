class BankAccount {
  final String accountNo;
  final String referenceNo;
  final String iban;
  final String fullName;
  final String password;
  final String accountType;
  final double balance;
  final String status;

  const BankAccount({
    required this.accountNo,
    required this.referenceNo,
    required this.iban,
    required this.fullName,
    required this.password,
    this.accountType = 'حساب توفير',
    this.balance = 0,
    this.status = 'active',
  });

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final cleaned = '$value'
        .replaceAll(',', '')
        .replaceAll('SDG', '')
        .replaceAll('جنيه', '')
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  factory BankAccount.fromMap(Map<String, dynamic> m) => BankAccount(
    accountNo: '${m['accountNo'] ?? m['identifier'] ?? m['رقم الحساب'] ?? m['docId'] ?? ''}',
    referenceNo: '${m['referenceNo'] ?? m['الرقم المرجعي'] ?? m['accountNo'] ?? m['رقم الحساب'] ?? m['docId'] ?? ''}',
    iban: '${m['iban'] ?? m['IBAN'] ?? ''}',
    fullName: '${m['fullName'] ?? m['accountName'] ?? m['name'] ?? m['الاسم'] ?? ''}',
    password: '${m['password'] ?? m['كلمة المرور'] ?? ''}',
    accountType: '${m['accountType'] ?? m['نوع الحساب'] ?? 'حساب توفير'}',
    balance: _toDouble(m['balance'] ?? m['الرصيد'] ?? 0),
    status: '${m['status'] ?? m['الحالة'] ?? 'active'}',
  );

  Map<String, dynamic> toMap() => {
    'accountNo': accountNo,
    'identifier': accountNo,
    'referenceNo': referenceNo,
    'iban': iban,
    'fullName': fullName,
    'password': password,
    'accountType': accountType,
    'balance': balance,
    'status': status,
  };
}
