// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/services/connected_song_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class MiniPlayerStyle {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final BoxShadow? boxShadow;
  MiniPlayerStyle({
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    Color? backgroundColor,
    this.textColor = Const.kBackground,
    this.boxShadow,
  }) : this.backgroundColor = backgroundColor ?? Colors.grey.shade200;

  MiniPlayerStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? textColor,
    BoxShadow? boxShadow,
  }) {
    return MiniPlayerStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}

class MiniPlayer extends StatefulWidget {
  static MiniPlayerStyle sStyle = MiniPlayerStyle();

  final bool isBottomBar;
  final MiniPlayerStyle style;
  MiniPlayer({
    this.isBottomBar = false,
    MiniPlayerStyle? style,
  }) : this.style = style ?? sStyle;

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool showPlayer = false;

  MiniPlayerStyle get style => widget.style;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
        stream: handler.playbackState,
        builder: (context, snapshot) {
          final playbackState = snapshot.data;
          final processingState = playbackState?.processingState;
          if (processingState == AudioProcessingState.idle) {
            return SizedBox();
          }
          return Container(
            padding: style.padding,
            margin: style.margin,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: style.borderRadius,
              boxShadow: style.boxShadow == null
                  ? null
                  : [
                      style.boxShadow!,
                    ],
            ),
            child: StreamBuilder<MediaItem?>(
              stream: handler.mediaItem,
              builder: (context, snapshot) {
                showPlayer = snapshot.data != null;
                Widget child = getSecondWidget(snapshot.data);
                if (widget.isBottomBar) {
                  child = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      child,
                      SizedBox(
                        height: 29,
                      ),
                    ],
                  );
                }

                child = AnimatedCrossFade(
                  firstChild: SizedBox(),
                  secondChild: child,
                  crossFadeState: showPlayer
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 350),
                );

                return child;
              },
            ),
          );
        });
  }

  Widget getSecondWidget(MediaItem? song) {
    if (song == null) {
      return SizedBox();
    }
    return Dismissible(
      direction: DismissDirection.down,
      key: Key(song.id),
      confirmDismiss: (d) async {
        if (connectedSongService.isAdmin) {
          await handler.stop();
          return true;
        } else {
          return false;
        }
      },
      child: Dismissible(
        key: ValueKey(song.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (s) async {
          if (connectedSongService.isAdmin) {
            if (s == DismissDirection.startToEnd) {
              if (handler.hasPrev) {
                await handler.skipToPrevious();
              }
            } else {
              if (handler.hasNext) {
                await handler.skipToNext();
              }
            }
          }
          return Future.value(false);
        },
        child: SizedBox(
          height: 58,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                top: -3,
                left: 0,
                right: 0,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 5),
                  onTap: () {
                    context.pushOpaque(
                      PlayingScreen(),
                    );
                  },
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17,
                        color: style.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    song.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: style.textColor),
                  ),
                  leading: Hero(
                    tag: 'currentArtwork',
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 45,
                        child: AspectRatio(
                          aspectRatio: song.type.isVideo ? 16 / 9 : 1,
                          child: song.getImageWidget,
                        ),
                      ),
                    ),
                  ),
                  trailing: ControlButtons(
                    miniplayer: true,
                    textColor: style.textColor,
                    item: song,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 0,
                left: 0,
                child: StreamBuilder<Duration>(
                    stream: AudioService.position,
                    builder: (context, snapshot) {
                      final position = snapshot.data;
                      return position == null
                          ? const SizedBox()
                          : (position.inSeconds.toDouble() < 0.0 ||
                                  (position.inSeconds.toDouble() >
                                      song.duration!.inSeconds.toDouble()))
                              ? const SizedBox()
                              : SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: style.textColor,
                                    inactiveTrackColor: Colors.transparent,
                                    trackHeight: 1,
                                    thumbColor: style.textColor,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 0.0,
                                    ),
                                    overlayColor: Colors.transparent,
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 0.0,
                                    ),
                                  ),
                                  child: Slider(
                                    // activeColor: Colors.white,
                                    value: position.inSeconds.toDouble(),
                                    max: song.duration!.inSeconds.toDouble(),
                                    onChanged: (newPosition) {
                                      handler.seek(Duration(
                                          seconds: newPosition.round()));
                                    },
                                  ),
                                );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final bool shuffle;
  final bool miniplayer;
  final Color textColor;
  final MediaItem item;

  ControlButtons({
    this.shuffle = false,
    this.miniplayer = false,
    required this.item,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: miniplayer ? 40.0 : 65.0,
          width: miniplayer ? 40.0 : 65.0,
          child: StreamBuilder<PlaybackState>(
            stream: handler.playbackState,
            builder: (context, snapshot) {
              final playbackState = snapshot.data;
              final processingState = playbackState?.processingState;
              final playing = playbackState?.playing ?? false;
              return Stack(
                children: [
                  if (processingState == AudioProcessingState.loading ||
                      processingState == AudioProcessingState.buffering)
                    Center(
                      child: SizedBox(
                        height: miniplayer ? 40.0 : 65.0,
                        width: miniplayer ? 40.0 : 65.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).iconTheme.color!,
                          ),
                        ),
                      ),
                    ),
                  if (miniplayer)
                    Center(
                      child: playing
                          ? IconButton(
                              tooltip: "Durdur",
                              onPressed: handler.pause,
                              icon: const Icon(
                                Icons.pause_rounded,
                              ),
                              color: textColor,
                            )
                          : IconButton(
                              tooltip: "Oynat",
                              onPressed: handler.play,
                              icon: const Icon(Icons.play_arrow_rounded),
                              color: textColor,
                            ),
                    )
                  else
                    Center(
                      child: SizedBox(
                        height: 59,
                        width: 59,
                        child: Center(
                          child: playing
                              ? FloatingActionButton(
                                  elevation: 10,
                                  tooltip: "Durdur",
                                  backgroundColor: Colors.white,
                                  onPressed: handler.pause,
                                  child: Icon(
                                    Icons.pause_rounded,
                                    size: 40.0,
                                    color: textColor,
                                  ),
                                )
                              : FloatingActionButton(
                                  elevation: 10,
                                  tooltip: "Oynat",
                                  backgroundColor: Colors.white,
                                  onPressed: handler.play,
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 40.0,
                                    color: textColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        StreamBuilder<bool>(
            stream: context.myData.favoriteSongs
                .map((event) => event.any((element) => element.id == item.id))
                .distinct(),
            builder: (context, snapshot) {
              return IconButton(
                tooltip: "Favori",
                onPressed: () {
                  MyData data = context.myData;
                  if (snapshot.data == true) {
                    data.removeFavoritedSong(item);
                  } else {
                    data.addFavoriteSong(item);
                  }
                },
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: snapshot.data == true
                      ? const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          size: 18,
                        ),
                ),
                color: textColor,
              );
            })
      ],
    );
  }
}
