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
  final int user_id;
  final String id;
  final String name;
  final String email;
  final String? imagePath;
  final String? groupName;
  final String count;
  final String idType;
  final String createdAt;
  final bool hasEntryToday;
  final bool faceCaptured;
  final String? latestEntry;

  Guest({
    required this.user_id,
    required this.id,
    required this.name,
    required this.email,
    this.imagePath,
    this.groupName,
    required this.count,
    required this.idType,
    required this.createdAt,
    required this.hasEntryToday,
    required this.faceCaptured,
    this.latestEntry,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    try {
      return Guest(
        user_id: json['user_id'] as int,
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        imagePath: json['image_path'],
        groupName: json['group_name'],
        count: json['count']?.toString() ?? '1',
        idType: json['id_type']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        hasEntryToday: json['entry_status']?['has_entry_today'] ?? false,
        faceCaptured: json['entry_status']?['face_captured'] ?? false,
        latestEntry: json['entry_status']?['latest_entry']?.toString(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error creating Guest from JSON: $e');
      debugPrint('JSON data: ${json.toString()}');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

Future<Map<String, dynamic>> parseJsonData(String body) async {
  try {
    debugPrint('Response body: $body');
    final parsedData = json.decode(body);
    
    if (parsedData['status'] != 'success') {
      throw Exception('API returned error status: ${parsedData['message']}');
    }

    final data = parsedData['data'];
    if (data == null) {
      throw Exception('Data field is null in response');
    }

    final allUsers = (data['all_users'] as List?)?.map((user) {
      debugPrint('Processing user: ${json.encode(user)}');
      return Guest.fromJson(user);
    }).toList() ?? [];

    final statistics = data['statistics'] as Map<String, dynamic>? ?? {};
    final todayStatistics = data['today_statistics'] as Map<String, dynamic>? ?? {};

    return {
      'statistics': statistics,
      'today_statistics': todayStatistics,
      'all_users': allUsers,
    };
  } catch (e, stackTrace) {
    debugPrint('Error parsing JSON: $e');
    debugPrint('Stack trace: $stackTrace');
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
  final Set<String> _loadedGuestIds = {};
  List<Guest> guests = [];
  List<Guest> filteredGuests = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMoreData = true;

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
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(ServerEndpoints.getUsers()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'page': _currentPage + 1,
          'per_page': _pageSize,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again!');
        },
      );

      if (!mounted) return;

      debugPrint('Load more response status: ${response.statusCode}');
      debugPrint('Load more response body: ${response.body}');

      if (response.statusCode == 200) {
        final processedData = await compute(parseJsonData, response.body);
        
        if (!mounted) return;

        if (processedData.containsKey('error')) {
          throw Exception(processedData['error']);
        }

        final newGuests = List<Guest>.from(processedData['all_users']);
        
        // Filter out duplicates
        final uniqueNewGuests = newGuests.where((guest) {
          final isNew = !_loadedGuestIds.contains(guest.id);
          if (isNew) {
            _loadedGuestIds.add(guest.id);
          }
          return isNew;
        }).toList();

        setState(() {
          if (uniqueNewGuests.isEmpty) {
            _hasMoreData = false;
          } else {
            guests.addAll(uniqueNewGuests);
            _filterGuests(_searchController.text);
            _currentPage++;
          }
          _isLoadingMore = false;
        });
      } else {
        throw HttpException('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading more guests: $e');
      setState(() {
        _isLoadingMore = false;
        _hasMoreData = false;
      });
      Fluttertoast.showToast(
        msg: "Error loading more guests: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      client.close();
    }
  }

  void _filterGuests(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      setState(() {
        if (query.isEmpty) {
          filteredGuests = List.from(guests); // Create a new list to avoid reference issues
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
        _loadedGuestIds.clear();
        _hasMoreData = true;
        _currentPage = 1;
      });

      final client = http.Client();
      try {
        final response = await client.post(
          Uri.parse(ServerEndpoints.getUsers()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'page': 1,
            'per_page': _pageSize,
          }),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('The connection has timed out, please try again!');
          },
        );

        if (!mounted) return;

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final processedData = await compute(parseJsonData, response.body);
          
          if (!mounted) return;

          if (processedData.containsKey('error')) {
            throw Exception(processedData['error']);
          }

          final newGuests = List<Guest>.from(processedData['all_users']);
          
          // Add all guest IDs to the set
          _loadedGuestIds.addAll(newGuests.map((guest) => guest.id));

          setState(() {
            statistics = Map<String, dynamic>.from(processedData['statistics']);
            todayStatistics = Map<String, dynamic>.from(processedData['today_statistics']);
            guests = newGuests;
            filteredGuests = newGuests;
            isLoading = false;
            _hasMoreData = newGuests.length >= _pageSize;
          });
        } else {
          throw HttpException('Server returned ${response.statusCode}: ${response.body}');
        }
      } finally {
        client.close();
      }
    } on TimeoutException catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Connection timeout. Please check your internet connection.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        error = 'Connection timeout. Please try again.';
        isLoading = false;
        _hasMoreData = false;
      });
    } on HttpException catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Server error: ${e.message}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        error = 'Server error: ${e.message}';
        isLoading = false;
        _hasMoreData = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error in fetchGuests: $e');
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        error = 'Failed to connect to server. Please try again later.';
        isLoading = false;
        _hasMoreData = false;
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
                          if (!_hasMoreData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No more guests to load'),
                              ),
                            );
                          }
                          return null;
                        }

                        final guest = filteredGuests[index];
                        return _buildGuestCard(guest);
                      },
                      childCount: filteredGuests.length + (_isLoadingMore || !_hasMoreData ? 1 : 0),
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
              'Total Entries',
              statistics['total_entries']?.toString() ?? '0',
              Icons.person,
              Colors.orange,
              'active',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active Today',
              todayStatistics['active_entries']?.toString() ?? '0',
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
          backgroundImage: guest.imagePath != null 
              ? NetworkImage('${ServerEndpoints.baseUrl}/${guest.imagePath}')
              : null,
          child: guest.imagePath == null ? const Icon(
            Icons.person_outline,
            color: Color(0xFF1A237E),
          ) : null,
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
            if (guest.groupName != null) Text(
              'Group: ${guest.groupName} (${guest.count} members)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    guest.idType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(guest.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (guest.hasEntryToday)
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
                          'Active Today',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (guest.faceCaptured) ...[
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.face,
                          size: 12,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Face Captured',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              'userId': guest.user_id.toString(),
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