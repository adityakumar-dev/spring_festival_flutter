import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spring_admin/utils/constants/server_endpoints.dart';

class ServerApi {
  
  static Future<String> getGuestList() async {
    final response = await http.get(Uri.parse(ServerEndpoints.getUsers()));
    if (response.statusCode == 200) {
  debugPrint(response.body);
      return response.body;
    } else {  debugPrint(response.statusCode.toString());

      return 'Error: ${response.statusCode}';
    }
  }

}