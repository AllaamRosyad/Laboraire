import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String loanId;
  final String userId;
  final String productId;
  final String productTitle;
  final String userName;
  final DateTime loanStartDate;
  final DateTime loanEndDate;
  final String imageUrl;
  final String productCondition;
  final Timestamp createdAt;

  LoanModel({
    required this.loanId,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.userName,
    required this.loanStartDate,
    required this.loanEndDate,
    required this.imageUrl,
    required this.productCondition,
    required this.createdAt,
  });

  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return LoanModel(
      loanId: data['loanId'] ?? '',
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      userName: data['userName'] ?? '',
      loanStartDate: (data['loanStartDate'] as Timestamp).toDate(),
      loanEndDate: (data['loanEndDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      productCondition: data['productCondition'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'userId': userId,
      'productId': productId,
      'productTitle': productTitle,
      'userName': userName,
      'loanStartDate': Timestamp.fromDate(loanStartDate),
      'loanEndDate': Timestamp.fromDate(loanEndDate),
      'imageUrl': imageUrl,
      'productCondition': productCondition,
      'createdAt': createdAt,
    };
  }
}
