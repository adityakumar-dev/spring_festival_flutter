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

      final response = await http.get(
        Uri.parse(ServerEndpoints.getUserById(widget.userId, widget.isQuickRegister)),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Fluttertoast.showToast(msg: response.body);
          guestData = json.decode(response.body) as Map<String, dynamic>?;
          debugPrint(guestData.toString());
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load guest details');
      }
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: 'Failed to load guest details');
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
            color: Color(0xFF1a237e),
          ),
        ),
      );
    }

    if (guestData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('No guest data available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        title: Text(
          guestData!['user'] != null
              ? guestData!['user']['name'] ?? 'Guest'
              : 'Guest',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Container(
              height: 250,
              width: double.infinity,
              color: const Color(0xFF1a237e),
              child: _buildProfileImage(),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.verified_user,
                    label: 'Verify',
                    onTap: () => _verifyGuest(),
                  ),
                  _buildActionButton(
                    icon: Icons.block,
                    label: 'Block',
                    onTap: () => _showBlockDialog(),
                    color: Colors.red,
                  ),
                  _buildActionButton(
                    icon: Icons.history,
                    label: 'History',
                    onTap: () => _showHistoryDetails(),
                  ),
                ],
              ),
            ),

            // User Info Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: guestData!['user'] != null
                      ? _buildUserInfo(guestData!['user'])
                      : const Text('User data not available'),
                ),
              ),
            ),

            // QR Code Section (if not quick register)
            if (!widget.isQuickRegister)
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

            // Verification History
            if (!widget.isQuickRegister)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildVerificationHistory(guestData!, guestData!['user']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageBase64 = guestData!['image_base64'];
    
    if (imageBase64 != null) {
      return Image.memory(
        base64Decode(imageBase64.split(',')[1]),
        fit: BoxFit.cover,
      );
    }

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
            color: Color(0xFF1a237e),
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
                  color: Color(0xFF1a237e),
                ),
              ),
            ),
            if (user['is_quick_register'] == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Quick Register',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user['email'] ?? 'No email',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        if (!user['is_quick_register']) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (user['is_instructor'] == true)
                _buildStatusBadge('Instructor', Colors.purple),
              if (user['is_student'] == true)
                _buildStatusBadge('Student', Colors.blue),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVerificationHistory(Map<String, dynamic> data, Map<String, dynamic> user) {
    final faceRecognitions = data['face_recognition'] as List?;
    final qrScans = data['qr_scan'] as List?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification History',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            if (faceRecognitions?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Text(
                'Face Recognition',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
              ...faceRecognitions!.map((scan) => ListTile(
                leading: const Icon(Icons.face),
                title: Text(scan['timestamp'] ?? 'Unknown time'),
                subtitle: Text(scan['status'] ?? 'Unknown status'),
              )),
            ],
            if (qrScans?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Text(
                'QR Code Scans',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
              ...qrScans!.map((scan) => ListTile(
                leading: const Icon(Icons.qr_code),
                title: Text(scan['timestamp'] ?? 'Unknown time'),
                subtitle: Text(scan['status'] ?? 'Unknown status'),
              )),
            ],
          ],
        ),
      ),
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

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Details'),
            onTap: () {
              Navigator.pop(context);
              _editGuestDetails();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Guest', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog();
            },
          ),
        ],
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

  void _verifyGuest() {
    // Implement verification logic
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Guest'),
        content: const Text('Are you sure you want to block this guest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement block logic
              Navigator.pop(context);
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editGuestDetails() {
    // Implement edit logic
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete logic
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedHistory(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Detailed History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        ...guestData!['face_recognition']?.map<Widget>((scan) => ListTile(
          leading: const Icon(Icons.face),
          title: Text(scan['timestamp'] ?? 'Unknown time'),
          subtitle: Text(scan['status'] ?? 'Unknown status'),
        )) ?? [],
        ...guestData!['qr_scan']?.map<Widget>((scan) => ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text(scan['timestamp'] ?? 'Unknown time'),
          subtitle: Text(scan['status'] ?? 'Unknown status'),
        )) ?? [],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF1a237e),
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}