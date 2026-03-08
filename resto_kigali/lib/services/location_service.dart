import 'package:url_launcher/url_launcher.dart';

class LocationService {
  /// Open Google Maps directions to the specified location
  static Future<void> launchMapDirections({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final String mapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(mapsUrl))) {
      await launchUrl(Uri.parse(mapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map directions';
    }
  }

  /// Open location in OpenStreetMap (OSM)
  static Future<void> openLocationInMaps({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    // Use OpenStreetMap instead of Google Maps (no API key needed)
    final String osmUrl =
        'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude&zoom=15';

    if (await canLaunchUrl(Uri.parse(osmUrl))) {
      await launchUrl(Uri.parse(osmUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map';
    }
  }

  /// Call a phone number
  static Future<void> callPhoneNumber(String phoneNumber) async {
    final String tel = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(tel))) {
      await launchUrl(Uri.parse(tel));
    } else {
      throw 'Could not launch call to $phoneNumber';
    }
  }

  /// Open website URL
  static Future<void> openWebsite(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch website: $url';
    }
  }

  /// Send an email
  static Future<void> sendEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    final String emailUrl =
        'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      throw 'Could not launch email to $email';
    }
  }
}
