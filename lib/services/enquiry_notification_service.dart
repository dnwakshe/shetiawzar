import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for delivering automated background notifications to the admin
/// via Free Telegram Bot API and Free Email alerts when customer enquiries are placed.
class EnquiryNotificationService {
  // Flag to enable/disable HTTP dispatch in automated test environments
  static bool enableHttp = true;

  // --- Telegram Bot Configuration ---
  // To receive instant push alerts on your phone via Telegram:
  // 1. Create a bot in 30 seconds via @BotFather on Telegram to get your BOT TOKEN.
  // 2. Message @userinfobot on Telegram to get your CHAT ID.
  static String telegramBotToken = 'YOUR_TELEGRAM_BOT_TOKEN';
  static String telegramChatId = 'YOUR_TELEGRAM_CHAT_ID';

  // --- Email Alert Configuration ---
  // Default notification email address for store alerts
  static String adminEmail = 'dnwakshe@gmail.com';

  /// Sends an instant Telegram push alert to the admin's phone.
  static Future<bool> sendTelegramAlert({
    required String customerName,
    required String customerPhone,
    String? notes,
    required String itemsSummary,
    required double totalAmount,
  }) async {
    if (!enableHttp) return true;
    if (telegramBotToken.isEmpty ||
        telegramBotToken.contains('YOUR_TELEGRAM_BOT_TOKEN') ||
        telegramChatId.isEmpty ||
        telegramChatId.contains('YOUR_TELEGRAM_CHAT_ID')) {
      // Configuration placeholder active
      return false;
    }

    try {
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      final buffer = StringBuffer();
      buffer.writeln('🌾 <b>नवीन शेती अवजार चौकशी! (Wakshe Agrotech)</b>');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('👤 <b>ग्राहक:</b> $customerName');
      buffer.writeln('📱 <b>फोन:</b> <a href="tel:$customerPhone">$customerPhone</a>');
      if (notes != null && notes.trim().isNotEmpty) {
        buffer.writeln('📝 <b>गाव/पत्ता:</b> ${notes.trim()}');
      }
      buffer.writeln('🛒 <b>अवजारे:</b> $itemsSummary');
      buffer.writeln('💰 <b>एकूण रक्कम:</b> ₹${totalAmount.round()}');
      buffer.writeln('⏰ <b>वेळ:</b> $dateStr');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('<i>वाक्षे ॲग्रोटेक शेती अवजार व्यापारी</i>');

      final url = Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': telegramChatId,
          'text': buffer.toString(),
          'parse_mode': 'HTML',
          'disable_web_page_preview': true,
        }),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sends a free automated email notification to the store administrator.
  static Future<bool> sendEmailAlert({
    required String customerName,
    required String customerPhone,
    String? notes,
    required String itemsSummary,
    required double totalAmount,
  }) async {
    if (!enableHttp) return true;
    if (adminEmail.isEmpty || !adminEmail.contains('@')) return false;

    try {
      // Free FormSubmit AJAX endpoint delivering instant email to admin
      final url = Uri.parse('https://formsubmit.co/ajax/$adminEmail');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'Name': customerName,
          'Phone': customerPhone,
          'Location_Notes': notes ?? 'None',
          'Tools_Ordered': itemsSummary,
          'Total_Amount': '₹${totalAmount.round()}',
          '_subject': '🔔 नवीन शेती अवजार चौकशी: $customerName ($customerPhone)',
          '_template': 'table',
        }),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Dispatches all background admin alerts simultaneously.
  static Future<void> dispatchAllAlerts({
    required String customerName,
    required String customerPhone,
    String? notes,
    required String itemsSummary,
    required double totalAmount,
  }) async {
    // Fire-and-forget in background without blocking UI
    Future.wait([
      sendTelegramAlert(
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        itemsSummary: itemsSummary,
        totalAmount: totalAmount,
      ),
      sendEmailAlert(
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        itemsSummary: itemsSummary,
        totalAmount: totalAmount,
      ),
    ]);
  }
}
