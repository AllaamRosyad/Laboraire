import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsmart_users_en/models/cart_model.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartitems => _cartItems;

  // Update the collection reference to 'dataPengguna'
  final penggunaDb = FirebaseFirestore.instance.collection("dataPengguna");
  final _auth = FirebaseAuth.instance;

  /// Firebase
  Future<void> addToCartFirebase({
    required String productId,
    required int qty,
    required BuildContext context,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: 'Please login first');
      return;
    }
    final uid = user.uid;
    final cartId = Uuid().v4();
    try {
      await penggunaDb.doc(uid).update({
        'userCart': FieldValue.arrayUnion([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      await fetchCart(); // Fetch updated cart data from Firestore
      Fluttertoast.showToast(msg: 'Item has been added');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchCart() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      _cartItems.clear();
      notifyListeners();
      return;
    }
    try {
      final userDoc = await penggunaDb.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey('userCart')) {
        _cartItems.clear();
        notifyListeners();
        return;
      }

      final cartList = List<Map<String, dynamic>>.from(data['userCart']);

      // Clear the cart items before repopulating them
      _cartItems.clear();

      for (var cartItem in cartList) {
        _cartItems.putIfAbsent(
          cartItem['productId'],
          () => CartModel(
            cartId: cartItem['cartId'],
            productId: cartItem['productId'],
            quantity: cartItem['quantity'],
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching cart: $e");
      rethrow;
    }
  }

  Future<void> removeCartItemFirestore({
    required String cartId,
    required String productId,
    required int qty,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await penggunaDb.doc(user.uid).update({
        'userCart': FieldValue.arrayRemove([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      await fetchCart(); // Fetch updated cart data from Firestore
      Fluttertoast.showToast(msg: 'Item has been removed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCartFromFirebase() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await penggunaDb.doc(user.uid).update({'userCart': []});
      await fetchCart(); // Fetch updated cart data from Firestore
      _cartItems.clear();
      Fluttertoast.showToast(msg: 'Cart has been cleared');
    } catch (e) {
      rethrow;
    }
  }

  /// Local Methods
  void addProductToCart({required String productId}) {
    _cartItems.putIfAbsent(
      productId,
      () => CartModel(
        cartId: const Uuid().v4(),
        productId: productId,
        quantity: 1,
      ),
    );
    notifyListeners();
  }

  void updateQty({required String productId, required int qty}) {
    _cartItems.update(
      productId,
      (cartItem) => CartModel(
        cartId: cartItem.cartId,
        productId: productId,
        quantity: qty,
      ),
    );
    notifyListeners();
  }

  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(productId);
  }

  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}
