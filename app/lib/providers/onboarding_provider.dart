import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _hasSeenWelcomeKey = 'has_seen_welcome';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provider to check if onboarding has been completed
final hasSeenWelcomeProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_hasSeenWelcomeKey) ?? false;
});

/// Controller for managing onboarding state
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingController(prefs);
});

class OnboardingController extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingController(this._prefs)
      : super(_prefs.getBool(_hasSeenWelcomeKey) ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_hasSeenWelcomeKey, true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _prefs.setBool(_hasSeenWelcomeKey, false);
    state = false;
  }
}
