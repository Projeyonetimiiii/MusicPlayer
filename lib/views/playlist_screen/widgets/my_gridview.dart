import 'package:flutter/material.dart';

class MyGridView extends StatefulWidget {
  final List<Widget> children;
  final int axisCount;
  MyGridView({
    Key? key,
    required this.children,
    this.axisCount = 2,
  }) : super(key: key);

  @override
  _MyGridViewState createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView> {
  @override
  void didUpdateWidget(covariant MyGridView oldWidget) {
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<List<Widget>> widgets = childrenLists(
      widget.children,
    );
    Widget body;
    if (widget.children.isEmpty) {
      body = Center(
        child: Text("Burada hiçbirşey yok"),
      );
    } else {
      body = ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.axisCount; i++)
                Container(
                  width: size.width / widget.axisCount,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widgets[i],
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return body;
  }

  List<List<Widget>> childrenLists(List<Widget> children) {
    List<List<Widget>> widgets = [];

    for (int a = 0; a < widget.axisCount; a++) {
      widgets.add([]);
    }

    for (int i = 0; i < children.length; i++) {
      for (int a = 0; a < widget.axisCount; a++) {
        if (i % widget.axisCount == a) {
          widgets[a].add(children[i]);
          break;
        }
      }
    }
    return widgets;
  }

  bool isNotEmptyChildren(List<List<Widget>> fixedWidgets) {
    bool isEmpty = true;
    for (var item in fixedWidgets) {
      if (item.isNotEmpty) isEmpty = false;
    }
    return !isEmpty;
  }
}
