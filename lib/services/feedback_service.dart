import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<bool> get _soundEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  Future<bool> get _vibrationEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_enabled') ?? true;
  }

  Future<void> vibrate() async {
    if (await _vibrationEnabled && await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> vibrateSuccess() async {
    if (await _vibrationEnabled && await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 50, 50, 50]);
    }
  }

  Future<void> vibrateError() async {
    if (await _vibrationEnabled && await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100]);
    }
  }

  Future<void> playClick() async {
    if (await _soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
    }
  }

  Future<void> playSuccess() async {
    if (await _soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    }
  }

  Future<void> playError() async {
    if (await _soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  Future<void> playScan() async {
    if (await _soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/scan.mp3'));
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
