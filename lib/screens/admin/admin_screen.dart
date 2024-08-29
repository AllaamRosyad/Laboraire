import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsmart_users_en/screens/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/loan_provider.dart'; // Import LoanProvider

class AdminScreen extends StatefulWidget {
  static const routeName = '/adminPanel';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    loanProvider
        .listenToNewLoans(); // Tambahkan listener untuk mendengarkan perubahan di Firebase
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: loanProvider
                .newLoanCountNotifier, // Menggunakan ValueNotifier untuk memantau jumlah peminjaman baru
            builder: (context, newLoanCount, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (newLoanCount > 0)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$newLoanCount',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  loanProvider
                      .clearNewLoanCount(); // Reset jumlah notifikasi setelah ditekan
                  _showNotificationDetails(context);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.2,
          ),
          children: [
            _buildGridItem(
              context,
              icon: Icons.add_box,
              label: 'Tambahkan Barang',
              onTap: () {
                Navigator.pushNamed(context, '/addProductScreen');
              },
            ),
            _buildGridItem(
              context,
              icon: Icons.shopping_cart,
              label: 'Data Barang',
              onTap: () {
                Navigator.pushNamed(context, '/inspectProductsScreen');
              },
            ),
            _buildGridItem(
              context,
              icon: Icons.assignment,
              label: 'Data Peminjaman',
              onTap: () {
                Navigator.pushNamed(context, '/loanScreen');
              },
            ),
            _buildGridItem(
              context,
              icon: Icons.assignment_return,
              label: 'Data Pengembalian',
              onTap: () {
                Navigator.pushNamed(context, '/returnItemsScreen');
              },
            ),
            _buildGridItem(
              context,
              icon: Icons.history,
              label: 'History',
              onTap: () {
                Navigator.pushNamed(context, '/historyScreen');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void _showNotificationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifikasi Peminjaman Baru'),
          content:
              const Text('Ada peminjaman barang baru yang belum diproses.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
