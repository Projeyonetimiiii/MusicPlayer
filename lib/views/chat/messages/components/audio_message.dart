import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/views/chat/models/chat_message.dart';
import 'package:provider/provider.dart';

class AudioMessage extends StatefulWidget {
  final ChatMessage? message;

  const AudioMessage({Key? key, this.message}) : super(key: key);

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  late AudioPlayer _player;
  double millisecond = 0;
  bool sliderScroll = false;
  double scrollSliderValue = 0;
  StreamSubscription<PlaybackEvent>? eventStream;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    initPlayer();
  }

  @override
  void didUpdateWidget(AudioMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    eventStream?.cancel();
    listenPlayer();
  }

  initPlayer() async {
    try {
      Duration? dur = await _player.setAudioSource(
        AudioSource.uri(Uri.parse(widget.message!.audio!.downloadURL!)),
      );
      if (mounted)
        setState(() {
          millisecond = dur!.inMilliseconds.toDouble();
        });
      listenPlayer();
    } on Exception catch (e) {
      // TODO
    }
  }

  listenPlayer() {
    eventStream = _player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        print("bitti");
        try {
          if (mounted)
            setState(() {
              sliderScroll = true;
              scrollSliderValue = 0;
            });
        } catch (e) {}
      }
    });
  }

  @override
  void dispose() {
    eventStream?.cancel();
    _player.dispose();
    super.dispose();
  }

  bool get isPlaying => _player.playing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.4),
                  ),
                  child: Center(
                    child: Icon(Icons.audiotrack_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onLongPress: () {},
                    borderRadius: BorderRadius.circular(90),
                    onTap: () {
                      try {
                        if (isPlaying) {
                          _player.pause();
                        } else {
                          _player.play();
                        }
                        if (mounted)
                          setState(() {
                            sliderScroll = false;
                          });
                      } catch (e) {}
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<Duration>(
                      initialData: Duration.zero,
                      stream: _player.positionStream,
                      builder: (context, pos) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: SliderTheme(
                            data: SliderThemeData(
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 13),
                              thumbShape: RoundSliderThumbShape(
                                disabledThumbRadius: 12,
                                enabledThumbRadius: 7,
                              ),
                            ),
                            child: Slider(
                              value: getValue(pos)!,
                              max: millisecond,
                              min: 0,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white,
                              onChanged: (i) {
                                if (mounted)
                                  setState(() {
                                    scrollSliderValue = i;
                                  });
                              },
                              onChangeStart: (i) {
                                if (mounted)
                                  setState(() {
                                    sliderScroll = true;
                                  });
                              },
                              onChangeEnd: (d) {
                                if (mounted)
                                  setState(() {
                                    sliderScroll = false;
                                  });
                                _player.seek(Duration(milliseconds: d.toInt()));
                              },
                            ),
                          ),
                        );
                      }),
                ),
                // Text(
                //   "0.37",
                //   style: TextStyle(
                //       fontSize: 12, color: message.senderUid.isEmpty ? Colors.white : null),
                // ),
              ],
            ),
          ),
          Positioned(
            bottom: 1,
            right: 3,
            child: Text(
              getDuration(sliderScroll ? scrollSliderValue : millisecond),
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  double? getValue(AsyncSnapshot<Duration> snapshot) {
    return sliderScroll
        ? scrollSliderValue
        : snapshot.hasData
            ? (snapshot.data!.inMilliseconds.toDouble() >= millisecond
                ? millisecond
                : snapshot.data!.inMilliseconds.toDouble())
            : 0;
  }

  String getDuration(double millis) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(millis.toInt());
    int second = (time.second % 60);
    int minute = (time.minute % 60);
    return (minute < 10 ? "0" + minute.toString() : minute).toString() +
        ":" +
        ((second < 10 ? "0" + second.toString() : second)).toString();
  }
}
