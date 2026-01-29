import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service to manage Supabase client initialization
class SupabaseService {
  static SupabaseClient? _client;

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Initialize Supabase with credentials from env.json
  static Future<void> initialize() async {
    final String configString = await rootBundle.loadString('env.json');
    final Map<String, dynamic> config = json.decode(configString);

    final url = config['SUPABASE_URL'] as String;
    final anonKey = config['SUPABASE_ANON_KEY'] as String;

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not found. Please update env.json with your SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}
