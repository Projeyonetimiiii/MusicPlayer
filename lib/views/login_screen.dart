import 'package:flutter/material.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: ListView(children: [
      SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: size.height * .5,
          width: size.width * .95,
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
                    child: Text("Giriş Ekranı",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white)),
                  ),
                  Divider(
                    color: Colors.white,
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
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
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
                    height: size.height * 0.08,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.teal.shade900,
                          border:
                              Border.all(color: Colors.teal.shade900, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                            child: Text(
                          "Giriş yap",
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
                              builder: (context) => ReqisterScreen()));
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
                          "Kayıt ol",
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      MyDivider(),
                      Text(
                        "Ya Da",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      MyDivider(),
                    ],
                  ),
                  Text(
                    "Google ile Oturum Açın",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {},
                      child: CircleAvatar(
                        maxRadius: 30,
                        child: Center(
                          child: Icon(Icons.ac_unit),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 60),
    ]));
  }

  Widget MyDivider() {
    return Container(
      height: 10,
      width: 30,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(15)),
    );
  }
}
