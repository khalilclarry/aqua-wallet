import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider.autoDispose<SharedPreferences>((_) {
  throw UnimplementedError('SharedPreferencesProvider is not implemented');
});
