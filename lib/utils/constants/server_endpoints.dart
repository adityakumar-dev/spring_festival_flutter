class ServerEndpoints {
  // Base URL
  static String baseUrl = 'https://api.vmsbutu.it.com';

  static String getGroupVerify() => '$baseUrl/face_recognition/group_entry';
  // User Management Endpoints
  static String createUser() => '$baseUrl/create_user';
  static String getUsers() => '$baseUrl/users/all';
  static String getUserById(String userId) => '$baseUrl/users/$userId';
  static String verifyUser() => '$baseUrl/verify';
  static String registerUser() => '$baseUrl/create';
  static String captureFace() => '$baseUrl/face_capture/capture';
  static String listOfImages() => '$baseUrl/list-images';
  static String getImage() => '$baseUrl/users/image/';
  // QR Code Related Endpoints
  static String getQrCode() => '$baseUrl/qr-code';
  static String scanQr() => '$baseUrl/qr/scan_qr';
  static String getQrHistory(int userId) => '$baseUrl/qr_scans/$userId';
  
  // Face Recognition Endpoints
  static String logFaceRecognition() => '$baseUrl/face_recognition';
  static String getFaceRecognitionHistory(int userId) => '$baseUrl/face_recognition/$userId';
  static String verifyFace() => '$baseUrl/verify-face';
  static String getFood() => '$baseUrl/food';
  static String scanFood() => '$baseUrl/food/add';

  static String getStudentList() => '$baseUrl/qr/group_entry';

  // Helper method to build query parameters
  static String addQueryParams(String url, Map<String, dynamic> params) {
    if (params.isEmpty) return url;
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$url?$queryString';
  }
  static String getAnalytics() => '$baseUrl/analytics';
  static String storeFaceImage() {
    return '$baseUrl/store-face-image';  // Adjust the endpoint path as needed
  }
  static String getFoodAnalytics() => '$baseUrl/food-analytics';
  static String login() => '$baseUrl/login';
  static String register() => '$baseUrl/register';
  // static String quickRegister() {
  //   return '$baseUrl/quick-register';
  // }
}

// Example Usage:
// final createUserUrl = ServerEndpoints.createUser();
// final userDetailsUrl = ServerEndpoints.getUserById(123);
// final qrHistoryWithParams = ServerEndpoints.addQueryParams(
//   ServerEndpoints.getQrHistory(123),
//   {'date': '2024-03-20'}
// );