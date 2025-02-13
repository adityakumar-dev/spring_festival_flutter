class ServerEndpoints {
  // Base URL
  static const String baseUrl = 'https://enabled-flowing-bedbug.ngrok-free.app';

  // User Management Endpoints
  static String createUser() => '$baseUrl/create_user';
  static String getUsers() => '$baseUrl/users';
  static String getUserById(int userId) => '$baseUrl/users/$userId';
  
  // QR Code Related Endpoints
  static String getQrCode(int userId) => '$baseUrl/qr_code/$userId';
  static String scanQr() => '$baseUrl/qr_scans/verify';
  static String getQrHistory(int userId) => '$baseUrl/qr_scans/$userId';
  
  // Face Recognition Endpoints
  static String logFaceRecognition() => '$baseUrl/face_recognition';
  static String getFaceRecognitionHistory(int userId) => '$baseUrl/face_recognition/$userId';
  static String verifyFaceRecognition() => '$baseUrl/face_recognition/verify';

  // Helper method to build query parameters
  static String addQueryParams(String url, Map<String, dynamic> params) {
    if (params.isEmpty) return url;
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$url?$queryString';
  }
}

// Example Usage:
// final createUserUrl = ServerEndpoints.createUser();
// final userDetailsUrl = ServerEndpoints.getUserById(123);
// final qrHistoryWithParams = ServerEndpoints.addQueryParams(
//   ServerEndpoints.getQrHistory(123),
//   {'date': '2024-03-20'}
// );