part of '../../../dash_chat_2.dart';

/// @nodoc
class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    required this.url,
    this.aspectRatio = 1,
    this.canPlay = true,
    this.containerColor,
    this.alignmentPlaying,
    this.alignmentPaused,
    Key? key,
  }) : super(key: key);

  /// Link of the video
  final String url;
  final Color? containerColor;

  /// The Aspect Ratio of the Video. Important to get the correct size of the video
  final double aspectRatio;

  /// If the video can be played
  final bool canPlay;

  /// Alignment for play/pause button when video is playing
  final AlignmentGeometry? alignmentPlaying;

  /// Alignment for play/pause button when video is paused
  final AlignmentGeometry? alignmentPaused;

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  late vp.VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = vp.VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Container(
            color: widget.containerColor ?? Colors.black,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                alignment: _controller.value.isPlaying
                    ? (widget.alignmentPlaying ??
                        AlignmentDirectional.bottomStart)
                    : (widget.alignmentPaused ?? AlignmentDirectional.center),
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: vp.VideoPlayer(_controller),
                  ),
                  IconButton(
                    iconSize: _controller.value.isPlaying ? 24 : 60,
                    onPressed: widget.canPlay
                        ? () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          }
                        : null,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(color: widget.containerColor ?? Colors.black);
  }
}
