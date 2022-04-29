import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';

import 'home.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordAgainController =
      TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      color: Colors.grey.shade400.withOpacity(0.1),
      child: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Welcome ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black)),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Material(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: TextField(
                                  controller: _nameController,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.mail,
                                        color: Colors.black,
                                      ),
                                      hintText: 'user name',
                                      prefixText: ' ',
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: InputBorder.none)),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Material(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: TextField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.mail,
                                        color: Colors.black,
                                      ),
                                      hintText: 'E-Mail',
                                      prefixText: ' ',
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: InputBorder.none)),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Material(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: TextField(
                                  obscureText: true,
                                  controller: _passwordController,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.black,
                                      ),
                                      hintText: 'password',
                                      prefixText: ' ',
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: InputBorder.none)),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Material(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: TextField(
                                  obscureText: true,
                                  controller: _passwordAgainController,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.black,
                                      ),
                                      hintText: 'password again',
                                      prefixText: ' ',
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: InputBorder.none)),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            InkWell(
                              onTap: () async {
                                if (_passwordController.text !=
                                    _passwordAgainController.text) {
                                  showErrorNotification(
                                    description: "Şifreler uyuşmuyor",
                                  );
                                  return;
                                } else {
                                  if (_passwordController.text.length < 6) {
                                    showErrorNotification(
                                      description:
                                          "Şifre en az 6 karakter olmalı",
                                    );
                                    return;
                                  }
                                }
                                UserModel userModel = UserModel(
                                    email: _emailController.text,
                                    userName: _nameController.text);
                                User? user = await _authService.createPerson(
                                  userModel,
                                  _passwordController.text,
                                );
                                if (user != null) {
                                  context.pushAndRemoveUntil(HomePage());
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                      child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  )),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "do you have an account? ",
                                  style: TextStyle(color: Colors.black),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                      (_) => false,
                                    );
                                  },
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
