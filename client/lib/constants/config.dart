// this is my config.dart
class Config {
  static const String userApiUrl = 'http://"YOUR_WIFI_IP_ADDRESS:8000/';
  static const String registrationUrl = "${userApiUrl}registration";
  static const String login = '${userApiUrl}login';
  static const String summarize = 'https://YOUR_NGROK_ENDPOINT_URL/text-summarizer/summarize/';
  static const String apiKey = '"YOUR_API_KEY_FROM_newsapi.org"';
  static const String getUserDetails = '${userApiUrl}getUserDetails';
  static const String getLikedArticles = '${userApiUrl}getLikedArticles';
  static const String recommend = '${userApiUrl}recommend';
}


