import'package:flutter/material.dart'​; 
  
import 'switcher_button.dart';
  
 ​class​ ​CustomSwitchListTile​ ​extends​ ​StatefulWidget​ { 
 ​  ​const​ ​CustomSwitchListTile​({ 
 ​    ​Key​?​ key, 
 ​    ​required​ ​this​.value, 
 ​    ​required​ ​this​.onChanged, 
 ​    ​this​.tileColor, 
 ​    ​this​.activeColor, 
 ​    ​this​.activeTrackColor, 
 ​    ​this​.inactiveThumbColor, 
 ​    ​this​.inactiveTrackColor, 
 ​    ​this​.activeThumbImage, 
 ​    ​this​.inactiveThumbImage, 
 ​    ​this​.title, 
 ​    ​this​.subtitle, 
 ​    ​this​.isThreeLine ​=​ ​false​, 
 ​    ​this​.dense, 
 ​    ​this​.contentPadding, 
 ​    ​this​.secondary, 
 ​    ​this​.selected ​=​ ​false​, 
 ​    ​this​.autofocus ​=​ ​false​, 
 ​    ​this​.controlAffinity ​=​ ​ListTileControlAffinity​.platform, 
 ​    ​this​.shape, 
 ​    ​this​.selectedTileColor, 
 ​    ​this​.visualDensity, 
 ​    ​this​.focusNode, 
 ​    ​this​.enableFeedback, 
 ​    ​this​.hoverColor, 
 ​  }):​ ​assert​(value ​!=​ ​null​), 
 ​        ​assert​(isThreeLine ​!=​ ​null​), 
 ​        ​assert​(​!​isThreeLine ​||​ subtitle ​!=​ ​null​), 
 ​        ​assert​(selected ​!=​ ​null​), 
 ​        ​assert​(autofocus ​!=​ ​null​), 
 ​        ​super​(key​:​ key); 
  
 ​  ​final​ ​bool​ value; 
  
 ​  ​final​ ​ValueChanged<​bool​>​?​ onChanged; 
  
 ​  ​final​ ​Color​?​ activeColor; 
  
 ​  ​final​ ​Color​?​ activeTrackColor; 
  
 ​  ​final​ ​Color​?​ inactiveThumbColor; 
  
 ​  ​final​ ​Color​?​ inactiveTrackColor; 
  
 ​  ​final​ ​Color​?​ tileColor; 
  
 ​  ​final​ ​ImageProvider​?​ activeThumbImage; 
  
 ​  ​final​ ​ImageProvider​?​ inactiveThumbImage; 
  
 ​  ​final​ ​Widget​?​ title; 
  
 ​  ​final​ ​Widget​?​ subtitle; 
  
 ​  ​final​ ​Widget​?​ secondary; 
  
 ​  ​final​ ​bool​ isThreeLine; 
  
 ​  ​final​ ​bool​?​ dense; 
  
 ​  ​final​ ​EdgeInsetsGeometry​?​ contentPadding; 
  
 ​  ​final​ ​bool​ selected; 
  
 ​  ​final​ ​bool​ autofocus; 
  
 ​  ​final​ ​ListTileControlAffinity​ controlAffinity; 
  
 ​  ​final​ ​ShapeBorder​?​ shape; 
  
 ​  ​final​ ​Color​?​ selectedTileColor; 
  
 ​  ​final​ ​VisualDensity​?​ visualDensity; 
  
 ​  ​final​ ​FocusNode​?​ focusNode; 
  
 ​  ​final​ ​bool​?​ enableFeedback; 
  
 ​  ​final​ ​Color​?​ hoverColor; 
  
 ​  ​@override 
 ​  ​State<​CustomSwitchListTile​>​ ​createState​() ​=>​ ​_CustomSwitchListTileState​(); 
 ​} 
  
 ​class​ ​_CustomSwitchListTileState​ ​extends​ ​State<​CustomSwitchListTile​>​ { 
 ​  ​GlobalKey<​SwitcherButtonState​>​ switcherButton ​=​ ​GlobalKey​(); 
  
 ​  ​@override 
 ​  ​Widget​ ​build​(​BuildContext​ context) { 
 ​    ​final​ ​Widget​ control ​=​ ​SwitcherButton​( 
 ​      key​:​ switcherButton, 
 ​      value​:​ widget.value, 
 ​      size​:​ ​40​, 
 ​      onChange​:​ widget.onChanged, 
 ​      onColor​:​ widget.activeColor ​??​ ​Colors​.white, 
 ​      offColor​:​ widget.inactiveThumbColor ​??​ ​Colors​.black, 
 ​    ); 
 ​    ​Widget​?​ leading, trailing; 
 ​    ​switch​ (widget.controlAffinity) { 
 ​      ​case​ ​ListTileControlAffinity​.leading​: 
 ​        leading ​=​ control; 
 ​        trailing ​=​ widget.secondary; 
 ​        ​break​; 
 ​      ​case​ ​ListTileControlAffinity​.trailing​: 
 ​      ​case​ ​ListTileControlAffinity​.platform​: 
 ​        leading ​=​ widget.secondary; 
 ​        trailing ​=​ control; 
 ​        ​break​; 
 ​    } 
  
 ​    ​return​ ​MergeSemantics​( 
 ​      child​:​ ​ListTileTheme​.​merge​( 
 ​        selectedColor​: 
 ​            widget.activeColor ​??​ ​Theme​.​of​(context).toggleableActiveColor, 
 ​        child​:​ ​ListTile​( 
 ​          leading​:​ leading, 
 ​          title​:​ widget.title, 
 ​          subtitle​:​ widget.subtitle, 
 ​          trailing​:​ trailing, 
 ​          isThreeLine​:​ widget.isThreeLine, 
 ​          dense​:​ widget.dense, 
 ​          contentPadding​:​ widget.contentPadding, 
 ​          enabled​:​ widget.onChanged ​!=​ ​null​, 
 ​          onTap​:​ widget.onChanged ​!=​ ​null 
 ​              ​?​ () { 
 ​                  ​if​ (​!​(switcherButton.currentState​?​.isAnimating ​??​ ​false​)) { 
 ​                    widget.​onChanged​!(​!​widget.value); 
 ​                  } 
 ​                } 
 ​              ​:​ ​null​, 
 ​          selected​:​ widget.selected, 
 ​          selectedTileColor​:​ widget.selectedTileColor, 
 ​          autofocus​:​ widget.autofocus, 
 ​          shape​:​ widget.shape, 
 ​          tileColor​:​ widget.tileColor, 
 ​          visualDensity​:​ widget.visualDensity, 
 ​          focusNode​:​ widget.focusNode, 
 ​          enableFeedback​:​ widget.enableFeedback, 
 ​          hoverColor​:​ widget.hoverColor, 
 ​        ), 
 ​      ), 
 ​    ); 
 ​  } 
 ​}