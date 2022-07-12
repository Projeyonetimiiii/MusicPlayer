import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/services/download_service.dart';
import 'package:onlinemusic/util/const.dart';

class DownloadButton extends StatefulWidget {
  final MediaItem item;
  final String? icon;
  final double? size;
  const DownloadButton({
    Key? key,
    required this.item,
    this.icon,
    this.size,
  }) : super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final ValueNotifier<bool> showStopButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    startLottie = downloadService.downloadingItem?.id == widget.item.id;

    downloadService.addListener(listener);
  }

  @override
  void dispose() {
    downloadService.removeListener(listener);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DownloadButton oldWidget) {
    if (oldWidget.item.id != widget.item.id) {
      setState(() {
        startLottie = downloadService.downloadingItem?.id == widget.item.id;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void listener() {
    setState(() {});
  }

  bool startLottie = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: getButton(),
    );
  }

  Widget getButton() {
    if (downloadsBox!.containsKey(widget.item.id)) {
      startLottie = false;
      return IconButton(
        icon: const Icon(Icons.download_done_rounded),
        tooltip: 'İndirme Tamamlandı',
        color: Const.contrainsColor,
        iconSize: widget.size ?? 24.0,
        onPressed: () async {
          downloadService.prepareDownload(context, widget.item);
        },
      );
    }
    return Row(
      children: [
        if (downloadService.progress != null &&
            downloadService.downloadingItem?.id == widget.item.id)
          Text(
            "${(downloadService.progress! * 100).toInt()}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LottieWidget(
            start: startLottie,
            onTap: () async {
              startLottie = await downloadService.addQueue(
                widget.item,
                context,
                isShowMessage: true,
              );
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}

class LottieWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool start;
  const LottieWidget({
    Key? key,
    required this.onTap,
    this.start = false,
  }) : super(key: key);

  @override
  State<LottieWidget> createState() => _LottieWidgetState();
}

class _LottieWidgetState extends State<LottieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant LottieWidget oldWidget) {
    if (oldWidget.start != widget.start) {
      if (widget.start) {
        _controller.repeat();
      } else {
        _controller.reset();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LottieBuilder.asset(
        "assets/lotties/downloading.json",
        controller: _controller,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.colorFilter(["**"],
                value: ColorFilter.mode(Const.contrainsColor, BlendMode.srcIn)),
          ],
        ),
        onLoaded: (loaded) {
          // print(loaded.layers[1].solidColor);
          _controller.duration = loaded.duration;
          if (widget.start) {
            _controller.repeat();
          } else {
            _controller.reset();
          }
        },
      ),
    );
  }
}
