import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';

import 'home.dart';
import 'login_screen.dart';

class ReqisterScreen extends StatefulWidget {
  const ReqisterScreen({Key? key}) : super(key: key);

  @override
  State<ReqisterScreen> createState() => _ReqisterScreenState();
}

class _ReqisterScreenState extends State<ReqisterScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordAgainController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: ListView(
      children: [
        Container(
          height: 100,
          width: 500,
          decoration: BoxDecoration(
              color: Colors.teal.shade900,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: size.width * .92,
                decoration: BoxDecoration(
                    color: Colors.teal.shade800,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(.75),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Kayıt Ekranı",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white)),
                        ),
                        Divider(
                          color: Colors.white,
                        ),
                        TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              hintText: 'Kullanıcı adı',
                              prefixText: ' ',
                              hintStyle: TextStyle(color: Colors.white),
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                            )),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextField(
                            controller: _emailController,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.mail,
                                color: Colors.white,
                              ),
                              hintText: 'E-Mail',
                              prefixText: ' ',
                              hintStyle: TextStyle(color: Colors.white),
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                            )),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            cursorColor: Colors.white,
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                color: Colors.white,
                              ),
                              hintText: 'Parola',
                              prefixText: ' ',
                              hintStyle: TextStyle(color: Colors.white),
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                            )),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        TextField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            cursorColor: Colors.white,
                            controller: _passwordAgainController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                color: Colors.white,
                              ),
                              hintText: 'Parola Tekrar',
                              prefixText: ' ',
                              hintStyle: TextStyle(color: Colors.white),
                              focusColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.white,
                              )),
                            )),
                        SizedBox(
                          height: 50,
                        ),
                        InkWell(
                          onTap: () async {
                            UserModel user = UserModel(
                              email: _emailController.text,
                              userName: _nameController.text,
                              id: _auth.currentUser!.uid,
                            );
                            await _authService
                                .createPerson(
                              user,
                              _passwordController.text,
                            )
                                .then((value) {
                              print("Buraya geldi");
                              return Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.teal.shade900,
                                border: Border.all(
                                    color: Colors.teal.shade900, width: 2),
                                //color: colorPrimaryShade,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text(
                                "Kayıt Ol",
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
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 1,
                          width: 75,
                          color: Colors.white,
                        ),
                        Text(
                          "Giriş Yap",
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          height: 1,
                          width: 75,
                          color: Colors.white,
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
          ),
        ),
        SizedBox(height: 80),
      ],
    ));
  }
}
