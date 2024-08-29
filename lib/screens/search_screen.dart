import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/product_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/products/product_widget.dart';
import '../widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  List<ProductModel> productListSearch = [];

  void _onSearchSubmitted() {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    setState(() {
      productListSearch = productsProvider.searchQuery(
        searchText: searchTextController.text,
        passedList: productsProvider.products,
      );
    });
  }

  void _clearSearch() {
    setState(() {
      searchTextController.clear();
      productListSearch.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    List<ProductModel> productList = productsProvider.products;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              AssetsManager.laboraire,
            ),
          ),
          title: const TitlesTextWidget(label: "Search products"),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 15.0),
                TextField(
                  controller: searchTextController,
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: GestureDetector(
                      onTap: _clearSearch,
                      child: const Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    _onSearchSubmitted();
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 15.0),
                if (searchTextController.text.isNotEmpty &&
                    productListSearch.isEmpty)
                  const Center(
                    child: TitlesTextWidget(label: "No products found"),
                  ),
                if (productList.isNotEmpty)
                  Expanded(
                    child: GridView.builder(
                      itemCount: searchTextController.text.isNotEmpty
                          ? productListSearch.length
                          : productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return ProductWidget(
                          productId: searchTextController.text.isNotEmpty
                              ? productListSearch[index].productId
                              : productList[index].productId,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
