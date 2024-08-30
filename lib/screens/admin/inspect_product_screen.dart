import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class InspectProductScreen extends StatefulWidget {
  static const routeName = '/inspectProductsScreen';

  @override
  _InspectProductScreenState createState() => _InspectProductScreenState();
}

class _InspectProductScreenState extends State<InspectProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspect Products'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('dataBarang').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['product_name']),
                subtitle: Text('Stock: ${product['product_stok']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditProductDialog(context, product);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('dataBarang').doc(productId).delete();
      Fluttertoast.showToast(msg: 'Product deleted successfully');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to delete product: $error');
    }
  }

  void _showEditProductDialog(BuildContext context, DocumentSnapshot product) {
    final TextEditingController _nameController =
        TextEditingController(text: product['product_name']);
    final TextEditingController _stockController =
        TextEditingController(text: product['product_stok'].toString());
    final TextEditingController _descriptionController =
        TextEditingController(text: product['product_deskripsi']);
    String? _currentImage = product['product_image'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, height: 150, width: 150)
                      : _currentImage != null
                          ? Image.network(_currentImage,
                              height: 150, width: 150)
                          : Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            ),
                ),
                const SizedBox(
                    height: 20), // Add space between image and fields
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await _updateProduct(
                  product.id,
                  _nameController.text,
                  int.parse(_stockController.text),
                  _descriptionController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct(String productId, String newName, int newStock,
      String newDescription) async {
    try {
      String? imageUrl;

      if (_selectedImage != null) {
        // Upload new image if selected
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child(fileName);
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Update Firestore document
      await _firestore.collection('dataBarang').doc(productId).update({
        'product_name': newName,
        'product_stok': newStock,
        'product_deskripsi': newDescription,
        if (imageUrl != null) 'product_image': imageUrl,
      });

      Fluttertoast.showToast(msg: 'Product updated successfully');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to update product: $error');
    }
  }
}
