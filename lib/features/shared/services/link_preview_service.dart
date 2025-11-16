import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching link previews via API
/// Supports linkpreview.net and linkpreview.io
class LinkPreviewService {
  // TODO: Replace with your API key from linkpreview.net or linkpreview.io
  // Option 1: Hardcode for development (NOT for production)
  static const String _apiKey = 'a7967192ca4afcc12216985ca352559f';
  
  // Option 2: Use environment variables (better security)
  // Load from .env file using flutter_dotenv package
  
  /// Fetch link preview data
  /// Returns a map with 'title', 'description', 'imageUrl', and 'domain'
  Future<Map<String, String?>> fetchPreview(String url) async {
    try {
      // Using linkpreview.net API (free tier available)
      final response = await http.get(
        Uri.parse('https://api.linkpreview.net/?key=$_apiKey&q=$url'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'imageUrl': data['image'],
          'domain': _extractDomain(url),
        };
      } else {
        // Fallback to basic data extraction
        return _fallbackPreview(url);
      }
    } catch (e) {
      // Fallback on error
      return _fallbackPreview(url);
    }
  }

  /// Extract domain from URL
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return '';
    }
  }

  /// Fallback preview when API fails
  Map<String, String?> _fallbackPreview(String url) {
    return {
      'title': _extractDomain(url),
      'description': url,
      'imageUrl': null,
      'domain': _extractDomain(url),
    };
  }

  /// Validate URL format
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Add http:// prefix if missing
  String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
}
