import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_details.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/viewed_recently_provider.dart';
import '../../services/my_app_functions.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productsProvider.findByProdId(productId);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);
    Size size = MediaQuery.of(context).size;

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
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: FancyShimmerImage(
                imageUrl: getCurrProduct.productImage,
                height: size.height * 0.22,
                width: double.infinity,
                boxFit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitlesTextWidget(
                    label: getCurrProduct.productName,
                    fontSize: 16,
                    maxLines: 1, // Batasi hanya 1 baris
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SubtitleTextWidget(
                          label: "Stock: ${getCurrProduct.productStock}",
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.lightBlue,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () async {
                            if (!cartProvider.isProdinCart(
                                productId: getCurrProduct.productId)) {
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
