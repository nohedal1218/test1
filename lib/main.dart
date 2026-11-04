import 'package:flutter/material.dart';

import 'data/profile_repository.dart';
import 'models/player_profile.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TechQuestApp());
}

class TechQuestApp extends StatelessWidget {
  const TechQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TECH QUEST',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  final ProfileRepository _repository = ProfileRepository();
  PlayerProfile? _profile;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _repository.loadProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNewProfile(PlayerProfile profile) async {
    await _repository.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  Future<void> _updateProfile(PlayerProfile profile) async {
    await _repository.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  Future<void> _resetProfile() async {
    await _repository.clearProfile();
    if (!mounted) return;
    setState(() => _profile = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded, size: 42),
                const SizedBox(height: 12),
                const Text('사용자 정보를 불러오지 못했어요.'),
                const SizedBox(height: 6),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _loadProfile,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return SetupScreen(onCompleted: _saveNewProfile);
    }

    return HomeScreen(
      profile: profile,
      onProfileUpdated: _updateProfile,
      onResetProfile: _resetProfile,
    );
  }
}
