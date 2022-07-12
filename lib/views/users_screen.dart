import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/profile_screen/profile_screen.dart';
import 'package:onlinemusic/widgets/custom_back_button.dart';

class UsersScreen extends StatefulWidget {
  UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        title: Text("Kullanıcılar"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AuthService().usersReference.snapshots(),
        builder: (c, snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Const.kBackground,
              ),
            );
          }
          List<UserModel> users =
              snap.data!.docs.map((e) => UserModel.fromMap(e.data())).toList();
          users.removeWhere((element) =>
              element.id == FirebaseAuth.instance.currentUser!.uid);
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (c, i) {
              UserModel user = users[i];
              Color color = user.isOnline == true ? Colors.green : Colors.red;
              return Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 10,
                    bottom: 10,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 7,
                    top: 11,
                    bottom: 11,
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      context.push(ProfileScreen(userModel: user));
                    },
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 4,
                        shape: StadiumBorder(),
                        child: CachedNetworkImage(
                          imageUrl: user.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      user.userName ?? "User",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      user.bio ?? "Biografi",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
