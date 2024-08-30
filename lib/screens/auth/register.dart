import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_users_en/consts/validator.dart';
import 'package:shopsmart_users_en/screens/loading_manager.dart';
import 'package:shopsmart_users_en/services/my_app_functions.dart';
import 'package:shopsmart_users_en/widgets/app_name_text.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

import '../../root_screen.dart';
import '../../widgets/auth/image_picker_widget.dart';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscureText = true;
  late final TextEditingController _nameController,
      _prodiController, // Controller for Prodi
      _emailController,
      _passwordController,
      _repeatPasswordController,
      _phoneController;

  late final FocusNode _nameFocusNode,
      _prodiFocusNode, // Focus node for Prodi
      _emailFocusNode,
      _passwordFocusNode,
      _repeatPasswordFocusNode,
      _phoneFocusNode;

  final _formkey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool _isLoading = false;
  final auth = FirebaseAuth.instance;
  String? userImageUrl;

  @override
  void initState() {
    _nameController = TextEditingController();
    _prodiController = TextEditingController(); // Initialize Prodi controller
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _nameFocusNode = FocusNode();
    _prodiFocusNode = FocusNode(); // Initialize Prodi focus node
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _nameController.dispose();
      _prodiController.dispose(); // Dispose Prodi controller
      _emailController.dispose();
      _passwordController.dispose();
      _repeatPasswordController.dispose();
      _phoneController.dispose();
      _nameFocusNode.dispose();
      _prodiFocusNode.dispose(); // Dispose Prodi focus node
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
      _repeatPasswordFocusNode.dispose();
      _phoneFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _registerFCT() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: "Make sure to pick up an image",
          fct: () {});
      return;
    }
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User? user = auth.currentUser;
        final String uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child("usersImages")
            .child("${_emailController.text.trim()}.jpg");
        await ref.putFile(File(_pickedImage!.path));
        userImageUrl = await ref.getDownloadURL();

        // Save user details to Firestore in 'dataPengguna' collection
        await FirebaseFirestore.instance
            .collection("dataPengguna")
            .doc(uid)
            .set({
          'user_id': uid,
          'user_name': _nameController.text,
          'prodi': _prodiController.text.trim(), // Add Prodi field
          'user_image': userImageUrl,
          'email': _emailController.text.toLowerCase(),
          'createdAt': Timestamp.now(),
          'role': 'user', // Default role to 'user'
          'no_hp': _phoneController.text.trim(),
        });

        Fluttertoast.showToast(
          msg: "An account has been created",
          textColor: Colors.white,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RootScreen.routeName);
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

  Future<void> localImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
        setState(() {});
      },
      galleryFCT: () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: LoadingManager(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  const AppNameTextWidget(
                    fontSize: 30,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitlesTextWidget(label: "Selamat Datang!"),
                          SubtitleTextWidget(
                              label: "Buat Akun Terlebih Dahulu"),
                        ],
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: size.width * 0.3,
                    width: size.width * 0.3,
                    child: PickImageWidget(
                      pickedImage: _pickedImage,
                      function: () async {
                        await localImagePicker();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(
                                _prodiFocusNode); // Focus on Prodi next
                          },
                          validator: (value) {
                            return MyValidators.displayNamevalidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _prodiController, // Set Prodi controller
                          focusNode: _prodiFocusNode, // Set Prodi focus node
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: 'Prodi', // Hint text for the new field
                            prefixIcon: Icon(
                              Icons.school,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(
                                _emailFocusNode); // Focus on Email next
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Prodi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Alamat Email",
                            prefixIcon: Icon(
                              IconlyLight.message,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_phoneFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.emailValidator(value);
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "Phone number",
                            prefixIcon: Icon(
                              Icons.phone,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
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
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_repeatPasswordFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          controller: _repeatPasswordController,
                          focusNode: _repeatPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "Repeat password",
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
                            await _registerFCT();
                          },
                          validator: (value) {
                            return MyValidators.repeatPasswordValidator(
                              value: value, // Corrected named argument
                              password: _passwordController
                                  .text, // Corrected named argument
                            );
                          },
                        ),
                        const SizedBox(
                          height: 36.0,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ),
                              ),
                            ),
                            icon: const Icon(IconlyLight.addUser),
                            label: const Text("Sign up"),
                            onPressed: () async {
                              await _registerFCT();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
