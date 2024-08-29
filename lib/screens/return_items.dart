// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shopsmart_users_en/providers/loan_provider.dart';
// import '../models/borrowing_model.dart';

// class ReturnItemsScreen extends StatelessWidget {
//   static const routeName = '/returnItems';

//   @override
//   Widget build(BuildContext context) {
//     final loanProvider = Provider.of<LoanProvider>(context);

//     // Fetch the returns data
//     loanProvider.fetchReturns();

//     final returnedItems = loanProvider.getReturns;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Return Borrowed Items'),
//       ),
//       body: returnedItems.isEmpty
//           ? const Center(child: Text('No items to return.'))
//           : ListView.builder(
//               itemCount: returnedItems.length,
//               itemBuilder: (ctx, index) {
//                 final loan = returnedItems[index];
//                 return Card(
//                   margin: const EdgeInsets.all(10),
//                   child: ListTile(
//                     leading: loan.productImage.isNotEmpty
//                         ? Image.network(
//                             loan.productImage,
//                             fit: BoxFit.cover,
//                             width: 50,
//                             height: 50,
//                           )
//                         : null, // Show the image only if it's not empty
//                     title: Text(loan.productName ?? loan.productId),
//                     subtitle: Text('Status: ${loan.statusPengembalian}'),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart';
import '../models/borrowing_model.dart';

class ReturnItemsScreen extends StatelessWidget {
  static const routeName = '/returnItems';

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    // Fetch the returns data
    loanProvider.fetchReturns();

    final returnedItems = loanProvider.getReturns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Borrowed Items'),
      ),
      body: returnedItems.isEmpty
          ? const Center(child: Text('No items to return.'))
          : ListView.builder(
              itemCount: returnedItems.length,
              itemBuilder: (ctx, index) {
                final loan = returnedItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: loan.productImage.isNotEmpty
                        ? Image.network(
                            loan.productImage,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          )
                        : null, // Show the image only if it's not empty
                    title: Text(loan.productName ?? loan.productId),
                    subtitle: Text('Status: ${loan.statusPengembalian}'),
                    trailing: loan.statusPengembalian == 'Disetujui'
                        ? IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              // Move to history when status is approved
                              loanProvider.moveToHistory(loan, context);
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
