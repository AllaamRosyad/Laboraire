import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/screens/product_card.dart';
import '../providers/products_provider.dart';

class AllProductsScreen extends StatelessWidget {
  static const routeName = '/all-products';

  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final products = productsProvider.getProducts;

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Products'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const Center(
          child: Text('No products available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: products.length,
          itemBuilder: (ctx, i) => ProductCard(
            productId: products[i].productId,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            childAspectRatio: 2 / 3, // Adjust as needed
            crossAxisSpacing: 10, // Horizontal spacing
            mainAxisSpacing: 10, // Vertical spacing
          ),
        ),
      ),
    );
  }
}
