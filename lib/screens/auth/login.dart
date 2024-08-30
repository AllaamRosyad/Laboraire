import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsmart_users_en/consts/validator.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/admin/admin_screen.dart';
import 'package:shopsmart_users_en/screens/auth/forgot_password.dart';
import 'package:shopsmart_users_en/screens/auth/register.dart';
import 'package:shopsmart_users_en/screens/loading_manager.dart';
import '../../services/my_app_functions.dart';
import '../../widgets/app_name_text.dart';
import '../../widgets/subtitle_text.dart';
import '../../widgets/title_text.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _emailController.dispose();
      _passwordController.dispose();
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loginFct() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('dataPengguna')
            .doc(userCredential.user!.uid)
            .get();

        String role = userDoc['role'];

        // Save user role to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);
        await prefs.setBool('isLoggedIn', true); // Save login status

        Fluttertoast.showToast(
          msg: "Login Successful",
          textColor: Colors.white,
        );

        if (!mounted) return;

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AdminScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, RootScreen.routeName);
        }
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevents background from moving
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_login.png', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 50, // Adjust this value to position the logo vertically
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo image path
                  height: 200, // Adjust the size as needed
                ),
              ),
            ),
            // Login Form
            LoadingManager(
              isLoading: _isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height:
                          250, // Adjust this value to control the space below the logo
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: TitlesTextWidget(
                        label: "Selamat Datang,",
                        fontSize: 28, // Adjusted for emphasis
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SubtitleTextWidget(
                        label:
                            "Laboraire Merupakan Aplikasi Peminjaman dan Pengembalian Alat Laboratorium Smart Automation",
                        fontSize: 16, // Smaller subtitle text
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: "E-Mail",
                                prefixIcon: Icon(
                                  IconlyLight.message,
                                ),
                              ),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                              validator: (value) {
                                return MyValidators.emailValidator(value);
                              },
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            TextFormField(
                              obscureText: obscureText,
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(
                                  IconlyLight.lock,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              onFieldSubmitted: (value) async {
                                await _loginFct();
                              },
                              validator: (value) {
                                return MyValidators.passwordValidator(value);
                              },
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    ForgotPasswordScreen.routeName,
                                  );
                                },
                                child: const SubtitleTextWidget(
                                  label: "Forgot Password?",
                                  fontStyle: FontStyle.italic,
                                  textDecoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onPressed: () async {
                                  await _loginFct();
                                },
                                child: const Text("Sign In"),
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(RegisterScreen.routName);
                                },
                                child: const Text("Create Account"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
