import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants/server_endpoints.dart';

class ViewGuestScreen extends StatefulWidget {
  static const String routeName = '/viewGuest';
  final int userId;
  final bool isQuickRegister;

  const ViewGuestScreen({super.key, required this.userId, required this.isQuickRegister});

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

      debugPrint("Fetching details for user ID: ${widget.userId}");
      final response = await http.get(
        Uri.parse(ServerEndpoints.getUserById(widget.userId, widget.isQuickRegister)),
      );

      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>?;
        debugPrint("Decoded data: $decodedData");

        // Validate required fields
        if (decodedData?['user'] == null) {
          throw Exception('Invalid response: missing user data');
        }

        // Debug data fields
        debugPrint("User data: ${decodedData?['user']}");
        debugPrint("Entry records: ${decodedData?['entry_records']?.length ?? 0}");
        debugPrint("Summary: ${decodedData?['summary']}");
        debugPrint("Image exists: ${decodedData?['image_base64'] != null}");
        debugPrint("QR exists: ${decodedData?['qr_base64'] != null}");

        setState(() {
          guestData = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load guest details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching guest details: $e");
      Fluttertoast.showToast(msg: 'Failed to load guest details: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
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
        body: Center(
          child: Text('No guest data available'),
        ),
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
                Color(0xFFF5F5F5).withOpacity(0.1)
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
              icon: const Icon(Icons.arrow_back_ios, 
                color: Color.fromARGB(255, 10, 128, 120)),
              onPressed: () => Navigator.pop(context),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                Container(
                  height: 250,
                  width: double.infinity,
                  color: const Color(0xFF1A237E),
                  child: _buildProfileImage(),
                ),

                // Action Buttons
              

                // User Info Card with blur effect
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: guestData!['user'] != null
                              ? _buildUserInfo(guestData!['user'])
                              : const Text('User data not available'),
                        ),
                      ),
                    ),
                  ),
                ),

                // QR Code Section (if not quick register)
                // if (!widget.isQuickRegister)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildQRSection(),
                      ),
                    ),
                  ),
                 Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0A8078),  // Your original teal color
                          Color(0xFF0A8078).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0A8078).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showHistoryDetails(),
                        borderRadius: BorderRadius.circular(15),
                        splashColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'View Entry History',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Verification History
                // if (!widget.isQuickRegister)
                //   Padding(
                //     padding: const EdgeInsets.all(16),
                //     child: Card(
                //       elevation: 2,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(16),
                //         child: _buildVerificationHistory(guestData!, guestData!['user']),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    debugPrint("Building profile image");
    final imageBase64 = guestData?['image_base64'];
    debugPrint("Image base64 data: ${imageBase64?.substring(0, 50)}..."); // Print first 50 chars
    
    if (imageBase64 != null) {
      try {
        final parts = imageBase64.split(',');
        debugPrint("Base64 parts length: ${parts.length}");
        if (parts.length != 2) {
          debugPrint("Invalid base64 format");
          throw Exception('Invalid base64 format');
        }
        
        final bytes = base64Decode(parts[1]);
        debugPrint("Decoded image bytes length: ${bytes.length}");
        
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Image error: $error");
            return _buildDefaultProfileImage();
          },
        );
      } catch (e) {
        debugPrint("Error decoding image: $e");
        return _buildDefaultProfileImage();
      }
    }

    debugPrint("No image data available");
    return _buildDefaultProfileImage();
  }

  Widget _buildDefaultProfileImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No Image Available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    final qrBase64 = guestData!['qr_base64'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
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
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Center(
            child: Text('No QR Code available'),
          ),
      ],
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    debugPrint("Building user info with data: $user");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
            // Show badges
            Row(
              children: [
                if (user['is_quick_register'] == true)
                  _buildStatusBadge('Quick Register', Color.fromARGB(255, 10, 128, 120)),
                if (user['is_instructor'] == true)
                  _buildStatusBadge('Instructor', Colors.blue),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ID information
        if (user['unique_id_type'] != null && user['unique_id'] != null)
          Text(
            '${user['unique_id_type'].toString().toUpperCase()}: ${user['unique_id']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 4),
        // Email
        Text(
          user['email'] ?? 'No email',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        // Institution if available
        if (user['institution'] != null)
          Text(
            'Institution: ${user['institution']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        if(user['group_count'] != null  )
          Text(
            'Group Count: ${user['group_count']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        // Created date
        if (user['created_at'] != null)
          Text(
            'Created: ${_formatDateTime(user['created_at'])}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 16),
        // Summary section
        if (guestData?['summary'] != null) _buildEntrySummary(guestData!['summary']),
      ],
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
    } catch (e) {
      debugPrint("Date parsing error: $e");
      return dateTime;
    }
  }

  Widget _buildEntrySummary(Map<String, dynamic> summary) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entry Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Days', summary['total_days']?.toString() ?? '0'),
              _buildSummaryItem('Total Entries', summary['total_entries']?.toString() ?? '0'),
              _buildSummaryItem('Face Verified', summary['face_verified_entries']?.toString() ?? '0'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Normal', summary['normal_entries']?.toString() ?? '0'),
              _buildSummaryItem('Bypass', summary['bypass_entries']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 10, 128, 120),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
    debugPrint("Building history with ${entryRecords.length} records");
    
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Entry History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
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
          ...entryRecords.expand((record) {
            debugPrint("Processing record: $record");
            final entries = record['entries'] as List? ?? [];
            final date = record['entry_date'] ?? 'Unknown Date';
            
            return [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Date: $date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              ...entries.map((entry) {
                debugPrint("Processing entry: $entry");
                return _buildEntryItem(entry);
              }),
            ];
          }).toList(),
      ],
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry) {
    final isBypass = entry['entry_type'] == 'bypass';
    final arrival = entry['arrival']?.toString().split('T')[1].split('.')[0] ?? 'N/A';
    final departure = entry['departure']?.toString().split('T')[1].split('.')[0] ?? 'Ongoing';
    
    return ListTile(
      leading: Icon(
        isBypass ? Icons.warning : Icons.check_circle,
        color: isBypass ? Colors.orange : Colors.green,
      ),
      title: Text('${isBypass ? "Bypass Entry" : "Normal Entry"}'),
      subtitle: Text('Arrival: $arrival\nDeparture: $departure'),
      trailing: entry['face_verified'] == true 
          ? Icon(Icons.face, color: Colors.green)
          : null,
    );
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