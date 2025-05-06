import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spring_admin/screens/captured_images_screen.dart';
import 'package:spring_admin/screens/image/profile_image.dart';
import 'dart:convert';
import '../../utils/constants/server_endpoints.dart';

class ViewGuestScreen extends StatefulWidget {
  static const String routeName = '/viewGuest';
  final String userId;

  const ViewGuestScreen({
    super.key,
    required this.userId,
    // required this.isQuickRegister,
  });

  @override
  State<ViewGuestScreen> createState() => _ViewGuestScreenState();
}

class _ViewGuestScreenState extends State<ViewGuestScreen> {
  Map<String, dynamic>? guestData;
  bool isLoading = true;
  String? error;
  
  bool showQR = false;

  @override
  void initState() {
    super.initState();
    fetchGuestDetails();
  }

  Future<void> fetchGuestDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse(ServerEndpoints.getUserById(widget.userId)),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>?;
        
        if (decodedData?['user'] == null) {
          throw Exception('Invalid response: missing user data');
        }

        setState(() {
          guestData = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load guest details: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load guest details: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 10, 128, 120),
          ),
        ),
      );
    }

    if (guestData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: Text('No guest data available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFCCCB),
                Color(0xFFF5F5F5),
                Color(0xFFF5F5F5).withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              guestData!['user'] != null
                  ? guestData!['user']['name'] ?? 'Guest'
                  : 'Guest',
              style: const TextStyle(
                color: Color(0xFF1A237E),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color.fromARGB(255, 10, 128, 120),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 10, 128, 120),
              ),
              onPressed: () => _showHistoryDetails(),
              child: const Text('History', style: TextStyle(color: Colors.white),),
            ),
          ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: -190,
            left: 150,
            right: -150,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                'assets/images/aipen.png',
                height: MediaQuery.of(context).size.height * 0.4,
                color: Color.fromARGB(255, 255, 165, 164),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileImage(),
                _buildUserInfo(guestData!['user']),
                _buildQRSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final imagePath = guestData?['image_base64'];
    return GestureDetector(
      onTap: (){
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileImageScreen(base64Image: imagePath, name: guestData?['user']['name'] ?? 'Guest')));
      },
      child: Container(
        height: 250,
        width: double.infinity,
        color: const Color(0xFF1A237E),
        child: imagePath != null
            ? Image.memory(
                base64Decode(imagePath.split(',')[1]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProfileImage();
                },
              )
            : _buildDefaultProfileImage(),
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('No Image Available', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user['name'] ?? 'N/A',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: ${user['email'] ?? 'No email'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'Institution: ${user['institution_name'] ?? 'N/A'}',
          //   style: TextStyle(color: Colors.grey[600]),
          // ),
          const SizedBox(height: 8),
          Text(
            'ID Type: ${user['id_type']?.toUpperCase() ?? 'N/A'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'ID Number: ${user['id'] ?? 'N/A'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (user['group_name'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Group: ${user['group_name']} (${user['count']} members)',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Created At: ${formatDate(user['created_at'])}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (guestData?['summary'] != null) ...[
            Text(
              'Entry Summary',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Days: ${guestData!['summary']['total_days']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Total Entries: ${guestData!['summary']['total_entries']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    final qrBase64 = guestData!['qr_base64'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(

          padding: const EdgeInsets.all(8.0),
          child: const Text(
            'QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (qrBase64 != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.memory(
                    base64Decode(qrBase64.split(',')[1]),
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan to verify guest',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          const Center(child: Text('No QR Code available')),
      ],
    );
  }

  void _showHistoryDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _buildDetailedHistory(scrollController),
      ),
    );
  }

  Widget _buildDetailedHistory(ScrollController scrollController) {
    final entryRecords = guestData?['entry_records'] as List? ?? [];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Entry History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapturedImagesScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
              ),
              child: const Text(
                'Captured Images',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (entryRecords.isEmpty)
          Center(
            child: Text(
              'No entry records found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...entryRecords.map((record) {
            final entries = record['entries'] as List? ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Date: ${formatDate(record['entry_date'])}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                ...entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      'Arrival: ${_formatDateTime(entry['arrival'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['departure'] != null)
                          Text('Departure: ${_formatDateTime(entry['departure'])}'),
                        if (entry['duration'] != null)
                          Text('Duration: ${entry['duration']} minutes'),
                        Text('Recorded by: ${record['app_user_id']}'),
                      ],
                    ),
                    leading: const Icon(
                      Icons.access_time,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                )).toList(),
              ],
            );
          }).toList(),
      ],
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      // The date is already in IST (+05:30) according to the response
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  String formatDate(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF2196F3),
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


