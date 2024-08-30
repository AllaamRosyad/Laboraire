import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini
import 'package:shopsmart_users_en/screens/admin/add_product_screen.dart';
import 'package:shopsmart_users_en/screens/admin/admin_screen.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/admin/history_screen.dart';
import 'package:shopsmart_users_en/screens/admin/inspect_product_screen.dart';
import 'package:shopsmart_users_en/screens/admin/loan_screen.dart';
import 'package:shopsmart_users_en/screens/admin/return_management_screent.dart';
import 'package:shopsmart_users_en/screens/all_product_screen.dart';
import 'package:shopsmart_users_en/screens/auth/login.dart';
import 'package:shopsmart_users_en/screens/auth/register.dart';
import 'package:shopsmart_users_en/screens/auth/forgot_password.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_details.dart';
import 'package:shopsmart_users_en/screens/inner_screen/viewed_recently.dart';
import 'package:shopsmart_users_en/screens/loan_management.dart';
import 'package:shopsmart_users_en/screens/return_items.dart';
import 'package:shopsmart_users_en/screens/search_screen.dart';
import 'package:shopsmart_users_en/screens/profile_screen.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/providers/theme_provider.dart';
import 'package:shopsmart_users_en/providers/cart_provider.dart';
import 'package:shopsmart_users_en/providers/user_provider.dart';
import 'package:shopsmart_users_en/providers/viewed_recently_provider.dart';
import 'consts/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> getInitialScreen() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // Jika pengguna sudah login
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('userRole');
      if (role == 'admin') {
        return AdminScreen.routeName;
      } else {
        return RootScreen.routeName;
      }
    } else {
      // Jika pengguna belum login
      return LoginScreen.routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ProductsProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()..fetchCart()),
            ChangeNotifierProvider(create: (_) => ViewedProdProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => LoanProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Laboraire',
                theme: Styles.themeData(
                  isDarkTheme: themeProvider.getIsDarkTheme,
                  context: context,
                ),
                initialRoute: snapshot.data ?? LoginScreen.routeName,
                routes: {
                  RootScreen.routeName: (context) => const RootScreen(),
                  AdminScreen.routeName: (context) => AdminScreen(),
                  ProductDetailsScreen.routName: (context) =>
                      const ProductDetailsScreen(),
                  ViewedRecentlyScreen.routName: (context) =>
                      const ViewedRecentlyScreen(),
                  RegisterScreen.routName: (context) => const RegisterScreen(),
                  LoginScreen.routeName: (context) => const LoginScreen(),
                  ForgotPasswordScreen.routeName: (context) =>
                      const ForgotPasswordScreen(),
                  SearchScreen.routeName: (context) => const SearchScreen(),
                  LoanManagementScreen.routeName: (context) =>
                      LoanManagementScreen(),
                  LoanScreen.routeName: (context) => LoanScreen(),
                  ReturnItemsScreen.routeName: (context) => ReturnItemsScreen(),
                  AddProductScreen.routeName: (context) => AddProductScreen(),
                  AllProductsScreen.routeName: (context) => AllProductsScreen(),
                  InspectProductScreen.routeName: (context) =>
                      InspectProductScreen(),
                  ReturnManagementScreen.routeName: (context) =>
                      ReturnManagementScreen(),
                  HistoryScreen.routeName: (context) => HistoryScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
