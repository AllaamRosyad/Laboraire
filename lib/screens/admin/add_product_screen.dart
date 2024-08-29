import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/addProductScreen';

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _selectedImage;
  final _picker = ImagePicker();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(
                  context,
                  await _picker.pickImage(source: ImageSource.camera),
                );
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(
                  context,
                  await _picker.pickImage(source: ImageSource.gallery),
                );
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _productNameController.clear();
      _stockController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> _uploadProduct() async {
    if (_selectedImage == null ||
        _productNameController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Menghasilkan UUID unik
      String productId = Uuid().v4();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child(fileName);
      await storageRef.putFile(_selectedImage!);

      String imageUrl = await storageRef.getDownloadURL();

      // Menyimpan produk dengan product_id yang unik
      await FirebaseFirestore.instance.collection('dataBarang').add({
        'createdAt': Timestamp.now(),
        'product_deskripsi': _descriptionController.text,
        'product_id': productId, // Gunakan UUID sebagai product_id
        'product_image': imageUrl,
        'product_name': _productNameController.text,
        'product_stok': int.parse(_stockController.text),
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product uploaded successfully')));
      _clearImage();
    } catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading product: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // This helps prevent overflow
      appBar: AppBar(
        title: Text('Upload a new product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    shape: BoxShape.rectangle,
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          key: ValueKey(_selectedImage?.path),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.purple, size: 50),
                            Text('Pick Product Image',
                                style: TextStyle(color: Colors.purple)),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 10),
              if (_selectedImage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Pick another image',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearImage,
                      child: Text(
                        'Remove image',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Product description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _clearImage,
                    child: Row(
                      children: [Icon(Icons.clear), Text('Clear')],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _uploadProduct,
                    child: Row(
                      children: [Icon(Icons.upload), Text('Upload Product')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
