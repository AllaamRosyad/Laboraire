// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import '../models/borrowing_model.dart';

// class LoanProvider with ChangeNotifier {
//   final CollectionReference loanCollection =
//       FirebaseFirestore.instance.collection('dataPeminjaman');
//   final CollectionReference returnCollection =
//       FirebaseFirestore.instance.collection('dataPengembalian');
//   final CollectionReference historyCollection =
//       FirebaseFirestore.instance.collection('history');
//   final _auth = FirebaseAuth.instance;

//   List<BorrowingModel> _loans = [];
//   List<BorrowingModel> _returns = [];

//   int _newLoanCount = 0;
//   final ValueNotifier<int> _newLoanCountNotifier = ValueNotifier<int>(0);

//   List<BorrowingModel> get getLoans => _loans;
//   List<BorrowingModel> get getReturns => _returns;

//   ValueNotifier<int> get newLoanCountNotifier => _newLoanCountNotifier;

//   LoanProvider() {
//     _loadNewLoanCount();
//     listenToNewLoans();
//   }

//   Future<void> _loadNewLoanCount() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _newLoanCount = prefs.getInt('newLoanCount') ?? 0;
//     _newLoanCountNotifier.value = _newLoanCount;
//   }

//   Future<void> _saveNewLoanCount() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('newLoanCount', _newLoanCount);
//   }

//   void clearNewLoanCount() async {
//     _newLoanCount = 0;
//     _newLoanCountNotifier.value = _newLoanCount;
//     await _saveNewLoanCount();
//     notifyListeners();
//   }

//   void listenToNewLoans() {
//     int previousCount = 0;
//     loanCollection.snapshots().listen((querySnapshot) {
//       final newCount = querySnapshot.docs.length;
//       if (newCount > previousCount) {
//         _newLoanCount += newCount - previousCount;
//         _newLoanCountNotifier.value = _newLoanCount;
//         _saveNewLoanCount();
//         notifyListeners();
//       }
//       previousCount = newCount;
//     });
//   }

//   Future<void> fetchLoans() async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user == null) return;

//       final loanSnapshot =
//           await loanCollection.where('userId', isEqualTo: user.uid).get();

//       _loans = loanSnapshot.docs
//           .map((doc) => BorrowingModel.fromFirestore(doc))
//           .toList();

//       notifyListeners();
//     } catch (error) {
//       print("Error fetching loans: $error");
//       throw error;
//     }
//   }

//   Future<void> fetchReturns() async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user == null) return;

//       final returnSnapshot =
//           await returnCollection.where('userId', isEqualTo: user.uid).get();

//       _returns = returnSnapshot.docs
//           .map((doc) => BorrowingModel.fromFirestore(doc))
//           .toList();

//       notifyListeners();
//     } catch (error) {
//       print("Error fetching returns: $error");
//       throw error;
//     }
//   }

//   Future<void> borrowProduct({
//     required String productId,
//     required String productTitle,
//     required String userName,
//     required String imageUrl,
//     required DateTime loanStartDate,
//     required DateTime loanEndDate,
//     required String productCondition,
//     required int quantityToBorrow,
//     required BuildContext context,
//   }) async {
//     final User? user = _auth.currentUser;
//     if (user == null) {
//       return;
//     }

//     final peminjamanId = Uuid().v4();

//     final newLoan = BorrowingModel(
//       peminjamanId: peminjamanId,
//       userId: user.uid,
//       productId: productId,
//       productImage: imageUrl,
//       productName: productTitle,
//       statusPeminjaman: 'Belum Disetujui',
//       statusPengembalian: 'Belum Disetujui',
//       quantity: quantityToBorrow,
//       tanggalPeminjaman: Timestamp.fromDate(loanStartDate),
//       tanggalPengembalian: Timestamp.fromDate(loanEndDate),
//       userName: userName,
//       type: 'peminjaman',
//     );

//     try {
//       bool isAvailable = await checkProductAvailability(
//         productId: productId,
//         quantityToBorrow: quantityToBorrow,
//         context: context,
//       );

//       if (!isAvailable) return;

//       print('Checking if the product with ID: $productId is available.');

//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('dataBarang')
//           .where('product_id', isEqualTo: productId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         DocumentReference productRef = querySnapshot.docs.first.reference;
//         await productRef
//             .update({'product_stok': FieldValue.increment(-quantityToBorrow)});
//         print('Stock updated for product ID: $productId');
//       } else {
//         print('Product with that ID not found.');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product not found in Firestore.')),
//         );
//         return;
//       }

//       // Simpan data peminjaman ke 'dataPeminjaman' dan 'history' dengan ID unik
//       await loanCollection.doc(peminjamanId).set(newLoan.toMap());
//       await historyCollection.doc(Uuid().v4()).set(newLoan.toMap());

//       _loans.add(newLoan);
//       _newLoanCount++;
//       _newLoanCountNotifier.value = _newLoanCount;
//       _saveNewLoanCount();
//       notifyListeners();
//     } catch (error) {
//       print('Error during borrowing: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error during borrowing: $error')),
//       );
//     }
//   }

