import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopsmart_users_en/models/borrowing_model.dart';

class LoanScreen extends StatelessWidget {
  static const routeName = '/loanScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('dataPeminjaman').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading loans'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No loans available.'));
          }

          List<BorrowingModel> loans = snapshot.data!.docs.map((doc) {
            return BorrowingModel.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return ListTile(
                leading: Image.network(
                  loan.productImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(loan.productName ?? 'Unknown Product'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Status: ${loan.statusPeminjaman ?? 'Pending Approval'}'),
                    Text('Quantity: ${loan.quantity}'),
                  ],
                ),
                trailing: loan.statusPeminjaman == 'Belum Disetujui'
                    ? ElevatedButton(
                        onPressed: () => _approveLoan(context, loan),
                        child: const Text('Approve'),
                      )
                    : const Icon(Icons.check_circle, color: Colors.green),
                onTap: () {
                  // Handle tap event if needed
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveLoan(BuildContext context, BorrowingModel loan) async {
    try {
      // Update the loan status to 'Disetujui' in Firestore
      await FirebaseFirestore.instance
          .collection('dataPeminjaman')
          .doc(loan.peminjamanId)
          .update({'status_peminjaman': 'Disetujui'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan status updated to Approved')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving loan: $error')),
      );
    }
  }
}
