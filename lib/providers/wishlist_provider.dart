// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shopsmart_users_en/models/wishlist_model.dart';
// import 'package:shopsmart_users_en/services/my_app_functions.dart';
// import 'package:uuid/uuid.dart';

// class WishlistProvider with ChangeNotifier {
//   final Map<String, WishlistModel> _wishlistItems = {};
//   Map<String, WishlistModel> get getWishlists {
//     return _wishlistItems;
//   }

//   final usersDb = FirebaseFirestore.instance.collection("users");
//   final _auth = FirebaseAuth.instance;

//   /// Firebase
//   Future<void> addToWishlistFirebase(
//       {required String productId, required BuildContext context}) async {
//     final User? user = _auth.currentUser;
//     if (user == null) {
//       MyAppFunctions.showErrorOrWarningDialog(
//           context: context, subtitle: 'Please login first', fct: () {});
//       return;
//     }
//     final uid = user.uid;
//     final wishlistId = Uuid().v4();
//     try {
//       await usersDb.doc(uid).update({
//         'userWish': FieldValue.arrayUnion([
//           {
//             'wishlistId': wishlistId,
//             'productId': productId,
//           }
//         ])
//       });
//       await fetchCart();
//       Fluttertoast.showToast(msg: 'Item has been added');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> fetchWishlist() async {
//     final User? user = _auth.currentUser;
//     if (user == null) {
//       _wishlistItems.clear();
//       return;
//     }
//     try {
//       final userDoc = await usersDb.doc(user.uid).get();
//       final data = userDoc.data();
//       if (data == null || !data.containsKey('userWish')) {
//         return;
//       }
//       final leng = userDoc.get("userWish").length;
//       for (int index = 0; index < leng; index++) {
//         _wishlistItems.putIfAbsent(
//             userDoc.get("userCart")[index]['productId'],
//             () => CartModel(
//                 cartId: userDoc.get("userCart")[index]['cartId'],
//                 productId: userDoc.get("userCart")[index]['productId'],
//                 quantity: userDoc.get("userCart")[index]['quantity']));
//       }
//     } catch (e) {
//       rethrow;
//     }
//     notifyListeners();
//   }

//   Future<void> removeCartItemFirestore(
//       {required String cartId,
//       required String productId,
//       required int qty}) async {
//     final User? user = _auth.currentUser;
//     try {
//       await usersDb.doc(user!.uid).update({
//         'userCart': FieldValue.arrayRemove([
//           {
//             'cartId': cartId,
//             'productId': productId,
//             'quantity': qty,
//           }
//         ])
//       });
//       await fetchCart();
//       Fluttertoast.showToast(msg: 'Item has been removed');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> clearCartFromFirebase() async {
//     final User? user = _auth.currentUser;
//     try {
//       await usersDb.doc(user!.uid).update({
//         'userCart': [],
//       });
//       await fetchCart();
//       _cartItems.clear();
//       Fluttertoast.showToast(msg: 'Cart has been cleared');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   ///Local
//   void addOrRemoveFromWishlist({required String productId}) {
//     if (_wishlistItems.containsKey(productId)) {
//       _wishlistItems.remove(productId);
//     } else {
//       _wishlistItems.putIfAbsent(
//         productId,
//         () =>
//             WishlistModel(wishlistId: const Uuid().v4(), productId: productId),
//       );
//     }

//     notifyListeners();
//   }

//   bool isProdinWishlist({required String productId}) {
//     return _wishlistItems.containsKey(productId);
//   }

//   void clearLocalWishlist() {
//     _wishlistItems.clear();
//     notifyListeners();
//   }
// }