//   Future<bool> checkProductAvailability({
//     required String productId,
//     required int quantityToBorrow,
//     required BuildContext context,
//   }) async {
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('dataBarang')
//           .where('product_id', isEqualTo: productId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         DocumentSnapshot productSnapshot = querySnapshot.docs.first;
//         int currentStock = productSnapshot['product_stok'];

//         if (currentStock < quantityToBorrow) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Cannot borrow $quantityToBorrow items. Only $currentStock available.',
//               ),
//             ),
//           );
//           return false;
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product not found in Firestore.')),
//         );
//         return false;
//       }
//       return true;
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error checking product availability: $error'),
//         ),
//       );
//       return false;
//     }
//   }

//   Future<void> returnProduct(BorrowingModel loan, BuildContext context) async {
//     try {
//       // Hanya tambahkan data pengembalian ke 'dataPengembalian'
//       await returnCollection.doc(loan.peminjamanId).set({
//         ...loan.toMap(),
//         'status_pengembalian': 'Belum Disetujui',
//       });

//       await loanCollection.doc(loan.peminjamanId).delete();

//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('dataBarang')
//           .where('product_id', isEqualTo: loan.productId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         DocumentReference productRef = querySnapshot.docs.first.reference;
//         await productRef
//             .update({'product_stok': FieldValue.increment(loan.quantity)});
//         print('Stock updated for product ID: ${loan.productId}');
//       } else {
//         print('Product with ID ${loan.productId} not found.');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Product with ID ${loan.productId} not found in Firestore.')),
//         );
//         return;
//       }

//       _loans.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
//       notifyListeners();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product successfully returned!')),
//       );
//     } catch (error) {
//       print('Error returning product: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error returning product: $error')),
//       );
//     }
//   }

//   Future<void> moveToHistory(BorrowingModel loan, BuildContext context) async {
//     try {
//       // Hanya tambahkan catatan ke 'history' saat pengembalian disetujui
//       await historyCollection.doc(Uuid().v4()).set({
//         ...loan.toMap(),
//         'status_pengembalian': 'Disetujui',
//         'type': 'pengembalian',
//       });

//       await returnCollection.doc(loan.peminjamanId).delete();

//       _returns.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
//       notifyListeners();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Data moved to history successfully!')),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error moving data to history: $error')),
//       );
//     }
//   }

//   Future<void> approveReturn(BorrowingModel loan, BuildContext context) async {
//     try {
//       // Update status di 'dataPengembalian'
//       await returnCollection.doc(loan.peminjamanId).update({
//         'status_pengembalian': 'Disetujui',
//       });

//       // Pindahkan ke history setelah disetujui
//       await moveToHistory(loan, context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Return approved and moved to history!')),
//       );
//     } catch (error) {
//       print('Error approving return: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error approving return: $error')),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/borrowing_model.dart';

class LoanProvider with ChangeNotifier {
  final CollectionReference loanCollection =
      FirebaseFirestore.instance.collection('dataPeminjaman');
  final CollectionReference returnCollection =
      FirebaseFirestore.instance.collection('dataPengembalian');
  final CollectionReference historyCollection =
      FirebaseFirestore.instance.collection('history');
  final _auth = FirebaseAuth.instance;

  List<BorrowingModel> _loans = [];
  List<BorrowingModel> _returns = [];

  int _newLoanCount = 0;
  final ValueNotifier<int> _newLoanCountNotifier = ValueNotifier<int>(0);

  List<BorrowingModel> get getLoans => _loans;
  List<BorrowingModel> get getReturns => _returns;

  ValueNotifier<int> get newLoanCountNotifier => _newLoanCountNotifier;

  LoanProvider() {
    _loadNewLoanCount();
    listenToNewLoans();
  }

