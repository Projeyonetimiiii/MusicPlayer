import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usermodel.dart';
import '../services/storage_bloc.dart';
import '../services/user_status_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final ImagePicker _pickerImage = ImagePicker();
  final StorageBloc storageService = StorageBloc();
  dynamic _pickImage;
  XFile? profileImage;
  final UserStatusService statusService = UserStatusService();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userModel.userName ?? "";
    _emailController.text = widget.userModel.email ?? "";
    _bio.text = widget.userModel.bio ?? "";
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget imagePlace() {
    if (widget.userModel.image != null) {
      setState(() {
        _pickImage = widget.userModel.image;
      });
    }
    if (profileImage != null) {
      print("resim : " + profileImage!.path);
      return CircleAvatar(
          backgroundImage: FileImage(File(profileImage!.path)), radius: 60);
    } else {
      if (_pickImage != null) {
        return CircleAvatar(
          backgroundImage: NetworkImage(_pickImage),
          radius: 60,
        );
      } else
        return CircleAvatar(
          maxRadius: 60,
          child: Icon(Icons.supervised_user_circle_outlined),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Profil Bilgileri"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _onImageButtonPressed(ImageSource.gallery,
                              context: context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imagePlace(),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          bottom: 5,
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 30,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Kişisel bilgi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                      controller: _nameController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          hintText: 'Kullanıcı adı',
                          prefixText: ' ',
                          hintStyle: TextStyle(color: Colors.black),
                          focusColor: Colors.black,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)))),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
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
                          focusColor: Colors.black,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)))),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                      maxLines: 5,
                      controller: _bio,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: 'Biografi',
                          prefixText: ' ',
                          hintStyle: TextStyle(color: Colors.black),
                          focusColor: Colors.black,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        UserModel userModel = widget.userModel;
                        if (profileImage != null) {
                          var mediaUrl = await storageService.uploadImage(
                              profileImage!.path, _auth.currentUser!.uid,
                              timeStamp: "");
                          userModel = userModel..image = mediaUrl;
                        }
                        userModel = userModel
                          ..userName = _nameController.text
                          ..email = _emailController.text
                          ..bio = _bio.text;
                        statusService.updateProfile(userModel);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                            child: Text(
                          "Bilgileri güncelle",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                              child: Text(
                            "Vazgeç",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      final pickedFile = await _pickerImage.pickImage(source: source);
      setState(() {
        profileImage = pickedFile!;
        print("dosyaya geldim: $profileImage");
        if (profileImage != null) {}
      });
      print('aaa');
    } catch (e) {
      setState(() {
        _pickImage = e;
        print("Image Error: " + _pickImage);
      });
    }
  }
}
