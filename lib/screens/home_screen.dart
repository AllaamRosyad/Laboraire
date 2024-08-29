// import 'package:card_swiper/card_swiper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shopsmart_users_en/consts/app_constants.dart';
// import 'package:shopsmart_users_en/widgets/products/ctg_rounded_widget.dart';
// import 'package:shopsmart_users_en/widgets/products/latest_arrival.dart';

// import '../providers/products_provider.dart';
// import '../services/assets_manager.dart';
// import '../widgets/app_name_text.dart';
// import '../widgets/title_text.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     final productsProvider =
//         Provider.of<ProductsProvider>(context, listen: false);
//     await productsProvider.fetchProducts();
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     final productsProvider = Provider.of<ProductsProvider>(context);

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (productsProvider.getProducts.isEmpty) {
//       return const Center(child: Text('No products available.'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Image.asset(
//             AssetsManager.shoppingCart,
//           ),
//         ),
//         title: const AppNameTextWidget(fontSize: 20),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 height: 15,
//               ),
//               SizedBox(
//                 height: size.height * 0.25,
//                 child: ClipRRect(
//                   child: Swiper(
//                     autoplay: true,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Image.asset(
//                         AppConstants.bannersImages[index],
//                         fit: BoxFit.fill,
//                       );
//                     },
//                     itemCount: AppConstants.bannersImages.length,
//                     pagination: const SwiperPagination(
//                       builder: DotSwiperPaginationBuilder(
//                           activeColor: Colors.red, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 15.0,
//               ),
//               // const TitlesTextWidget(label: "Latest arrival"),
//               // const SizedBox(
//               //   height: 15.0,
//               // ),
//               // SizedBox(
//               //   height: size.height * 0.2,
//               //   child: ListView.builder(
//               //       scrollDirection: Axis.horizontal,
//               //       itemCount: productsProvider.getProducts.length < 10
//               //           ? productsProvider.getProducts.length
//               //           : 10,
//               //       itemBuilder: (context, index) {
//               //         return ChangeNotifierProvider.value(
//               //           value: productsProvider.getProducts[index],
//               //           child: const LatestArrivalProductsWidget(),
//               //         );
//               //       }),
//               // ),
//               const TitlesTextWidget(label: "Categories"),
//               const SizedBox(
//                 height: 15.0,
//               ),
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 4,
//                 children:
//                     List.generate(AppConstants.categoriesList.length, (index) {
//                   return CategoryRoundedWidget(
//                     image: AppConstants.categoriesList[index].image,
//                     name: AppConstants.categoriesList[index].name,
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/consts/app_constants.dart';
import 'package:shopsmart_users_en/screens/all_product_screen.dart';
import 'package:shopsmart_users_en/widgets/products/product_widget.dart';
import '../providers/products_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/app_name_text.dart';
import '../widgets/title_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.fetchProducts();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productsProvider = Provider.of<ProductsProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productsProvider.getProducts.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    // Determine the number of products to show (max 4)
    int productCount = productsProvider.getProducts.length > 4
        ? 4
        : productsProvider.getProducts.length;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            AssetsManager.laboraire,
          ),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: size.height * 0.25,
                  child: ClipRRect(
                    child: Swiper(
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.asset(
                          AppConstants.bannersImages[index],
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: AppConstants.bannersImages.length,
                      pagination: const SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                            activeColor: Colors.red, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TitlesTextWidget(label: "Barang Di Lemari"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllProductsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: productCount,
                  itemBuilder: (context, index) {
                    return ProductWidget(
                      productId: productsProvider.getProducts[index].productId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
