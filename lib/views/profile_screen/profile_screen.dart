import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/auth/login_screen.dart';
import 'package:onlinemusic/views/chat/messages/message_screen.dart';
import 'package:onlinemusic/views/profile_screen/blocked_users.dart';
import 'package:onlinemusic/views/profile_screen/edit_profile_screen.dart';
import 'package:onlinemusic/views/profile_screen/shared_songs_screen.dart';
import '../../models/usermodel.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMee = false;

  @override
  void initState() {
    super.initState();
    isMee = widget.userModel.id == FirebaseAuth.instance.currentUser!.uid;
  }

  Widget imagePlace() {
    return CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      backgroundImage: CachedNetworkImageProvider(widget.userModel.image!),
      radius: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
        iconTheme: IconThemeData(
          color: Const.kBackground,
        ),
        actions: [
          if (isMee)
            IconButton(
              onPressed: () async {
                await context.push(EditProfile(userModel: widget.userModel));
                setState(() {});
              },
              icon: Icon(Icons.mode_edit_outlined),
            )
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Const.kBackground.withOpacity(0.25),
                    offset: Offset(0, 7),
                    blurRadius: 12,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                )),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  imagePlace(),
                  SizedBox(height: 30),
                  Text(
                    widget.userModel.userName ?? "",
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "    " + (widget.userModel.bio ?? ""),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  if (isMee) ...[
                    SizedBox(height: 25),
                    Text(
                      widget.userModel.email ?? "",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          listTileWidget(
            onTap: () {
              context.push(SharedSongsScreen(user: widget.userModel));
            },
            title: "Yüklenen müzikler",
            leadingIcon: Icons.music_note_rounded,
          ),
          if (!isMee) ...[
            listTileWidget(
              onTap: () {
                context.push(MessagesScreen(user: widget.userModel));
              },
              title: "Mesaj at",
              leadingIcon: Icons.message_rounded,
            ),
          ],
          if (isMee) ...[
            listTileWidget(
              onTap: () {
                context.push(BlockedUsers(user: widget.userModel));
              },
              title: "Engellenen kullanıcılar",
              leadingIcon: Icons.person_off_outlined,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Const.kBackground.withOpacity(0.4),
              endIndent: 30,
              indent: 30,
            ),
            ListTile(
              onTap: () async {
                await AuthService().signOut();
                context.pushAndRemoveUntil(LoginScreen());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 28),
              leading: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-pi),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
              ),
              title: Text(
                "Çıkış yap",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
          // if (!isMee && widget.userModel.connectedUserId == null) ...[
          //   listTileWidget(
          //     onTap: () {
          //       context.push(BlockedUsers(user: widget.userModel));
          //     },
          //     title: "Eşleşme isteği gönder",
          //     leadingIcon: Icons.person_add_alt,
          //   ),
          // ],
        ],
      ),
    );
  }

  ListTile listTileWidget({
    required String title,
    required IconData leadingIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 28),
      leading: Icon(leadingIcon, color: Const.kBackground.withOpacity(0.4)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Const.kBackground,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Const.kBackground.withOpacity(0.4),
      ),
    );
  }
}
