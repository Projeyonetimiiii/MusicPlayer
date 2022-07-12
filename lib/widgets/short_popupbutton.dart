// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

import 'package:onlinemusic/views/playing_screen/widgets/my_popup_divider.dart';

typedef ChangeSort = void Function(SortType, OrderType);

class SortPopupButton extends StatefulWidget {
  final SortType? sortValue;
  final OrderType? orderValue;
  final ChangeSort? changeSort;
  final bool isDownload;
  SortPopupButton({
    Key? key,
    this.sortValue,
    this.orderValue,
    this.changeSort,
    this.isDownload = false,
  }) : super(key: key);

  @override
  State<SortPopupButton> createState() => _SortPopupButtonState();
}

class _SortPopupButtonState extends State<SortPopupButton> {
  late int sortValue;
  late int orderValue;

  SortType get sortType {
    return SortType.values[sortValue];
  }

  OrderType get orderType {
    return OrderType.values[orderValue];
  }

  List<SortModel> get sortList {
    return [
      SortModel(text: "İsim", index: SortType.Name.index),
      SortModel(text: "Eklenme Tarihi", index: SortType.DateAdded.index),
      SortModel(text: "Albüm", index: SortType.Album.index),
      SortModel(text: "Sanatçı", index: SortType.Artist.index),
      SortModel(text: "Süre", index: SortType.Time.index),
    ];
  }

  List<SortModel> get orderList {
    return [
      SortModel(text: "Artan", index: OrderType.Growing.index),
      SortModel(text: "Azalan", index: OrderType.Descending.index),
    ];
  }

  @override
  void initState() {
    sortValue = widget.sortValue?.index ?? sortList.first.index;
    orderValue = widget.orderValue?.index ?? orderList.first.index;
    if (widget.sortValue == null || widget.orderValue == null) {
      widget.changeSort?.call(sortType, orderType);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.sort_rounded),
      itemBuilder: (c) {
        final menuList = <PopupMenuEntry<int>>[];
        menuList.addAll(
          sortList
              .map(
                (e) => PopupMenuItem<int>(
                  value: e.index,
                  child: Row(
                    children: [
                      if (sortValue == e.index)
                        Icon(
                          Icons.check_rounded,
                          color: Const.contrainsColor,
                        )
                      else
                        const SizedBox(),
                      const SizedBox(width: 10),
                      Text(
                        e.text,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
        if (widget.isDownload) {
          menuList.add(
            PopupMenuItem<int>(
              value: SortType.DownloadTime.index,
              child: Row(
                children: [
                  if (sortValue == SortType.DownloadTime.index)
                    Icon(
                      Icons.check_rounded,
                      color: Const.contrainsColor,
                    )
                  else
                    const SizedBox(),
                  const SizedBox(width: 10),
                  Text(
                    "İndirme Tarihi",
                  ),
                ],
              ),
            ),
          );
        }
        menuList.add(
          MyPopupMenuDivider(
            height: 6,
            tickness: 6,
            color: Const.contrainsColor.withOpacity(0.1),
          ),
        );
        menuList.addAll(
          orderList
              .map(
                (e) => PopupMenuItem<int>(
                  value: e.index,
                  child: Row(
                    children: [
                      if (orderValue == e.index)
                        Icon(
                          Icons.check_rounded,
                          color: Const.contrainsColor,
                        )
                      else
                        const SizedBox(),
                      const SizedBox(width: 10),
                      Text(
                        e.text,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
        return menuList;
      },
      onSelected: (i) {
        if (i < 6) {
          sortValue = i;
        } else {
          orderValue = i;
        }

        widget.changeSort?.call(sortType, orderType);
      },
    );
  }

  Row popupChild(String text, IconData? icon) {
    return Row(
      children: [
        if (icon != null) Icon(icon),
        SizedBox(
          width: 10,
        ),
        Text(text)
      ],
    );
  }
}

class SortModel {
  String text;
  int index;
  SortModel({
    required this.text,
    required this.index,
  });
}

enum SortType {
  Name,
  DateAdded,
  Album,
  Artist,
  Time,
  DownloadTime,
}

enum OrderType {
  temp1,
  temp2,
  temp3,
  temp4,
  temp5,
  temp6,
  Descending,
  Growing,
}
