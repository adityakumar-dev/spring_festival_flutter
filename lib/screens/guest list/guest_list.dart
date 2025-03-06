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
  List<dynamic> filteredGuests = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  
  // Add new statistics variables
  Map<String, dynamic> statistics = {};
  Map<String, dynamic> todayStatistics = {};
  Map<String, dynamic> entryTypes = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGuests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterByType(String type) {
    setState(() {
      selectedFilter = type;
      if (type == 'all') {
        filteredGuests = guests;
      } else if (type == 'active') {
        filteredGuests = guests.where((guest) => 
          guest['current_entry'] != null && 
          guest['current_entry']['is_active'] == true
        ).toList();
      } else if (type == 'students') {
        filteredGuests = guests.where((guest) => guest['is_student'] == true).toList();
      } else if (type == 'instructors') {
        filteredGuests = guests.where((guest) => guest['is_instructor'] == true).toList();
      } else if (type == 'quick_register') {
        filteredGuests = guests.where((guest) => guest['is_quick_register'] == true).toList();
      } else if (type == 'individuals') {
        filteredGuests = guests.where((guest) => 
          !guest['is_student'] && !guest['is_instructor'] && !guest['is_quick_register']
        ).toList();
      }
    });
  }

  void _filterGuests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterByType(selectedFilter);
      } else {
        var typeFiltered = guests;
        if (selectedFilter != 'all') {
          typeFiltered = filteredGuests;
        }
        
        filteredGuests = typeFiltered.where((guest) {
          final name = guest['name']?.toString().toLowerCase() ?? '';
          final email = guest['email']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> fetchGuests() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.post(
        Uri.parse(ServerEndpoints.getUsers()),
        headers: {
          'method': 'POST',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final data = decodedResponse['data'];
        
        setState(() {
          // Set all users list
          guests = data['all_users'];
          filteredGuests = data['all_users'];
          
          // Set statistics
          statistics = data['statistics'];
          todayStatistics = data['today_statistics'];
          entryTypes = data['entry_types'];
          
          isLoading = false;
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
                  _buildQuickStats(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterGuests,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Guests',
                  statistics['total_users']?.toString() ?? '0',
                  Icons.people,
                  Colors.green,
                  'all',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Entries',
                  todayStatistics['active_entries']?.toString() ?? '0',
                  Icons.today,
                  Colors.orange,
                  'active',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Quick Register',
                  statistics['total_quick_register']?.toString() ?? '0',
                  Icons.flash_on,
                  Colors.blue,
                  'quick_register',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Expanded(
              //   child: _buildStatCard(
              //     'Students',
              //     statistics['total_students']?.toString() ?? '0',
              //     Icons.school,
              //     Colors.purple,
              //     'students',
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Group Leader',
                  statistics['total_instructors']?.toString() ?? '0',
                  Icons.person_2,
                  Colors.indigo,
                  'instructors',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Individual Guests',
                  statistics['total_individual_guests']?.toString() ?? '0',
                  Icons.person_outline,
                  Colors.teal,
                  'individuals',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String filterType) {
    bool isSelected = selectedFilter == filterType;
    
    return InkWell(
      onTap: () => _filterByType(filterType),
      child: Card(
        elevation: isSelected ? 6 : 2,
        color: isSelected ? color.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : color.withOpacity(0.8),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: isSelected 
                    ? color 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
      itemCount: filteredGuests.length,
      itemBuilder: (context, index) {
        final guest = filteredGuests[index];
        final bool isQuickRegister = guest['is_quick_register'] ?? false;
        final bool isActive = guest['current_entry'] != null && 
                            guest['current_entry']['is_active'] == true;
        final String? entryType = guest['current_entry']?['entry_type'];
        
        // Fix duration type conversion
        final dynamic rawDuration = guest['current_entry']?['duration_minutes'];
        final double? duration = rawDuration != null ? 
            (rawDuration is int ? rawDuration.toDouble() : rawDuration as double) : 
            null;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest['name'] ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Wrap( // Replace Row with Wrap to fix overflow
                        spacing: 8, // horizontal spacing between items
                        runSpacing: 4, // vertical spacing between lines
                        children: [
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isActive && entryType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entryType.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (isQuickRegister)
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
                          if (guest['is_student'] == true)
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
                          if (guest['is_instructor'] == true)
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
                                'Group Leader',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                if (isActive && duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Duration: ${duration.toStringAsFixed(1)} mins',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
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