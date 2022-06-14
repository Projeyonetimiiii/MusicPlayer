import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/media_reference.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/util/enums.dart';
import 'package:onlinemusic/util/mixins.dart';
import 'package:onlinemusic/views/chat/models/sender_media_message.dart';
import 'package:onlinemusic/views/details_screen/widgets/image_dismissible_widget.dart';
import 'package:onlinemusic/views/details_screen/widgets/textfield_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:extended_image/extended_image.dart';

class ImagesDetail extends StatefulWidget {
  final List<PlatformFile>? files;
  final UserModel? receiver;
  ImagesDetail({Key? key, this.files, this.receiver}) : super(key: key);

  @override
  _ImagesDetailState createState() => _ImagesDetailState(files: files);
}

class _ImagesDetailState extends State<ImagesDetail>
    with PickerMixin, LoadingMixin {
  List<PlatformFile>? files;
  int selectIndex = 0;
  ExtendedPageController? _pageController;
  ScrollController? _scrollController;
  BehaviorSubject<double>? shadow;
  List<MediaReference> downloadsRef = [];
  TextEditingController _message = TextEditingController();
  BehaviorSubject<double>? loadingProgress;

  _ImagesDetailState({this.files});

  @override
  Widget build(BuildContext context) {
    StorageBloc storageBloc = StorageBloc();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: ExtendedImageGesturePageView.builder(
              controller: _pageController,
              itemCount: files!.length,
              onPageChanged: (i) {
                setState(() {
                  selectIndex = i;
                });
              },
              itemBuilder: (c, i) {
                return ExtendedImage.file(
                  File(files![i].path!),
                  key: Key(files![i].path!),
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (d) {
                    return GestureConfig(
                      cacheGesture: false,
                      inPageView: true,
                      initialScale: 1,
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              titleSpacing: 0,
              backgroundColor: Colors.black38,
              title: Row(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.receiver!.image!),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    widget.receiver!.userName!,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {
                    if (files!.length == 1) {
                      Navigator.pop(context);
                    } else {
                      files!.removeAt(selectIndex);
                      setState(() {
                        selectIndex > 1 ? selectIndex-- : selectIndex = 0;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 110,
              color: Colors.black38,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.maxFinite,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  controller: _message,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  String time = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  showLoadingStreamDialog(
                                      context, loadingProgress!);

                                  files!.asMap().forEach((index, value) async {
                                    MediaReference ref =
                                        await storageBloc.uploadMessageImage(
                                      index: index,
                                      ext: StorageBloc.fileExt(value.path!),
                                      file: File(value.path!),
                                      timeStamp: time,
                                      userUid: FirebaseAuth
                                          .instance.currentUser!.uid,
                                    );
                                    print("downloadurl= " + ref.downloadURL!);
                                    downloadsRef.add(ref);
                                    double val =
                                        (downloadsRef.length / files!.length);
                                    loadingProgress!.add(val >= 1 ? 1 : val);
                                    if (val >= 1) {
                                      Navigator.pop(context);
                                    }
                                    if (downloadsRef.length == files!.length) {
                                      SenderMediaMessage senderMessage =
                                          SenderMediaMessage(
                                        type: ChatMessageType.Image,
                                        refs: downloadsRef,
                                        message: _message.text,
                                      );
                                      Navigator.pop(context, senderMessage);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () async {
                                    List<PlatformFile> newImages =
                                        await getImagePicker();
                                    newImages.forEach((element) {
                                      if (!files!
                                          .any((e) => e.path == element.path)) {
                                        files!.add(element);
                                      }
                                    });
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 50,
                                    child: Center(
                                      child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              StreamBuilder<double>(
                                  stream: shadow,
                                  initialData: 0,
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: (snapshot.data! > 0) ? 5 : 5),
                                      child: AnimatedOpacity(
                                        opacity: snapshot.data! > 0 ? 1 : 0,
                                        duration: Duration(milliseconds: 300),
                                        child: Container(
                                          width: 3,
                                          padding: EdgeInsets.all(5),
                                          height: double.maxFinite,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 4,
                                                    offset: Offset(0, 0),
                                                    color: Colors.white30,
                                                    spreadRadius: 4),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                    );
                                  }),
                              Expanded(
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  controller: _scrollController,
                                  padding: EdgeInsets.all(5),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: files!.length,
                                  itemBuilder: (c, i) {
                                    return GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          selectIndex = i;
                                        });
                                        await _pageController!.animateToPage(
                                            selectIndex,
                                            duration:
                                                Duration(milliseconds: 400),
                                            curve: Curves.linear);
                                      },
                                      child: ImageDismissibleWidget(
                                        file: files![i],
                                        isSelected: selectIndex == i,
                                        onDismissed: (d) {
                                          if (files!.length == 1) {
                                            Navigator.pop(context);
                                          } else {
                                            files!.removeAt(i);
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getShadow() {
    double shad;
    try {
      shad = _scrollController!.offset.toInt() <= 0 ? 0 : 8;
    } catch (e) {
      shad = 0;
    }
    shadow!.add(shad);
  }

  @override
  void initState() {
    super.initState();
    _pageController = ExtendedPageController(initialPage: 0);
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      getShadow();
    });
    loadingProgress = BehaviorSubject.seeded(0);
    shadow = BehaviorSubject.seeded(0);
  }

  @override
  void dispose() {
    shadow!.close();
    loadingProgress!.close();
    super.dispose();
  }
}
