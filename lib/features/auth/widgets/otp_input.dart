import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String _code() => _controllers.map((c) => c.text).join();

  void _emit() {
    final code = _code();
    widget.onChanged?.call(code);
    if (!_controllers.any((c) => c.text.isEmpty)) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 10),
            child: SizedBox(
              width: 54,
              height: 52,
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3.copyWith(letterSpacing: 1),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                  ),
                ),
                onChanged: (v) {
                  if (v.isNotEmpty) {
                    HapticFeedback.selectionClick();
                    if (i < widget.length - 1) {
                      _nodes[i + 1].requestFocus();
                    } else {
                      _nodes[i].unfocus();
                    }
                  }
                  _emit();
                },
                onTapOutside: (_) => _nodes[i].unfocus(),
                onSubmitted: (_) {
                  if (i < widget.length - 1) {
                    _nodes[i + 1].requestFocus();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
