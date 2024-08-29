import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart';
import 'package:shopsmart_users_en/providers/cart_provider.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartBottomSheetWidget extends StatefulWidget {
  const CartBottomSheetWidget({super.key});

  @override
  _CartBottomSheetWidgetState createState() => _CartBottomSheetWidgetState();
}

class _CartBottomSheetWidgetState extends State<CartBottomSheetWidget> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _borrowItems(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to borrow items.')),
      );
      return;
    }

    print(
        "Memulai proses peminjaman..."); // Log untuk memulai proses peminjaman

    final userSnapshot = await FirebaseFirestore.instance
        .collection('dataPengguna')
        .doc(user.uid)
        .get();
    final String userName = userSnapshot.data()?['user_name'] ?? 'Unknown User';

    final cartItems = cartProvider.getCartitems.values.toList();

    DateTime? loanStartDate;
    DateTime? loanEndDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Loan Dates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Loan Start Date',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      loanStartDate = picked;
                      _startDateController.text =
                          '${picked.day}-${picked.month}-${picked.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Loan End Date',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      loanEndDate = picked;
                      _endDateController.text =
                          '${picked.day}-${picked.month}-${picked.year}';
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (loanStartDate != null && loanEndDate != null) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please select both start and end dates.')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (loanStartDate == null || loanEndDate == null) {
      return; // Stop if dates are not selected
    }

    for (var cartItem in cartItems) {
      final product = productsProvider.findByProdId(cartItem.productId);

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${cartItem.productId} not found.')),
        );
        continue;
      }

      final String productName = product.productName;
      final String imageUrl = product.productImage;

      print(
          "Memulai proses peminjaman untuk produk: $productName"); // Log tambahan di sini

      // Check product availability before borrowing
      bool isAvailable = await loanProvider.checkProductAvailability(
        productId: cartItem.productId,
        quantityToBorrow: cartItem.quantity,
        context: context,
      );

      if (!isAvailable) {
        return; // Stop if the product is not available
      }

      // Call borrowProduct method with correct parameters
      await loanProvider.borrowProduct(
        productId: cartItem.productId,
        productTitle: productName,
        userName: userName,
        imageUrl: imageUrl,
        loanStartDate: loanStartDate!,
        loanEndDate: loanEndDate!,
        productCondition: 'Good',
        quantityToBorrow: cartItem.quantity,
        context: context,
      );
    }

    await cartProvider.clearCartFromFirebase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items have been borrowed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                        child: Text(
                            "Total (${cartProvider.getCartitems.length} products/${cartProvider.getQty()} items)")),
                    // Removed total price
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _borrowItems(context);
                },
                child: const Text("Peminjaman Barang"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
