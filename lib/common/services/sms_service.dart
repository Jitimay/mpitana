import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static Future<void> sendSms(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}
