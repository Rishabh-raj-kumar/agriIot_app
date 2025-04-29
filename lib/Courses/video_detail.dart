import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import './model.dart';

class VideoDetailPage extends StatefulWidget {
  final Video video;

  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  VoidCallback? _controllerListener;

  bool _areControlsVisible = false;
  Timer? _hideTimer;
  final Duration _controlsHideDuration = const Duration(seconds: 3);

  bool _isFullScreen = false;
  bool _isVideoFinished = false;

  @override
  void initState() {
    super.initState();
    _resetSystemUI();

    _controller = VideoPlayerController.asset(widget.video.videoAssetPath)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          _isPlaying = true; // Start playing when initialized
          _isVideoFinished = false;
          _areControlsVisible = false;
        });

        _controller.play(); // Play video on first open

        _controllerListener = () {
          if (!mounted) return;
          final controllerValue = _controller.value;
          final newIsPlaying = controllerValue.isPlaying;
          bool shouldSetState = false;

          if (_isPlaying != newIsPlaying) {
            _isPlaying = newIsPlaying;
            shouldSetState = true;

            if (_isPlaying) {
              _checkStartHideTimer();
              if (_isVideoFinished) {
                _isVideoFinished = false;
              }
            } else {
              if (!_isVideoFinished) {
                _areControlsVisible = true;
              }
              _cancelHideTimer();
            }
          }

          final isFinished = controllerValue.position >=
                  (controllerValue.duration -
                      const Duration(milliseconds: 100)) &&
              controllerValue.duration > Duration.zero;

          if (isFinished && !_isVideoFinished) {
            setState(() {
              _isVideoFinished = true;
              _isPlaying = false;
              _areControlsVisible = true;
            });
            _controller.pause();
            _controller.seekTo(Duration.zero);
            _cancelHideTimer();
            shouldSetState = false;
          } else if (!isFinished && _isVideoFinished) {
            _isVideoFinished = false;
            shouldSetState = true;
          }

          if (shouldSetState) {
            setState(() {});
          }
        };
        _controller.addListener(_controllerListener!);
      }).catchError((error) {
        if (!mounted) return;
        print("Error initializing video player: $error");
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: ${error.toString()}')),
        );
      });
  }

  void _toggleControlsVisibility() {
    if (!mounted || !_isInitialized) return;
    setState(() {
      _areControlsVisible = !_areControlsVisible;
    });
    if (_areControlsVisible) {
      _checkStartHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _checkStartHideTimer() {
    _cancelHideTimer();
    if (_areControlsVisible &&
        _controller.value.isPlaying &&
        !_isVideoFinished) {
      _hideTimer = Timer(_controlsHideDuration, () {
        if (!mounted || !_controller.value.isPlaying) return;
        setState(() {
          _areControlsVisible = false;
        });
      });
    }
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _handlePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      setState(() {
        _areControlsVisible = true;
      });
      if (_isVideoFinished) {
        _controller.seekTo(Duration.zero).then((_) {
          if (mounted) {
            _controller.play();
            _checkStartHideTimer();
          }
        });
      } else {
        _controller.play();
        _checkStartHideTimer();
      }
    }
  }

  void _seekBackward(Duration duration) {
    if (!_isInitialized) return;
    final newPosition = _controller.value.position - duration;
    _controller.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    setState(() {
      _areControlsVisible = true;
    });
    _checkStartHideTimer();
  }

  void _seekForward(Duration duration) {
    if (!_isInitialized) return;
    final newPosition = _controller.value.position + duration;
    final videoDuration = _controller.value.duration;
    _controller
        .seekTo(newPosition > videoDuration ? videoDuration : newPosition);
    setState(() {
      _areControlsVisible = true;
    });
    _checkStartHideTimer();
  }

  void _resetSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _toggleFullScreen() async {
    if (!_isInitialized || !mounted) return;

    final targetFullScreen = !_isFullScreen;

    _areControlsVisible = true;
    _cancelHideTimer();

    setState(() {
      _isFullScreen = targetFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
            overlays: []);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
        _checkStartHideTimer();
      } else {
        _resetSystemUI();
        _checkStartHideTimer();
      }
    });
  }

  @override
  void dispose() {
    _cancelHideTimer();
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    _controller.dispose();
    _resetSystemUI();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showAppBar = !_isFullScreen;

    return SafeArea(
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: Scaffold(
        backgroundColor:
            _isFullScreen ? Colors.black : theme.scaffoldBackgroundColor,
        appBar: showAppBar
            ? AppBar(
                title: Text(widget.video.title),
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              )
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Hero(
                    tag: 'video-thumbnail-${widget.video.id}',
                    child: _isInitialized
                        ? VideoPlayer(_controller)
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                  ),
                  if (_isInitialized)
                    GestureDetector(
                      onTap: _toggleControlsVisibility,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                  if (_isInitialized)
                    AnimatedOpacity(
                      opacity: _areControlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_areControlsVisible,
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                Colors.transparent,
                                Colors.black26,
                                Colors.black54
                              ],
                                  stops: [
                                0.5,
                                0.8,
                                1.0
                              ])),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_isFullScreen)
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios_new,
                                          size: 24),
                                      color: Colors.white,
                                      onPressed: _toggleFullScreen,
                                      tooltip: 'Exit Fullscreen',
                                    ),
                                  ),
                                ),
                              if (!_isFullScreen) const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.replay_10, size: 35),
                                    color: Colors.white,
                                    onPressed: () => _seekBackward(
                                        const Duration(seconds: 10)),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 60,
                                    ),
                                    color: Colors.white,
                                    onPressed: _handlePlayPause,
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.forward_10, size: 35),
                                    color: Colors.white,
                                    onPressed: () => _seekForward(
                                        const Duration(seconds: 10)),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 0),
                                    colors: VideoProgressColors(
                                      playedColor:
                                          theme.primaryColor.withOpacity(0.8),
                                      bufferedColor: Colors.white54,
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 8.0,
                                        top: 4.0,
                                        bottom: 8.0),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder(
                                          valueListenable: _controller,
                                          builder: (context, value, child) {
                                            return Text(
                                              '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            );
                                          },
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(
                                              _isFullScreen
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen,
                                              size: 28),
                                          color: Colors.white,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: _toggleFullScreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_isInitialized &&
                      _controller.value.isBuffering &&
                      !_isVideoFinished)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                ],
              ),
            ),
            if (!_isFullScreen)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.video.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.video.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    duration = duration.isNegative ? Duration.zero : duration;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
