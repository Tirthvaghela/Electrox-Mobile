import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps any widget and shows a red banner at the top when offline.
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    // Check initial state
    Connectivity().checkConnectivity().then(_update);
    // Listen for changes
    _sub = Connectivity().onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _isOffline) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOffline ? 36 : 0,
          color: Colors.red.shade700,
          child: _isOffline
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('No internet connection',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
