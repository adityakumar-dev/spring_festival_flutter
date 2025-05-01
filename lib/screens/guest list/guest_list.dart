import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view_guest.dart';
import '../../utils/constants/server_endpoints.dart';

// Define a Guest model for better type safety and performance
class Guest {
  final int id;
  final String name;
  final String email;
  final String institutionName;
  final String contactNumber;
  final String createdAt;
  final bool entryExist;
  final String? imagePath;
  final String? qrCode;

  Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.institutionName,
    required this.contactNumber,
    required this.createdAt,
    required this.entryExist,
    this.imagePath,
    this.qrCode,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      institutionName: json['institution_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      entryExist: json['entry_status']['has_entry_today'] ?? false,
      imagePath: json['image_path'],
      qrCode: json['qr_code'],
    );
  }
}

Future<Map<String, dynamic>> parseJsonData(String body) async {
  try {
    final parsedData = json.decode(body);
    final data = parsedData['data'];
    
    return {
      'statistics': Map<String, dynamic>.from(data['statistics']),
      'today_statistics': Map<String, dynamic>.from(data['today_statistics']),
      'all_users': (data['all_users'] as List)
          .map((user) => Guest.fromJson(user))
          .toList(),
    };
  } catch (e) {
    return {'error': 'Failed to parse JSON: $e'};
  }
}

class GuestListsScreen extends StatefulWidget {
  static const String routeName = '/guestList';
  const GuestListsScreen({super.key});

  @override
  State<GuestListsScreen> createState() => _GuestListsScreenState();
}

class _GuestListsScreenState extends State<GuestListsScreen> {
  List<Guest> guests = [];
  List<Guest> filteredGuests = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Statistics variables
  Map<String, dynamic> statistics = {};
  Map<String, dynamic> todayStatistics = {};
  Map<String, dynamic> entryTypes = {};

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchGuests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreGuests();
    }
  }

  Future<void> _loadMoreGuests() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ServerEndpoints.getUsers()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'page': _currentPage + 1,
          'per_page': _pageSize,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final processedData = await compute(parseJsonData, response.body);
        
        if (!mounted) return;

        if (processedData.containsKey('error')) {
          throw Exception(processedData['error']);
        }

        setState(() {
          final newGuests = List<Guest>.from(processedData['all_users']);
          guests.addAll(newGuests);
          filteredGuests = guests;
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _isLoadingMore = false;
      debugPrint('Error loading more guests: $e');
    }
  }

  void _filterGuests(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      setState(() {
        if (query.isEmpty) {
          filteredGuests = guests;
        } else {
          final searchLower = query.toLowerCase();
          filteredGuests = guests.where((guest) {
            return guest.name.toLowerCase().contains(searchLower) ||
                   guest.email.toLowerCase().contains(searchLower);
          }).toList();
        }
      });
    });
  }

  Future<void> fetchGuests() async {
    if (!mounted) return;
    
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.post(
        Uri.parse(ServerEndpoints.getUsers()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'page': 1,
          'per_page': _pageSize,
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final processedData = await compute(parseJsonData, response.body);
        
        if (!mounted) return;

        if (processedData.containsKey('error')) {
          throw Exception(processedData['error']);
        }

        setState(() {
          statistics = Map<String, dynamic>.from(processedData['statistics']);
          todayStatistics = Map<String, dynamic>.from(processedData['today_statistics']);
          guests = List<Guest>.from(processedData['all_users']);
          filteredGuests = guests;
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Error : Status ${response.statusCode}");
        throw Exception('Failed to load guests: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      
      Fluttertoast.showToast(msg: "Error : ${e.toString()}");
      debugPrint(e.toString());
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
            RefreshIndicator(
              onRefresh: fetchGuests,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        _buildStatistics(),
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
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= filteredGuests.length) {
                          if (_isLoadingMore) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return null;
                        }

                        final guest = filteredGuests[index];
                        return _buildGuestCard(guest);
                      },
                      childCount: filteredGuests.length + (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
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

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
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
              'Active Users',
              statistics['total_entries']?.toString() ?? '0',
              Icons.person,
              Colors.orange,
              'active',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Today\'s Entries',
              todayStatistics['total_entries']?.toString() ?? '0',
              Icons.today,
              Colors.blue,
              'today',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String filterType) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(Guest guest) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFF1A237E),
          ),
        ),
        title: Text(
          guest.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guest.email,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Institution: ${guest.institutionName}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  'Created: ${_formatDate(guest.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                if (guest.entryExist)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
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
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            ViewGuestScreen.routeName,
            arguments: {
              'userId': guest.id,
            },
          );
        },
      ),
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