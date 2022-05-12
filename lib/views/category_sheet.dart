import 'package:flutter/material.dart';
import 'package:onlinemusic/util/const.dart';

import '../models/genre.dart';
import '../widgets/customlist.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({ Key? key }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  List<Genre>genreList=[];
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child:Column(
          children: [
             Expanded(
               child: ListView.builder(
                       itemCount: Const.genres.length,
                       itemBuilder: ((context, index){
             
                       return CustomSwitchListTile​(
                         title:Text( Const.genres[index].name) ,
                         onChanged: (bool value) { 
                           if(value==true){
                             setState(() {
               
                             genreList.add(Const.genres[index]);
             });
                           }else{
                             setState(() {
                              genreList.remove(Const.genres[index]);
});
                           }
             
                        }, value: Const.genres.any((element) =>element.id==Const.genres[index].id
                        ));
                     })),
             ),
             SizedBox(height: 10,),
             MaterialButton(
               minWidth: 80,
               height: 40,
               onPressed: (){
Navigator.pop(context);
             },child: Text("Kaydet"),)
          ],
        )
      )
    );
  }
}