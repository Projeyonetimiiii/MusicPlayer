import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

import '../models/genre.dart';
import '../widgets/customlist.dart';

class CategoryPage extends StatefulWidget {
  final List<Genre>? genres;
  const CategoryPage({Key? key, this.genres}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Genre> genreList;

  @override
  void initState() {
    genreList = widget.genres ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
            ),
            height: 10,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: IntrinsicHeight(
                child: Column(
                  children: Const.genres.map((e) {
                    return CustomSwitchListTile(
                      activeColor: Colors.black,
                      inactiveThumbColor: Colors.grey,
                      title: Text(e.name),
                      onChanged: (bool value) {
                        if (value) {
                          if (!genreList.any((element) => element.id == e.id)) {
                            genreList.add(e);
                          }
                        } else {
                          genreList
                              .removeWhere(((element) => element.id == e.id));
                        }
                        WidgetsBinding.instance!
                            .addPostFrameCallback((timeStamp) {
                          setState(() {});
                        });
                      },
                      value: genreList.any((element) => element.id == e.id),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          MaterialButton(
            minWidth: 80,
            height: 40,
            onPressed: () {
              Navigator.pop(context, genreList);
            },
            child: Text("Kaydet"),
          )
        ],
      ),
    );
  }
}
