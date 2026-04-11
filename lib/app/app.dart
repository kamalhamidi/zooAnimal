import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

class SoundZooApp extends ConsumerStatefulWidget {
  const SoundZooApp({super.key});

  @override
  ConsumerState<SoundZooApp> createState() => _SoundZooAppState();
}

class _SoundZooAppState extends ConsumerState<SoundZooApp> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _isWifiConnected = false;

  @override
  void initState() {
    super.initState();
    _setupConnectivityMonitoring();
  }

  Future<void> _setupConnectivityMonitoring() async {
    final initialResult = await _connectivity.checkConnectivity();
    _handleConnectivityChange(initialResult);

    _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(dynamic result) {
    bool hasWifi = false;

    if (result is ConnectivityResult) {
      hasWifi = result == ConnectivityResult.wifi;
    } else if (result is List<ConnectivityResult>) {
      hasWifi = result.contains(ConnectivityResult.wifi);
    } else if (result is Iterable) {
      hasWifi = result.contains(ConnectivityResult.wifi);
    }

    if (!mounted) return;

    setState(() {
      _isWifiConnected = hasWifi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SoundZoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (!_isWifiConnected)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Wi-Fi Required',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'This game needs Wi-Fi connection to play and enjoy your zoo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: () async {
                                final result =
                                    await _connectivity.checkConnectivity();
                                _handleConnectivityChange(result);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
