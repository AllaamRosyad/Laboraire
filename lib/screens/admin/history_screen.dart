import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopsmart_users_en/models/borrowing_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/historyScreen';

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generatePdfAndDownload(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('history').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No history available.'));
          }

          List<BorrowingModel> items = snapshot.data!.docs.map((doc) {
            return BorrowingModel.fromFirestore(doc);
          }).toList();

          // Pisahkan data berdasarkan tipe
          List<BorrowingModel> peminjamanItems =
              items.where((item) => item.type == 'peminjaman').toList();
          List<BorrowingModel> pengembalianItems =
              items.where((item) => item.type == 'pengembalian').toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: Text(
                //     'Data Peminjaman',
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //   ),
                // ),
                // _buildSection(peminjamanItems, 'peminjaman'),
                // const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSection(pengembalianItems, 'pengembalian'),
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to build sections for loans and returns
  Widget _buildSection(List<BorrowingModel> items, String type) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: item.productImage.isNotEmpty
                ? Image.network(
                    item.productImage,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  )
                : null, // Show the image only if it's not empty
            title: Text(item.productName ?? item.productId),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Name: ${item.userName}'),
                Text('Product Name: ${item.productName}'),
                Text('Quantity: ${item.quantity}'),
                if (type == 'peminjaman')
                  Text('Status Peminjaman: ${item.statusPeminjaman}'),
                Text('Status Pengembalian: ${item.statusPengembalian}'),
                Text(
                    'Tanggal Peminjaman: ${formatTimestamp(item.tanggalPeminjaman)}'),
                Text(
                    'Tanggal Pengembalian: ${formatTimestamp(item.tanggalPengembalian)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to format Firestore Timestamp
  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Generate and Download PDF
  Future<void> _generatePdfAndDownload(BuildContext context) async {
    final pdf = pw.Document();
    final dataHistory =
        await FirebaseFirestore.instance.collection('history').get();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text('History Report'),
          ),
          pw.Paragraph(text: 'Data Peminjaman dan Pengembalian'),
          _buildPdfTable(context, dataHistory),
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Helper to create table for PDF
  pw.Widget _buildPdfTable(pw.Context context, QuerySnapshot snapshot) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: [
        'User Name',
        'Product Name',
        'Quantity',
        'Status Peminjaman',
        'Status Pengembalian',
        'Tanggal Peminjaman',
        'Tanggal Pengembalian'
      ],
      data: snapshot.docs.map((doc) {
        final item = BorrowingModel.fromFirestore(doc);
        return [
          item.userName ?? 'N/A',
          item.productName ?? 'N/A',
          item.quantity.toString(),
          item.statusPeminjaman,
          item.statusPengembalian,
          formatTimestamp(item.tanggalPeminjaman),
          formatTimestamp(item.tanggalPengembalian),
        ];
      }).toList(),
    );
  }
}
