import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AudioRecordingBar extends StatefulWidget {
  final Function(int durationSeconds) onSaveRecording;
  final VoidCallback onCancel;

  const AudioRecordingBar({
    super.key,
    required this.onSaveRecording,
    required this.onCancel,
  });

  @override
  State<AudioRecordingBar> createState() => _AudioRecordingBarState();
}

class _AudioRecordingBarState extends State<AudioRecordingBar> with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String get _timeString {
    final mins = _seconds ~/ 60;
    final secs = _seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5B7B7), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14FF0000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing red indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.4 + (_pulseController.value * 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: _pulseController.value * 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),

          // Timer
          Text(
            _timeString,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(width: 12),

          // Animated Sound Waves
          Expanded(
            child: SizedBox(
              height: 24,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(12, (index) {
                      final waveVal = ((index * 0.15 + _waveController.value) % 1.0);
                      final height = 6.0 + (waveVal * 16.0);
                      return Container(
                        width: 3,
                        height: height,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.6 + (waveVal * 0.4)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Cancel Button
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 22),
            tooltip: 'Hủy ghi âm',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 6),

          // Save Button
          InkWell(
            onTap: () {
              final finalSeconds = _seconds == 0 ? 1 : _seconds;
              widget.onSaveRecording(finalSeconds);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Lưu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMemoPlayer extends StatefulWidget {
  final int durationSeconds;
  final String? title;
  final VoidCallback onDelete;

  const AudioMemoPlayer({
    super.key,
    required this.durationSeconds,
    this.title,
    required this.onDelete,
  });

  @override
  State<AudioMemoPlayer> createState() => _AudioMemoPlayerState();
}

class _AudioMemoPlayerState extends State<AudioMemoPlayer> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _currentSeconds = 0;
  Timer? _playbackTimer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _animController.repeat(reverse: true);
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _currentSeconds++;
          if (_currentSeconds >= widget.durationSeconds) {
            _currentSeconds = 0;
            _isPlaying = false;
            _playbackTimer?.cancel();
            _animController.stop();
          }
        });
      });
    } else {
      _animController.stop();
      _playbackTimer?.cancel();
    }
  }

  String _formatTime(int sec) {
    final mins = sec ~/ 60;
    final secs = sec % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.durationSeconds > 0
        ? (_currentSeconds / widget.durationSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          // Play / Pause Circle
          InkWell(
            onTap: _togglePlay,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content & Waveform / Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title ?? 'Bản ghi âm giọng nói',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_formatTime(_currentSeconds)} / ${_formatTime(widget.durationSeconds)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Linear Progress bar with slider feel
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Delete recording button
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.textTertiary),
            tooltip: 'Xóa bản ghi âm',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
