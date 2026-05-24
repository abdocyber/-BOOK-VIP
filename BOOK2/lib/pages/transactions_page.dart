import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _dateText(dynamic value) {
    if (value == null) return '';

    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    if (value is DateTime) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }

    final text = '$value'.trim();

    if (text.contains('T')) {
      return text.split('T').first;
    }

    if (text.contains(' ')) {
      return text.split(' ').first;
    }

    return text;
  }

  String _monthTitle(dynamic value) {
    DateTime date = DateTime.now();

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value != null) {
      final parsed = DateTime.tryParse('$value');
      if (parsed != null) date = parsed;
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> _normalizeDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return {
      ...data,
      'id': data['id'] ?? data['operationNumber'] ?? data['transactionId'] ?? doc.id,
      'operationNumber': data['operationNumber'] ?? data['id'] ?? data['transactionId'] ?? doc.id,
      'date': data['date'] ?? data['createdAt'] ?? data['createdAtServer'],
      'createdAt': data['createdAt'] ?? data['date'] ?? data['createdAtServer'],
      'receiverName': data['receiverName'] ??
          data['accountName'] ??
          data['title'] ??
          'تحويل لحسابات أخرى',
      'toAccount': data['toAccount'] ??
          data['accountTo'] ??
          data['to'] ??
          data['id'] ??
          '',
      'accountTo': data['accountTo'] ??
          data['toAccount'] ??
          data['to'] ??
          '',
      'fromAccount': data['fromAccount'] ??
          data['accountFrom'] ??
          data['from'] ??
          '',
      'amount': data['amount'] ?? 0,
    };
  }

  bool _matchesSearch(Map<String, dynamic> d) {
    final q = searchText.trim();

    if (q.isEmpty) return true;

    final cleanQuery = q.replaceAll(' ', '');

    final values = [
      d['toAccount'],
      d['accountTo'],
      d['to'],
      d['id'],
      d['operationNumber'],
      d['transactionId'],
      d['fromAccount'],
      d['accountFrom'],
      d['from'],
    ].map((e) => '$e'.replaceAll(' ', '')).join(' ');

    return values.contains(cleanQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffeaeaea),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            color: const Color(0xfff5f5f5),
            child: Column(
              children: [
                Container(
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffff0000),
                        Color(0xffca1e24),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/img/white_logo_n.png',
                          width: 120,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 16,
                        child: Image.asset(
                          'assets/img/dehaze_24.png',
                          width: 28,
                          color: Colors.white,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 58,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          'المعاملات السابقة',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 11,
                        child: InkWell(
                          onTap: () => safeBack(context, '/home'),
                          child: Image.asset(
                            'assets/img/back.png',
                            width: 80,
                            height: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 54,
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 6),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffdddddd)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'بحث برقم الحساب',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Color(0xff555555),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          onChanged: (v) {
                            setState(() {
                              searchText = v;
                            });
                          },
                        ),
                      ),
                      if (searchText.isNotEmpty)
                        InkWell(
                          onTap: () {
                            searchController.clear();
                            setState(() {
                              searchText = '';
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xff777777),
                          ),
                        )
                      else
                        const Text(
                          '▼',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff555555),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('transfericon')
                        .orderBy('createdAtServer', descending: true)
                        .snapshots(),
                    builder: (context, s) {
                      if (s.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffe60000),
                          ),
                        );
                      }

                      final docs = s.data?.docs ?? [];

                      final allTransactions = docs
                          .map((doc) => _normalizeDoc(doc))
                          .where(_matchesSearch)
                          .toList();

                      final monthTitle = allTransactions.isNotEmpty
                          ? _monthTitle(
                              allTransactions.first['date'] ??
                                  allTransactions.first['createdAt'] ??
                                  allTransactions.first['createdAtServer'],
                            )
                          : 'April 2026';

                      if (docs.isEmpty) {
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    monthTitle,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      color: Color(0xff777777),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: [
                                  tx(context, {
                                    'id': '20018909627',
                                    'amount': 9900,
                                    'date': '2026-04-23',
                                    'receiverName': 'تحويل لحسابات أخرى',
                                    'toAccount': '0123025229390001',
                                  }),
                                  tx(context, {
                                    'id': '20018901780',
                                    'amount': 2500,
                                    'date': '2026-04-23',
                                    'receiverName': 'Sudani TopUp',
                                    'toAccount': '20018901780',
                                  }),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      if (allTransactions.isEmpty) {
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    monthTitle,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      color: Color(0xff777777),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'لا توجد معاملات مطابقة',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xff777777),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  monthTitle,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: Color(0xff777777),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: allTransactions
                                  .map((d) => tx(context, d))
                                  .toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tx(BuildContext context, Map<String, dynamic> d) {
    final amount = (d['amount'] is num)
        ? (d['amount'] as num).toDouble()
        : double.tryParse('${d['amount'] ?? 0}'.replaceAll(',', '')) ?? 0.0;

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/white',
        arguments: d,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(16),
        minHeight: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SizedBox(
                width: 98,
                child: Text(
                  '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} SDG',
                  style: const TextStyle(
                    color: Color(0xffe60000),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/img/trxhisothft.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.swap_horiz,
                          size: 50,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _dateText(
                                d['date'] ??
                                    d['createdAt'] ??
                                    d['createdAtServer'],
                              ),
                              style: const TextStyle(
                                color: Color(0xff666666),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${d['receiverName'] ?? d['accountName'] ?? d['title'] ?? 'تحويل لحسابات أخرى'}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff333333),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '#${d['toAccount'] ?? d['accountTo'] ?? d['to'] ?? d['id'] ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff888888),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
