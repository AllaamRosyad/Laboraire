import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/services/my_app_functions.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/viewed_recently_provider.dart';
import '../../screens/inner_screen/product_details.dart';

class ProductCard extends StatelessWidget {
  final String productId;

  const ProductCard({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productsProvider.findByProdId(productId);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    if (getCurrProduct == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        viewedProdProvider.addViewedProd(productId: getCurrProduct.productId);
        await Navigator.pushNamed(
          context,
          ProductDetailsScreen.routName,
          arguments: getCurrProduct.productId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar produk dengan tinggi tetap
            SizedBox(
              height: 120, // Tetapkan tinggi tetap untuk gambar
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: FancyShimmerImage(
                  imageUrl: getCurrProduct.productImage,
                  width: double.infinity,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
            // Kolom dengan teks dan tombol
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getCurrProduct.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Stock: ${getCurrProduct.productStock}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.lightBlue,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () async {
                            if (cartProvider.isProdinCart(
                                productId: getCurrProduct.productId)) {
                              return;
                            }
                            try {
                              cartProvider.addToCartFirebase(
                                  productId: getCurrProduct.productId,
                                  qty: 1,
                                  context: context);
                            } catch (e) {
                              await MyAppFunctions.showErrorOrWarningDialog(
                                context: context,
                                subtitle: e.toString(),
                                fct: () {},
                              );
                            }
                          },
                          splashColor: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              cartProvider.isProdinCart(
                                      productId: getCurrProduct.productId)
                                  ? Icons.check
                                  : Icons.add_shopping_cart_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
