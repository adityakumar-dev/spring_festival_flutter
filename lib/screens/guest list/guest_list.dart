import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view_guest.dart';
import '../../utils/constants/server_endpoints.dart';

class GuestListsScreen extends StatefulWidget {
  static const String routeName = '/guestList';
  const GuestListsScreen({super.key});

  @override
  State<GuestListsScreen> createState() => _GuestListsScreenState();
}

class _GuestListsScreenState extends State<GuestListsScreen> {
  List<dynamic> guests = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  int totalGuests = 0;
  int todayEntries = 0;
  int quickRegisters = 0;
  @override
  void initState() {
    super.initState();
    fetchGuests();
  }

  Future<void> fetchGuests() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      debugPrint("loading");
      final response = await http.post(
        Uri.parse(ServerEndpoints.getUsers()),
        headers: {
          'method': 'POST',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );
      
      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          guests = decodedResponse;
          isLoading = false;
          totalGuests = decodedResponse.length;
          // todayEntries = decodedResponse.where((guest) => _isToday(guest['created_at'])).length;
          
          quickRegisters = decodedResponse.where((guest) => guest['is_quick_register'] == true).length;
        });
      } else {
        throw Exception('Failed to load guests: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint("Socket Exception: $e");
      setState(() {
        error = 'Cannot connect to server. Please check your internet connection.';
        isLoading = false;
      });
    } on TimeoutException catch (e) {
      debugPrint("Timeout Exception: $e");
      setState(() {
        error = 'Connection timed out. Please try again.';
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching guests: $e");
      setState(() {
        error = 'Failed to connect to server. Please try again later.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, 
                color: Color(0xFF1A237E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Guest List',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
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
                  _buildHeaderCard(),
                  _buildQuickStats(totalGuests.toString(), todayEntries.toString(), quickRegisters.toString()),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'All Guests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  _buildGuestList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.people_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'View and manage all registered guests',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(String totalGuests, String todayEntries, String quickRegisters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Guests',
              totalGuests,
              Icons.people,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Today\'s Entries',
              todayEntries,
              Icons.today,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Quick Register',
              quickRegisters,
              Icons.flash_on,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ));
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: guests.length,
      itemBuilder: (context, index) {
        final guest = guests[index];
        final bool isQuickRegister = guest['is_quick_register'] ?? false;

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Row(
              children: [
                Text(
                  guest['name'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (isQuickRegister) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Quick Register',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (guest['is_student'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Student',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (guest['is_instructor'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Instructor',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest['email'] ?? 'No email',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (guest['unique_id_type'] != null && guest['unique_id'] != null)
                  Text(
                    '${guest['unique_id_type']}: ${guest['unique_id']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      'Created: ${_formatDate(guest['created_at'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.login, size: 12, color: Colors.grey[600]),
                    Text(
                      ' Entries: ${guest['count_of_entries'] ?? 0}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: (){ 
              // Fluttertoast.showToast(msg: 'Guest ID: ${guest['id']}');
              Navigator.pushNamed(
              context,
              ViewGuestScreen.routeName,
              arguments: {
                'userId': guest['id'],
                'isQuickRegister': isQuickRegister,
              },
            );
            },
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}