  Future<void> _loadNewLoanCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _newLoanCount = prefs.getInt('newLoanCount') ?? 0;
    _newLoanCountNotifier.value = _newLoanCount;
  }

  Future<void> _saveNewLoanCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('newLoanCount', _newLoanCount);
  }

  void clearNewLoanCount() async {
    _newLoanCount = 0;
    _newLoanCountNotifier.value = _newLoanCount;
    await _saveNewLoanCount();
    notifyListeners();
  }

  void listenToNewLoans() {
    int previousCount = 0;
    loanCollection.snapshots().listen((querySnapshot) {
      final newCount = querySnapshot.docs.length;
      if (newCount > previousCount) {
        _newLoanCount += newCount - previousCount;
        _newLoanCountNotifier.value = _newLoanCount;
        _saveNewLoanCount();
        notifyListeners();
      }
      previousCount = newCount;
    });
  }

  Future<void> fetchLoans() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final loanSnapshot =
          await loanCollection.where('userId', isEqualTo: user.uid).get();

      _loans = loanSnapshot.docs
          .map((doc) => BorrowingModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching loans: $error");
      throw error;
    }
  }

  Future<void> fetchReturns() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final returnSnapshot =
          await returnCollection.where('userId', isEqualTo: user.uid).get();

      _returns = returnSnapshot.docs
          .map((doc) => BorrowingModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching returns: $error");
      throw error;
    }
  }

  Future<void> borrowProduct({
    required String productId,
    required String productTitle,
    required String userName,
    required String imageUrl,
    required DateTime loanStartDate,
    required DateTime loanEndDate,
    required String productCondition,
    required int quantityToBorrow,
    required BuildContext context,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final peminjamanId = Uuid().v4();

    final newLoan = BorrowingModel(
      peminjamanId: peminjamanId,
      userId: user.uid,
      productId: productId,
      productImage: imageUrl,
      productName: productTitle,
      statusPeminjaman: 'Belum Disetujui',
      statusPengembalian: 'Belum Disetujui',
      quantity: quantityToBorrow,
      tanggalPeminjaman: Timestamp.fromDate(loanStartDate),
      tanggalPengembalian: Timestamp.fromDate(loanEndDate),
      userName: userName,
      type: 'peminjaman',
    );

    try {
      bool isAvailable = await checkProductAvailability(
        productId: productId,
        quantityToBorrow: quantityToBorrow,
        context: context,
      );

      if (!isAvailable) return;

      print('Checking if the product with ID: $productId is available.');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dataBarang')
          .where('product_id', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference productRef = querySnapshot.docs.first.reference;
        await productRef
            .update({'product_stok': FieldValue.increment(-quantityToBorrow)});
        print('Stock updated for product ID: $productId');
      } else {
        print('Product with that ID not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found in Firestore.')),
        );
        return;
      }

      // Simpan data peminjaman ke 'dataPeminjaman' saja
      await loanCollection.doc(peminjamanId).set(newLoan.toMap());

      _loans.add(newLoan);
      _newLoanCount++;
      _newLoanCountNotifier.value = _newLoanCount;
      _saveNewLoanCount();
      notifyListeners();
    } catch (error) {
      print('Error during borrowing: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during borrowing: $error')),
      );
    }
  }

  Future<bool> checkProductAvailability({
    required String productId,
    required int quantityToBorrow,
    required BuildContext context,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dataBarang')
          .where('product_id', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot productSnapshot = querySnapshot.docs.first;
        int currentStock = productSnapshot['product_stok'];

        if (currentStock < quantityToBorrow) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot borrow $quantityToBorrow items. Only $currentStock available.',
              ),
            ),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found in Firestore.')),
        );
        return false;
      }
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking product availability: $error'),
        ),
      );
      return false;
    }
  }

  Future<void> approveLoan(BorrowingModel loan, BuildContext context) async {
    try {
      await loanCollection.doc(loan.peminjamanId).update({
        'status_peminjaman': 'Disetujui',
      });

      // Setelah disetujui, pindahkan data ke 'history'
      await historyCollection.doc(Uuid().v4()).set({
        ...loan.toMap(),
        'status_peminjaman':
            'Disetujui', // Memastikan status adalah 'Disetujui'
        'type': 'peminjaman',
      });

      // Optionally, you can remove the loan from the active list after approval
      _loans.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan approved and moved to history!')),
      );
    } catch (error) {
      print('Error approving loan: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving loan: $error')),
      );
    }
  }

  Future<void> returnProduct(BorrowingModel loan, BuildContext context) async {
    try {
      await returnCollection.doc(loan.peminjamanId).set({
        ...loan.toMap(),
        'status_pengembalian': 'Belum Disetujui',
      });

      await loanCollection.doc(loan.peminjamanId).delete();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dataBarang')
          .where('product_id', isEqualTo: loan.productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference productRef = querySnapshot.docs.first.reference;
        await productRef
            .update({'product_stok': FieldValue.increment(loan.quantity)});
        print('Stock updated for product ID: ${loan.productId}');
      } else {
        print('Product with ID ${loan.productId} not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Product with ID ${loan.productId} not found in Firestore.')),
        );
        return;
      }

      _loans.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product successfully returned!')),
      );
    } catch (error) {
      print('Error returning product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error returning product: $error')),
      );
    }
  }

  Future<void> approveReturn(BorrowingModel loan, BuildContext context) async {
    try {
      await returnCollection.doc(loan.peminjamanId).update({
        'status_pengembalian': 'Disetujui',
      });

      // Pindahkan ke history setelah disetujui
      await historyCollection.doc(Uuid().v4()).set({
        ...loan.toMap(),
        'status_pengembalian': 'Disetujui',
        'type': 'pengembalian',
      });

      await returnCollection.doc(loan.peminjamanId).delete();

      _returns.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return approved and moved to history!')),
      );
    } catch (error) {
      print('Error approving return: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving return: $error')),
      );
    }
  }

  Future<void> moveToHistory(BorrowingModel loan, BuildContext context) async {
    try {
      await historyCollection.doc(Uuid().v4()).set({
        ...loan.toMap(),
        'status_pengembalian': 'Disetujui', // Hanya setelah disetujui
        'type': 'pengembalian',
      });

      await returnCollection.doc(loan.peminjamanId).delete();

      _returns.removeWhere((item) => item.peminjamanId == loan.peminjamanId);
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data moved to history successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error moving data to history: $error')),
      );
    }
  }
}
