import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';
import 'package:onlinemusic/widgets/custom_textfield.dart';

class EditProfile extends StatefulWidget {
  final UserModel userModel;
  const EditProfile({Key? key, required this.userModel}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final ImagePicker _pickerImage = ImagePicker();
  XFile? profileImage;
  final StorageBloc storageService = StorageBloc();
  final UserStatusService statusService = UserStatusService();
  dynamic _pickImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userModel.userName ?? "";
    _bio.text = widget.userModel.bio ?? "";
  }

  Widget imagePlace() {
    if (widget.userModel.image != null) {
      setState(() {
        _pickImage = widget.userModel.image;
      });
    }
    if (profileImage != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        backgroundImage: FileImage(File(profileImage!.path)),
        radius: 120,
      );
    } else {
      if (_pickImage != null) {
        return CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          backgroundImage: CachedNetworkImageProvider(_pickImage!),
          radius: 120,
        );
      } else
        return CircleAvatar(
          maxRadius: 120,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.supervised_user_circle_outlined),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Profili düzenle",
          style: TextStyle(
            color: Const.kBackground,
          ),
        ),
        leading: CustomBackButton(
          color: Const.kBackground,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  child: imagePlace(),
                  elevation: 4,
                  shape: StadiumBorder(),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: RawMaterialButton(
                    constraints: BoxConstraints.loose(Size.square(45)),
                    shape: StadiumBorder(),
                    fillColor: Colors.grey.shade200,
                    onPressed: () {
                      _onImageButtonPressed(
                        ImageSource.gallery,
                        context: context,
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.camera_alt,
                        color: Const.kBackground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  hintText: "Kullanıcı adı",
                  horizontalPadding: 0,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.only(
                    top: 15,
                  ),
                  onChanged: (s) {
                    setState(() {});
                  },
                ),
                CustomTextField(
                  controller:
                      TextEditingController(text: widget.userModel.email),
                  hintText: "Email",
                  horizontalPadding: 0,
                  readOnly: true,
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.only(
                    top: 15,
                  ),
                ),
                CustomTextField(
                  controller: _bio,
                  hintText: "Biyografi",
                  horizontalPadding: 8,
                  maxLines: 5,
                  onChanged: (s) {
                    setState(() {});
                  },
                ),
              ],
            ),
            if (AuthService().isAdmin &&
                widget.userModel.id != AuthService().currentUser.value?.id &&
                !(widget.userModel.isAdmin ?? false)) ...[
              SwitchListTile.adaptive(
                activeColor: Const.kBackground,
                title: Text("Çevrimiçi"),
                value: widget.userModel.isOnline ?? false,
                onChanged: (s) {
                  UserModel user = widget.userModel..isOnline = s;
                  statusService.updateProfile(user);
                  setState(() {});
                },
              ),
              SwitchListTile.adaptive(
                activeColor: Const.kBackground,
                title: Text("Admin"),
                value: widget.userModel.isAdmin ?? false,
                onChanged: (s) {
                  UserModel user = widget.userModel..isAdmin = s;
                  statusService.updateProfile(user);
                  setState(() {});
                },
              ),
            ],
            SizedBox(
              height: 16,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              child: !checkUser()
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: RawMaterialButton(
                              fillColor: Const.kBackground,
                              splashColor: Colors.white12,
                              hoverColor: Colors.white12,
                              highlightColor: Colors.white12,
                              shape: StadiumBorder(),
                              onPressed: () async {
                                UserModel userModel = widget.userModel;
                                if (profileImage != null) {
                                  var mediaUrl =
                                      await storageService.uploadProfileImage(
                                    profileImage!.path,
                                    _auth.currentUser!.uid,
                                  );
                                  userModel = userModel..image = mediaUrl;
                                  await FirebaseAuth.instance.currentUser!
                                      .updatePhotoURL(
                                    mediaUrl,
                                  );
                                }
                                if (_nameController.text.trim() !=
                                    widget.userModel.userName) {
                                  await FirebaseAuth.instance.currentUser!
                                      .updateDisplayName(
                                    _nameController.text.trim(),
                                  );
                                }
                                userModel = userModel
                                  ..userName = _nameController.text.trim()
                                  ..bio = _bio.text;
                                statusService.updateProfile(userModel);
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    "Kaydet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool checkUser() {
    if (_nameController.text.trim() != widget.userModel.userName) {
      return true;
    }
    if (profileImage != null) {
      return true;
    }
    if (_bio.text.trim() != widget.userModel.bio) {
      return true;
    }
    return false;
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      final pickedFile = await _pickerImage.pickImage(source: source);
      setState(() {
        profileImage = pickedFile!;
        if (profileImage != null) {}
      });
    } catch (e) {
      setState(() {
        _pickImage = e;
      });
    }
  }
}
