import 'package:url_launcher/url_launcher.dart';

/// Central branding constants and launcher helpers for Wakshe Agrotech.
/// Houses official proprietor details, slogans, telephone, WhatsApp,
/// physical address, and Google Maps integration.
class LauncherHelper {
  // Owner & Business details
  static const String proprietor = 'प्रो. प्रा. सौ. माया मोहन वाक्षे';
  static const String proprietorEn = 'Prof. Mrs. Maya Mohan Wakshe';
  static const String businessRole = 'शेती अवजार व्यापारी';
  static const String businessRoleEn = 'Agricultural Tool Merchant & Blacksmith Craft';

  // Support & Contact
  static const String phone = '+918788341895';
  static const String phoneDisplay = '87 88 34 18 95';
  static const String whatsappNumber = '918788341895';

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

  /// Launch direct phone dialer for customer support.
  static Future<bool> callSupport() async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Launch WhatsApp chat with pre-filled message.
  static Future<bool> openWhatsApp([String? message]) async {
    final defaultMsg =
        'नमस्कार, मला वाक्षे ॲग्रोटेक (प्रो. माया वाक्षे) शेती अवजारांबद्दल माहिती हवी आहे.';
    final text = Uri.encodeComponent(message ?? defaultMsg);
    final uri = Uri.parse('https://wa.me/$whatsappNumber?text=$text');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open Google Maps location in external browser or Maps application.
  static Future<bool> openMap() async {
    final uri = Uri.parse(mapsUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
