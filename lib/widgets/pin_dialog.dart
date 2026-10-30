import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PinDialogMode { verify, setup }

class PinDialog extends StatefulWidget {
  final PinDialogMode mode;
  final String title;
  final String subtitle;
  final Future<bool> Function(String pin) onVerify;
  final Function(String pin)? onSetupComplete;

  const PinDialog({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.onVerify,
    this.onSetupComplete,
  });

  static Future<bool?> showVerify({
    required BuildContext context,
    String title = 'Mở khóa ghi chú',
    String subtitle = 'Nhập mã PIN gồm 4 số để xem nội dung',
    required Future<bool> Function(String pin) onVerify,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PinDialog(
        mode: PinDialogMode.verify,
        title: title,
        subtitle: subtitle,
        onVerify: onVerify,
      ),
    );
  }

  static Future<String?> showSetup({
    required BuildContext context,
    String title = 'Thiết lập mã PIN khóa ghi chú',
    String subtitle = 'Nhập 4 số để bảo vệ các ghi chú bạn chọn',
  }) {
    String? createdPin;
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PinDialog(
        mode: PinDialogMode.setup,
        title: title,
        subtitle: subtitle,
        onVerify: (_) async => true,
        onSetupComplete: (pin) {
          createdPin = pin;
        },
      ),
    ).then((val) => createdPin);
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) async {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        if (widget.mode == PinDialogMode.setup) {
          if (!_isConfirming) {
            setState(() {
              _firstPin = _enteredPin;
              _enteredPin = '';
              _isConfirming = true;
            });
          } else {
            if (_enteredPin == _firstPin) {
              widget.onSetupComplete?.call(_enteredPin);
              Navigator.of(context).pop(true);
            } else {
              _triggerError('Mã PIN xác nhận không khớp. Vui lòng nhập lại.');
              setState(() {
                _enteredPin = '';
              });
            }
          }
        } else {
          final isCorrect = await widget.onVerify(_enteredPin);
          if (!mounted) return;
          if (isCorrect) {
            Navigator.of(context).pop(true);
          } else {
            _triggerError('Mã PIN không đúng. Vui lòng thử lại.');
            setState(() {
              _enteredPin = '';
            });
          }
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _triggerError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isConfirming ? 'Xác nhận mã PIN' : widget.title;
    final subtitle = _isConfirming ? 'Nhập lại 4 số bạn vừa tạo để xác nhận' : widget.subtitle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock Icon with subtle scale
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Shaking PIN Dots indicator
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Keypad (1 to 9, 0, Backspace)
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  for (var row = 0; row < 3; row++) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var col = 1; col <= 3; col++) ...[
                          _buildKeypadButton('${row * 3 + col}'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      _buildKeypadButton('0'),
                      // Backspace Button
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: IconButton(
                          onPressed: _onDeletePressed,
                          icon: const Icon(
                            Icons.backspace_outlined,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5F2),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _onDigitPressed(digit),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
