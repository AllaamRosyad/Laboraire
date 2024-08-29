// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shopsmart_users_en/providers/loan_provider.dart';
// import 'package:shopsmart_users_en/widgets/products/loan_item_widget.dart';
// import '../models/borrowing_model.dart'; // Import BorrowingModel

// class LoanManagementScreen extends StatefulWidget {
//   static const routeName = '/loanManagement';

//   @override
//   _LoanManagementScreenState createState() => _LoanManagementScreenState();
// }

// class _LoanManagementScreenState extends State<LoanManagementScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch loans when the screen is loaded
//     Future.microtask(() {
//       final loanProvider = Provider.of<LoanProvider>(context, listen: false);
//       loanProvider.fetchLoans();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loanProvider = Provider.of<LoanProvider>(context);
//     final List<BorrowingModel> loans = loanProvider.getLoans;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Peminjaman Barang'),
//       ),
//       body: loans.isEmpty
//           ? Center(child: Text('No active loans.'))
//           : ListView.builder(
//               itemCount: loans.length,
//               itemBuilder: (ctx, i) => LoanItemWidget(
//                 loan: loans[i],
//                 onReturn: () async {
//                   // Provide a callback function, even if it's empty
//                 },
//               ),
//             ),
//       bottomNavigationBar: loans.isNotEmpty
//           ? Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await _handleReturnAllItems(loanProvider, context);
//                 },
//                 child: Text('Kembalikan semua barang'),
//               ),
//             )
//           : null,
//     );
//   }

//   Future<void> _handleReturnAllItems(
//       LoanProvider loanProvider, BuildContext context) async {
//     // Loop through loans and return all items with 'Belum Disetujui' status
//     final loans = loanProvider.getLoans
//         .where((loan) => loan.statusPengembalian == 'Belum Disetujui')
//         .toList();

//     for (var loan in loans) {
//       await loanProvider.returnProduct(loan, context);
//     }

//     // Refresh the list after the operation
//     await loanProvider.fetchLoans();
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart';
import 'package:shopsmart_users_en/widgets/products/loan_item_widget.dart';
import '../models/borrowing_model.dart'; // Import BorrowingModel

class LoanManagementScreen extends StatefulWidget {
  static const routeName = '/loanManagement';

  @override
  _LoanManagementScreenState createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch loans when the screen is loaded
    Future.microtask(() {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      loanProvider.fetchLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);
    final List<BorrowingModel> loans = loanProvider.getLoans;

    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Barang'),
      ),
      body: loans.isEmpty
          ? Center(child: Text('No active loans.'))
          : ListView.builder(
              itemCount: loans.length,
              itemBuilder: (ctx, i) => LoanItemWidget(
                loan: loans[i],
                onReturn: () async {
                  await loanProvider.returnProduct(loans[i], context);
                },
              ),
            ),
      bottomNavigationBar: loans.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _handleReturnAllItems(loanProvider, context);
                },
                child: Text('Kembalikan semua barang'),
              ),
            )
          : null,
    );
  }

  Future<void> _handleReturnAllItems(
      LoanProvider loanProvider, BuildContext context) async {
    // Loop through loans and return all items with 'Belum Disetujui' status
    final loans = loanProvider.getLoans
        .where((loan) => loan.statusPengembalian == 'Belum Disetujui')
        .toList();

    for (var loan in loans) {
      await loanProvider.returnProduct(loan, context);
    }

    // Refresh the list after the operation
    await loanProvider.fetchLoans();
  }
}
