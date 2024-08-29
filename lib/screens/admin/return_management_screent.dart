import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/borrowing_model.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart';

class ReturnManagementScreen extends StatefulWidget {
  static const routeName = '/returnItemsScreen';

  @override
  _ReturnManagementScreenState createState() => _ReturnManagementScreenState();
}

class _ReturnManagementScreenState extends State<ReturnManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pengembalian'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dataPengembalian')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items to return.'));
          }

          List<BorrowingModel> returns = snapshot.data!.docs.map((doc) {
            return BorrowingModel.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: returns.length,
            itemBuilder: (ctx, i) {
              final loan = returns[i];
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name: ${loan.productName}'),
                      Text('Jumlah Barang: ${loan.quantity}'),
                      Text('Status Pengembalian: ${loan.statusPengembalian}'),
                      Text(
                          'Tanggal Peminjaman: ${formatTimestamp(loan.tanggalPeminjaman)}'),
                      Text(
                          'Tanggal Pengembalian: ${formatTimestamp(loan.tanggalPengembalian)}'),
                    ],
                  ),
                  trailing: loan.statusPengembalian == 'Belum Disetujui'
                      ? ElevatedButton(
                          onPressed: () {
                            _approveReturn(loanProvider, loan, context);
                          },
                          child: const Text('Approve'),
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to format Firestore Timestamp
  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _approveReturn(LoanProvider loanProvider, BorrowingModel loan,
      BuildContext context) async {
    try {
      // Update the status in Firestore to 'Disetujui'
      await FirebaseFirestore.instance
          .collection('dataPengembalian')
          .doc(loan.peminjamanId)
          .update({'status_pengembalian': 'Disetujui'});

      // Optionally, move the approved document to another collection (e.g., 'history')
      await loanProvider.moveToHistory(loan, context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengembalian berhasil disetujui!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving return: $error')),
      );
    }
  }
}
