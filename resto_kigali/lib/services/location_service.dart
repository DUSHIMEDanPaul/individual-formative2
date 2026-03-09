import 'package:url_launcher/url_launcher.dart';

class LocationService {
  /// Open Google Maps with turn-by-turn directions to the specified location.
  /// Tries the native Google Maps app URI first, then falls back to the web URL.
  static Future<void> launchMapDirections({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    // Native Google Maps app URI (Android & iOS)
    final Uri nativeUri = Uri.parse(
        'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving');
    // Web fallback — always works in a browser
    final Uri webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open location in Google Maps (no directions)
  static Future<void> openLocationInMaps({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Call a phone number
  static Future<void> callPhoneNumber(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch call to $phoneNumber';
    }
  }

  /// Open website URL
  static Future<void> openWebsite(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Send an email
  static Future<void> sendEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    final Uri uri = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email to \$email';
    }
  }
}
