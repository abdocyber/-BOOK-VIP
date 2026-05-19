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

  factory BankAccount.fromMap(Map<String, dynamic> m) => BankAccount(
    accountNo: '${m['accountNo'] ?? m['identifier'] ?? ''}',
    referenceNo: '${m['referenceNo'] ?? ''}',
    iban: '${m['iban'] ?? ''}',
    fullName: '${m['fullName'] ?? m['accountName'] ?? ''}',
    password: '${m['password'] ?? ''}',
    accountType: '${m['accountType'] ?? 'حساب توفير'}',
    balance: (m['balance'] is num) ? (m['balance'] as num).toDouble() : double.tryParse('${m['balance'] ?? 0}') ?? 0,
    status: '${m['status'] ?? 'active'}',
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
