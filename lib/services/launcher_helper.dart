import 'package:url_launcher/url_launcher.dart';

/// Central branding constants and launcher helpers for Wakshe Agrotech.
/// Houses official proprietor details, slogans, telephone, WhatsApp,
/// physical address, and Google Maps integration.
class LauncherHelper {
  // Owner & Business details
  static const String proprietor = 'प्रो. प्रा. एम एम वाक्षे';
  static const String proprietorEn = 'Prop. Prof. M. M. Wakshe';
  static const String businessRole = 'शेती अवजार व्यापारी';
  static const String businessRoleEn = 'Agricultural Tool Merchant & Blacksmith Craft';

  // Support & Contact
  static const String phone = '+918788341895';
  static const String phoneDisplay = '+918788341895';
  static const String whatsappNumber = '918788341895';
  static const String email = 'waksheagrotech@gmail.com';

  // Address & Location
  static const String addressVillage = 'वाक्षेवाडी, पोस्ट : निंबवडे';
  static const String addressTaluka = 'तालुका : आटपाडी, जिल्हा : सांगली';
  static const String addressPinState = 'पिन कोड : 415 301, महाराष्ट्र';
  static const String fullAddress =
      '$addressVillage, $addressTaluka, $addressPinState';
  static const String mapsUrl = 'https://maps.app.goo.gl/vKnLdCAzfwjZLotW8';

  // Slogans & Quotes
  static const String mainSlogan =
      'वाक्षे ॲग्रोटेक - शिवकालीन परंपरेतील लोहारांची कारागिरी';
  static const String qualityQuote =
      '"जिथे परंपरा भेटते गुणवत्तेला, तिथेच जन्मतो खरा लोहास"';
  static const String trustTagline = '✦ विश्वासाचं नाव, शेतकऱ्यांचं काम ✦';
  static const String craftsmanshipMotto = 'स्वच्छ धार, उत्तम तोल';
  static const String traditionNotice =
      'राजस्थानी लोहारांनी घडवलेली पारंपरिक शेती अवजारे • Rajasthan Handcrafted';

  /// Flag to enable/disable external OS intents (useful in automated test environments)
  static bool enableLauncher = true;

  /// Optional test hook invoked with the target [Uri] before launching.
  static void Function(Uri uri)? onLaunchAttempt;

  static Future<bool> _launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    onLaunchAttempt?.call(uri);
    if (!enableLauncher) return true;
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return await launchUrl(uri, mode: mode);
    } catch (_) {}
    return false;
  }

  /// Launch direct phone dialer for customer support.
  static Future<bool> callSupport() async {
    return _launch(Uri.parse('tel:$phone'));
  }

  /// Launch email client for customer support.
  static Future<bool> openEmail([String? subject, String? body]) async {
    final sub = Uri.encodeComponent(subject ?? 'Wakshe Agrotech Inquiry / चौकशी');
    final b = Uri.encodeComponent(body ?? '');
    return _launch(Uri.parse('mailto:$email?subject=$sub&body=$b'));
  }

  /// Launch WhatsApp chat with pre-filled message.
  static Future<bool> openWhatsApp([String? message]) async {
    final defaultMsg =
        'नमस्कार, मला वाक्षे ॲग्रोटेक ($proprietor) शेती अवजारांबद्दल माहिती हवी आहे.';
    final text = Uri.encodeComponent(message ?? defaultMsg);
    return _launch(
      Uri.parse('https://wa.me/$whatsappNumber?text=$text'),
      mode: LaunchMode.externalApplication,
    );
  }

  /// Open Google Maps location in external browser or Maps application.
  static Future<bool> openMap() async {
    return _launch(
      Uri.parse(mapsUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
