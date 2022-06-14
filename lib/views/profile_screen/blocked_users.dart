import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/blocked_details.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/user_status_service.dart';
import 'package:onlinemusic/util/const.dart';

class BlockedUsers extends StatelessWidget {
  final UserModel user;
  BlockedUsers({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.userName ?? "User"),
      ),
      body: StreamBuilder<List<BlockedDetails>>(
        stream: UserStatusService().blockedUsers,
        builder: (c, snap) {
          if (snap.hasData) {
            if (snap.data!.isEmpty) {
              return Center(
                child: Text("Hiç kullanıcı yok"),
              );
            } else {
              return ListView.builder(
                itemCount: snap.data!.length,
                itemBuilder: (c, i) {
                  BlockedDetails details = snap.data![i];
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream:
                        AuthService().getUserStreamFromId(details.blockedUid),
                    builder: (c, snap) {
                      UserModel? user;
                      if (snap.hasData) {
                        user = UserModel.fromMap(snap.data!.data()!);
                      }
                      return ListTile(
                        title: AnimatedSwitcher(
                          duration: Duration(milliseconds: 350),
                          child: user == null
                              ? SizedBox()
                              : Text(user.userName ?? "User"),
                        ),
                        leading: AnimatedSwitcher(
                          duration: Duration(milliseconds: 350),
                          child: user == null
                              ? SizedBox()
                              : CircleAvatar(
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.image!),
                                ),
                        ),
                        subtitle:
                            Text(Const.getDateTimeString(details.blockedTime)),
                      );
                    },
                  );
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Const.kBackground,
              ),
            );
          }
        },
      ),
    );
  }
}
