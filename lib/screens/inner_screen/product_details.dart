import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/services/my_app_functions.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routName = "/ProductDetailsScreen";
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productsProvider = Provider.of<ProductsProvider>(context);
    String? productId = ModalRoute.of(context)!.settings.arguments as String?;
    final getCurrProduct = productsProvider.findByProdId(productId!);
    final cartProvider = Provider.of<CartProvider>(context);

    if (getCurrProduct == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          title: const AppNameTextWidget(fontSize: 20),
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align content to the left
          children: [
            FancyShimmerImage(
              imageUrl: getCurrProduct.productImage,
              height: size.height * 0.38,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    getCurrProduct.productName,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(height: 20, thickness: 1), // Divider
                  // Product Description
                  SubtitleTextWidget(
                    label: getCurrProduct.productDescription,
                  ),
                  const SizedBox(height: 20),
                  // Stock Information
                  Text(
                    "Stock: ${getCurrProduct.productStock}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add to Cart Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: kBottomNavigationBarHeight - 10,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () async {
                          if (cartProvider.isProdinCart(
                              productId: getCurrProduct.productId)) {
                            return;
                          }
                          try {
                            cartProvider.addToCartFirebase(
                              productId: getCurrProduct.productId,
                              qty: 1,
                              context: context,
                            );
                          } catch (e) {
                            await MyAppFunctions.showErrorOrWarningDialog(
                              context: context,
                              subtitle: e.toString(),
                              fct: () {},
                            );
                          }
                        },
                        icon: Icon(
                          cartProvider.isProdinCart(
                                  productId: getCurrProduct.productId)
                              ? Icons.check
                              : Icons.add_shopping_cart_outlined,
                        ),
                        label: Text(
                          cartProvider.isProdinCart(
                                  productId: getCurrProduct.productId)
                              ? "In cart"
                              : "Add to cart",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
