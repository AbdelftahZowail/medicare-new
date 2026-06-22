import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/fcm_service.dart';

class FcmTokenDebugWidget extends StatefulWidget {
  const FcmTokenDebugWidget({super.key});

  @override
  State<FcmTokenDebugWidget> createState() => _FcmTokenDebugWidgetState();
}

class _FcmTokenDebugWidgetState extends State<FcmTokenDebugWidget> {
  String? _localToken;
  String? _storedToken;
  Timer? _timer;

  bool get _synced =>
      _localToken != null &&
      _storedToken != null &&
      _localToken == _storedToken;

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final local = await FirebaseMessaging.instance.getToken();
    final stored = await FcmService().getStoredToken();
    if (mounted) setState(() {
      _localToken = local;
      _storedToken = stored;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kEnableDebugTools) return const SizedBox.shrink();
    final color = _synced ? Colors.green : Colors.red;
    final label = _synced ? 'FCM SYNCED' : 'FCM DESYNCED';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: _check,
                child: Icon(Icons.refresh, size: 14, color: color),
              ),
            ],
          ),
        ),
        if (_localToken != null || _storedToken != null) ...[
          const SizedBox(height: 4),
          if (_localToken != null)
            Text('Local:  ${_localToken!.length > 40 ? _localToken!.substring(0, 40) : _localToken}…',
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
          if (_storedToken != null)
            Text('Stored: ${_storedToken!.length > 40 ? _storedToken!.substring(0, 40) : _storedToken}…',
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ],
    );
  }
}
