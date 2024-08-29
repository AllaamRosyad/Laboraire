import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/product_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/widgets/products/product_widget.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

class InspectProductsScreen extends StatefulWidget {
  static const routeName = '/inspectProductsScreen';

  @override
  _InspectProductsScreenState createState() => _InspectProductsScreenState();
}

class _InspectProductsScreenState extends State<InspectProductsScreen> {
  late TextEditingController searchTextController;
  bool _isLoading = true;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await Provider.of<ProductsProvider>(context, listen: false)
          .fetchProducts();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print("Failed to load products: $error");
      setState(() {
        _isLoading = false;
      });
    }
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
      productListSearch.clear(); // Clear the search results
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    List<ProductModel> productList = productsProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Data Barang"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                      FocusScope.of(context).unfocus(); // Hide keyboard
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: searchTextController.text.isNotEmpty
                          ? productListSearch.length
                          : productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2 / 3,
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
    );
  }
}
