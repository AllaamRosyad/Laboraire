import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String productName; // Updated from productTitle to productName
  final String productDescription;
  final String productImage; // Ensure this is correctly mapped
  final int productStock; // Updated from productQuantity to productStock
  final Timestamp createdAt;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productStock,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      productId:
          data['product_id']?.toString() ?? 'Unknown', // Field name change
      productName:
          data['product_name']?.toString() ?? 'No Name', // Field name change
      productDescription: data['product_deskripsi']?.toString() ??
          'No Description', // Field name change
      productImage: data['product_image']?.toString() ?? '',
      productStock: data['product_stok'] is int
          ? data['product_stok']
          : int.tryParse(data['product_stok'].toString()) ?? 0,
      createdAt: data['createdAt'] ??
          Timestamp.now(), // Ensure this field exists in Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_deskripsi': productDescription,
      'product_image': productImage,
      'product_stok': productStock,
      'createdAt': createdAt,
    };
  }
}
