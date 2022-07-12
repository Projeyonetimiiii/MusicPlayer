import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/util/helper_functions.dart';
import 'package:onlinemusic/widgets/custom_textfield.dart';

import '../root_app.dart';
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
        body: Center(
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
                            child: Text(
                              "Hoş Geldiniz",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CustomTextField(
                            controller: _nameController,
                            hintText: "Kullanıcı adı",
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          CustomTextField(
                            controller: _emailController,
                            hintText: "Eposta",
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "Şifre",
                            obscureText: true,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          CustomTextField(
                            controller: _passwordAgainController,
                            hintText: "Şifre ( Tekrar )",
                            obscureText: true,
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
                                context.pushAndRemoveUntil(RootApp());
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
                                    "Kayıt Ol",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
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
                                "Hesabın var mı? ",
                                style: TextStyle(),
                              ),
                              InkWell(
                                onTap: () {
                                  context.pushAndRemoveUntil(LoginScreen());
                                },
                                child: Text(
                                  "Giriş Yap",
                                  style: TextStyle(
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
    ));
  }
}
