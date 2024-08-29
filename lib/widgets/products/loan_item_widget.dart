// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shopsmart_users_en/models/borrowing_model.dart';

// class LoanItemWidget extends StatelessWidget {
//   final BorrowingModel loan;
//   final Future<void> Function() onReturn;

//   const LoanItemWidget({
//     Key? key,
//     required this.loan,
//     required this.onReturn,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(10),
//       child: ListTile(
//         leading: Image.network(
//           loan.productImage, // Display product image
//           fit: BoxFit.cover,
//           width: 50,
//           height: 50,
//         ),
//         title: Text(loan.productName), // Display product name
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Status: ${loan.statusPengembalian}'),
//             Text('Jumlah Barang Dipinjam: ${loan.quantity}'),
//             Text(
//                 'Tanggal Peminjaman: ${formatTimestamp(loan.tanggalPeminjaman)}'), // Display loan date
//             Text(
//                 'Tanggal Pengembalian: ${formatTimestamp(loan.tanggalPengembalian)}'), // Display return date
//             // Display quantity
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to format Firestore Timestamp
//   String formatTimestamp(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/models/borrowing_model.dart';

class LoanItemWidget extends StatelessWidget {
  final BorrowingModel loan;
  final Future<void> Function() onReturn;

  const LoanItemWidget({
    Key? key,
    required this.loan,
    required this.onReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Image.network(
          loan.productImage, // Display product image
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        ),
        title: Text(loan.productName), // Display product name
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Status Peminjaman: ${loan.statusPeminjaman}'), // Display statusPeminjaman
            Text(
                'Jumlah Barang Dipinjam: ${loan.quantity}'), // Display quantity
            Text(
                'Tanggal Peminjaman: ${formatTimestamp(loan.tanggalPeminjaman)}'), // Display loan date
            Text(
                'Tanggal Pengembalian: ${formatTimestamp(loan.tanggalPengembalian)}'), // Display return date
          ],
        ),
        // trailing: IconButton(
        //   icon: Icon(Icons.arrow, color: Colors.green),
        //   onPressed: () async {
        //     await onReturn(); // Trigger the onReturn callback when pressed
        //   },
        // ),
      ),
    );
  }

  // Helper method to format Firestore Timestamp
  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
