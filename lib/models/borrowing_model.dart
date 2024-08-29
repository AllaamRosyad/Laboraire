// import 'package:cloud_firestore/cloud_firestore.dart';

// class BorrowingModel {
//   final String peminjamanId;
//   final String userId;
//   final String productId;
//   final String productImage;
//   final String productName;
//   final String statusPeminjaman;
//   String statusPengembalian; // Make this non-final to update later
//   final int quantity;
//   final Timestamp tanggalPeminjaman;
//   final Timestamp tanggalPengembalian;
//   final String userName; // New field added for storing user name

//   BorrowingModel({
//     required this.peminjamanId,
//     required this.userId,
//     required this.productId,
//     required this.productImage,
//     required this.productName,
//     required this.statusPeminjaman,
//     required this.statusPengembalian,
//     required this.quantity,
//     required this.tanggalPeminjaman,
//     required this.tanggalPengembalian,
//     required this.userName, // Initialize the new user name field
//   });

//   factory BorrowingModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return BorrowingModel(
//       peminjamanId: data['peminjamanId'] ?? '',
//       userId: data['userId'] ?? '',
//       productId: data['productId'] ?? '',
//       productImage: data['productImage'] ?? '',
//       productName: data['productName'] ?? '',
//       statusPeminjaman: data['status_peminjaman'] ?? '',
//       statusPengembalian: data['status_pengembalian'] ?? '',
//       quantity: data['quantity'] ?? 1,
//       tanggalPeminjaman: data['tanggal_peminjaman'] ?? Timestamp.now(),
//       tanggalPengembalian: data['tanggal_pengembalian'] ?? Timestamp.now(),
//       userName:
//           data['user_name'] ?? 'Unknown User', // Get userName from Firestore
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'peminjamanId': peminjamanId,
//       'userId': userId,
//       'productId': productId,
//       'productImage': productImage,
//       'productName': productName,
//       'status_peminjaman': statusPeminjaman,
//       'status_pengembalian': statusPengembalian,
//       'quantity': quantity,
//       'tanggal_peminjaman': tanggalPeminjaman,
//       'tanggal_pengembalian': tanggalPengembalian,
//       'user_name': userName, // Include userName in map
//     };
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingModel {
  final String peminjamanId;
  final String userId;
  final String productId;
  final String productImage;
  final String productName;
  final String statusPeminjaman;
  String statusPengembalian; // Allow modification later
  final int quantity;
  final Timestamp tanggalPeminjaman;
  final Timestamp tanggalPengembalian;
  final String userName;
  final String type; // Tambahkan properti baru 'type'

  BorrowingModel({
    required this.peminjamanId,
    required this.userId,
    required this.productId,
    required this.productImage,
    required this.productName,
    required this.statusPeminjaman,
    required this.statusPengembalian,
    required this.quantity,
    required this.tanggalPeminjaman,
    required this.tanggalPengembalian,
    required this.userName,
    required this.type, // Tambahkan 'type' sebagai parameter wajib
  });

  factory BorrowingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BorrowingModel(
      peminjamanId: data['peminjamanId'] ?? '',
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productImage: data['productImage'] ?? '',
      productName: data['productName'] ?? '',
      statusPeminjaman: data['status_peminjaman'] ?? '',
      statusPengembalian: data['status_pengembalian'] ?? '',
      quantity: data['quantity'] ?? 1,
      tanggalPeminjaman: data['tanggal_peminjaman'] ?? Timestamp.now(),
      tanggalPengembalian: data['tanggal_pengembalian'] ?? Timestamp.now(),
      userName: data['user_name'] ?? 'Unknown User',
      type: data['type'] ??
          'peminjaman', // Default to 'peminjaman' if not present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peminjamanId': peminjamanId,
      'userId': userId,
      'productId': productId,
      'productImage': productImage,
      'productName': productName,
      'status_peminjaman': statusPeminjaman,
      'status_pengembalian': statusPengembalian,
      'quantity': quantity,
      'tanggal_peminjaman': tanggalPeminjaman,
      'tanggal_pengembalian': tanggalPengembalian,
      'user_name': userName,
      'type': type, // Tambahkan 'type' ke map
    };
  }
}
