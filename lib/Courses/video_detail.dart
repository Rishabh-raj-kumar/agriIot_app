import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import './model.dart'; // Assuming models.dart is the correct path

// --- Video Model (Example definition) ---
// class Video {
//   final String id;
//   final String title;
//   final String description;
//   final String videoAssetPath;
//   Video({ required this.id, required this.title, required this.description, required this.videoAssetPath });
// }
// --- End Example Model ---

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

  // --- Control visibility state ---
  // Start with controls hidden
  bool _areControlsVisible = false;
  Timer? _hideTimer;
  final Duration _controlsHideDuration = const Duration(seconds: 3);

  bool _isFullScreen = false;
  // Track if the video has finished playing
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
          _isPlaying = _controller.value.isPlaying; // Should be false initially
          _isVideoFinished = false;
          // Don't show controls initially, user must tap
          _areControlsVisible = false;
        });

        _controllerListener = () {
          if (!mounted) return;
          final controllerValue = _controller.value;
          final newIsPlaying = controllerValue.isPlaying;
          bool shouldSetState = false;

          if (_isPlaying != newIsPlaying) {
            _isPlaying = newIsPlaying;
            shouldSetState = true; // Update state if playing status changes

            if (_isPlaying) {
              // If video starts playing (e.g. after buffering), restart hide timer
              // only if controls are already visible
              _checkStartHideTimer();
              // If playing starts, video is not finished
              if (_isVideoFinished) {
                _isVideoFinished = false;
                // If controls were forced visible at the end, hide them again if playing restarts
                // However, user interaction (play button) already handles this.
                // Let's rely on tap/interaction to show controls.
              }
            } else {
              // If video pauses, show controls and cancel timer
              if (!_isVideoFinished) {
                // Don't force controls visible again if we just finished
                _areControlsVisible = true;
              }
              _cancelHideTimer();
            }
          }

          // Check for video end
          // Use a small buffer to prevent triggering slightly before the actual end
          final isFinished = controllerValue.position >=
                  (controllerValue.duration -
                      const Duration(milliseconds: 100)) &&
              controllerValue.duration > Duration.zero;

          if (isFinished && !_isVideoFinished) {
            setState(() {
              // Use setState directly here as we modify _areControlsVisible too
              _isVideoFinished = true;
              _isPlaying = false; // Explicitly set isPlaying false
              _areControlsVisible = true; // Show controls at the end
            });
            _controller.pause(); // Ensure paused state
            _controller.seekTo(Duration.zero); // Seek to beginning
            _cancelHideTimer(); // Keep controls visible
            shouldSetState = false; // Already called setState
          } else if (!isFinished && _isVideoFinished) {
            // Reset finished state if user seeks back
            _isVideoFinished = false;
            shouldSetState = true;
          }

          if (shouldSetState) {
            setState(() {}); // General state update if needed
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

  // --- Control Visibility Logic ---

  // Call this when user taps the video area
  void _toggleControlsVisibility() {
    if (!mounted || !_isInitialized) return;
    setState(() {
      _areControlsVisible = !_areControlsVisible;
    });
    if (_areControlsVisible) {
      _checkStartHideTimer(); // If showing, check if timer should start
    } else {
      _cancelHideTimer(); // If hiding, cancel timer
    }
  }

  // Call this to potentially start the hide timer
  void _checkStartHideTimer() {
    _cancelHideTimer(); // Always cancel previous timer first
    // Only start timer if controls are visible AND video is playing AND not finished
    if (_areControlsVisible &&
        _controller.value.isPlaying &&
        !_isVideoFinished) {
      _hideTimer = Timer(_controlsHideDuration, () {
        if (!mounted || !_controller.value.isPlaying)
          return; // Check again before hiding
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

  // --- Play/Pause/Seek Interaction ---

  void _handlePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      // Pause keeps controls visible, cancels timer (handled by listener)
    } else {
      setState(() {
        _areControlsVisible = true;
      }); // Show controls on interaction
      // If finished, restart from beginning
      if (_isVideoFinished) {
        _controller.seekTo(Duration.zero).then((_) {
          // Only play after seek is complete if it was finished
          if (mounted) {
            _controller.play();
            _checkStartHideTimer(); // Start timer after play
          }
        });
      } else {
        _controller.play();
        _checkStartHideTimer(); // Start timer after play
      }
    }
  }

  void _seekBackward(Duration duration) {
    if (!_isInitialized) return;
    final newPosition = _controller.value.position - duration;
    _controller.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    setState(() {
      _areControlsVisible = true;
    }); // Show controls on interaction
    _checkStartHideTimer(); // Check if timer should start/restart
  }

  void _seekForward(Duration duration) {
    if (!_isInitialized) return;
    final newPosition = _controller.value.position + duration;
    final videoDuration = _controller.value.duration;
    _controller
        .seekTo(newPosition > videoDuration ? videoDuration : newPosition);
    setState(() {
      _areControlsVisible = true;
    }); // Show controls on interaction
    _checkStartHideTimer(); // Check if timer should start/restart
  }

  // --- Fullscreen and Dispose ---
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

    // Decide target fullscreen state before async calls
    final targetFullScreen = !_isFullScreen;

    // Always ensure controls are visible when toggling screen mode
    _areControlsVisible = true;
    _cancelHideTimer(); // Cancel timer when changing modes

    setState(() {
      _isFullScreen = targetFullScreen; // Update state immediately for UI build
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
            overlays: []);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
        // Keep controls visible in fullscreen until interaction or timer (if playing)
        _checkStartHideTimer(); // Start timer if playing in new fullscreen mode
      } else {
        _resetSystemUI();
        // Keep controls visible briefly after exiting fullscreen
        _checkStartHideTimer(); // Start timer if playing after exiting fullscreen
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

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showAppBar = !_isFullScreen;

    // FIX 1: Wrap the main Column in SafeArea
    return SafeArea(
      // Apply SafeArea only when not in fullscreen for typical use cases
      // In fullscreen, we usually want edge-to-edge.
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: Scaffold(
        // Prevent Scaffold background from interfering with SafeArea
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
            // --- Video Player Area ---
            AspectRatio(
              aspectRatio: _controller.value.isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Video Player
                  Hero(
                    tag: 'video-thumbnail-${widget.video.id}',
                    child: _isInitialized
                        ? VideoPlayer(_controller)
                        : Container(
                            // Placeholder ONLY when not initialized
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                  ),

                  // Gesture Detector to toggle controls
                  // Only detect taps if initialized
                  if (_isInitialized)
                    GestureDetector(
                      onTap: _toggleControlsVisibility,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),

                  // Video Controls Overlay
                  // Only build if initialized
                  if (_isInitialized)
                    AnimatedOpacity(
                      opacity: _areControlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      // Ignore pointer events when hidden
                      child: IgnorePointer(
                        ignoring: !_areControlsVisible,
                        child: Container(
                          decoration: const BoxDecoration(
                              // Gradient background for controls
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
                              // Top controls (e.g., back button in fullscreen)
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

                              // Center Controls Row
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
                                      // Use _isPlaying state
                                      _isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 60,
                                    ),
                                    color: Colors.white,
                                    // Use the handler function
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

                              // Bottom Controls Row
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
                                          // Update time text efficiently
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

                  // FIX 2: Buffering Indicator - show ONLY when buffering AND NOT finished
                  // Make sure _isInitialized is true before accessing controller value
                  if (_isInitialized &&
                      _controller.value.isBuffering &&
                      !_isVideoFinished)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                ],
              ),
            ),

            // --- Description Area (Conditional) ---
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

  // Helper function to format Duration
  String _formatDuration(Duration duration) {
    // Clamp duration to avoid negative values if controller position is slightly off
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
