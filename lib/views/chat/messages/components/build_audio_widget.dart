import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onlinemusic/util/const.dart';

class BuildAudioWidget extends StatefulWidget {
  final List<PlatformFile>? audios;
  final Size? size;
  final ValueChanged<int>? onPressedDeleteButton;
  BuildAudioWidget(
      {Key? key, this.audios, this.size, this.onPressedDeleteButton})
      : super(key: key);

  @override
  _BuildAudioWidgetState createState() => _BuildAudioWidgetState();
}

class _BuildAudioWidgetState extends State<BuildAudioWidget> {
  AudioPlayer? _player;
  double millisecond = 0;
  bool sliderScroll = false;
  double scrollSliderValue = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    loadData();
  }

  void loadData() async {
    if (widget.audios!.isNotEmpty) {
      Duration? dur = await _player!.setFilePath(widget.audios![0].path!);
      setState(() {
        millisecond = dur!.inMilliseconds.toDouble();
      });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    super.dispose();
  }

  bool get isPlaying {
    if (_player != null) {
      return _player!.playerState.playing;
    } else
      return false;
  }

  @override
  void didUpdateWidget(BuildAudioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audios != oldWidget.audios && widget.audios!.isNotEmpty) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: widget.size?.width ?? 250,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: widget.audios!.isEmpty
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildButton(
                  onPressed: () {
                    if (_player != null) {
                      if (isPlaying) {
                        _player!.pause();
                      } else {
                        _player!.play();
                      }
                    }
                    setState(() {});
                  },
                  icon: isPlaying
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            widget.audios![0].name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Const.contrainsColor,
                            ),
                          ),
                        ),
                        StreamBuilder<Duration>(
                            stream: _player!.positionStream,
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  if (widget.onPressedDeleteButton != null)
                                    StreamBuilder<Duration>(
                                      stream: _player!.positionStream,
                                      initialData: Duration.zero,
                                      builder: (context, snapshot) {
                                        return Text(
                                          sliderScroll
                                              ? Const.getDurationString(
                                                  Duration(
                                                    milliseconds:
                                                        scrollSliderValue
                                                            .toInt(),
                                                  ),
                                                )
                                              : Const.getDurationString(
                                                  snapshot.data!),
                                        );
                                      },
                                    ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 16,
                                        ),
                                        thumbShape: RoundSliderThumbShape(
                                          disabledThumbRadius: 10,
                                          enabledThumbRadius: 8,
                                        ),
                                      ),
                                      child: Slider(
                                        min: 0,
                                        max: millisecond,
                                        value: sliderScroll
                                            ? scrollSliderValue
                                            : snapshot.hasData
                                                ? (snapshot.data!.inMilliseconds
                                                            .toDouble() >=
                                                        millisecond
                                                    ? millisecond
                                                    : snapshot
                                                        .data!.inMilliseconds
                                                        .toDouble())
                                                : 0,
                                        activeColor: Const.contrainsColor,
                                        inactiveColor: Const.contrainsColor
                                            .withOpacity(0.1),
                                        onChanged: (i) {
                                          setState(() {
                                            scrollSliderValue = i;
                                          });
                                        },
                                        onChangeStart: (d) {
                                          setState(() {
                                            sliderScroll = true;
                                          });
                                        },
                                        onChangeEnd: (e) async {
                                          setState(() {
                                            sliderScroll = false;
                                          });
                                          await _player!.seek(Duration(
                                              milliseconds: e.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  if (_player!.duration != null)
                                    Text(
                                      Const.getDurationString(
                                        _player!.duration!,
                                      ),
                                      style: TextStyle(
                                        color: Const.contrainsColor,
                                      ),
                                    ),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                if (widget.onPressedDeleteButton != null)
                  buildButton(
                    icon: Icons.delete_outline_rounded,
                    onPressed: () => widget.onPressedDeleteButton!(0),
                  ),
              ],
            ),
    );
  }

  Container buildButton({VoidCallback? onPressed, IconData? icon}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Const.contrainsColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          splashRadius: 20,
          splashColor: Const.contrainsColor.withOpacity(0.5),
          icon: Icon(icon, color: Const.contrainsColor),
        ),
      ),
    );
  }
}
