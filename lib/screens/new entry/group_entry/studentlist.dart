import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/screens/new%20entry/face_verification.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';
import 'package:spring_admin/utils/ui/loader_dailog.dart';

class StudentListScreen extends StatefulWidget {
  final String userId;
  static const routeName = '/student-list';
  StudentListScreen({required this.userId});
  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> _studentList = [];
  List<Map<String, dynamic>> _filteredStudentList = [];
  Map<int, bool> _selectedStudents = {};
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudentList();
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudentList = List.from(_studentList);
      } else {
        _filteredStudentList = _studentList.where((student) {
          final name = student['name'].toString().toLowerCase();
          final email = student['email'].toString().toLowerCase();
          return name.contains(query.toLowerCase()) || 
                 email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _fetchStudentList() async {
    final response = await http.MultipartRequest(
      'POST',
      Uri.parse(ServerEndpoints.getStudentList()),
    );
    response.fields['user_id'] = widget.userId;
    response.headers['api-key'] =
        await Provider.of<AppUserManager>(context, listen: false).getAppUserToken();
    final responseData = await response.send();
    final processedResponse = await http.Response.fromStream(responseData);
    final jsonData = jsonDecode(processedResponse.body);
    
    if (processedResponse.statusCode == 200) {
      setState(() {
        _studentList = List<Map<String, dynamic>>.from(jsonData['students']);
        _filteredStudentList = List.from(_studentList);
        _isLoading = false;
        for (var student in _studentList) {
          _selectedStudents[student['user_id']] = false;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = jsonData['detail'];
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
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1A237E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Select Students',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStudents.forEach((key, value) {
                      _selectedStudents[key] = !value;
                    });
                  });
                },
                child: Text(
                  'Select All',
                  style: TextStyle(
                    color: Color.fromARGB(255, 10, 128, 120),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final selectedIds = _selectedStudents.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList();
                final ids = <int>[];
                for (var id in selectedIds) {
                  ids.add(id);
                }
                if(int.tryParse(widget.userId) != null){
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => FaceVerificationScreen(userId: int.tryParse(widget.userId) ?? 0, operationType: 'group', studentIds: ids),
                //   ),
                // );
                }else{
                  Fluttertoast.showToast(
                    msg: 'User ID is not a valid integer',
                    backgroundColor: Colors.red,
                  );
                }
                
                
                // Navigator.pop(context, ids);
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Color.fromARGB(255, 10, 128, 120),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 10, 128, 120),
              ),
            )
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchStudentList,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A237E),
                        ),
                        child: Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email',
                          prefixIcon: Icon(Icons.search, color: Color(0xFF1A237E)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF1A237E)),
                          ),
                        ),
                        onChanged: _filterStudents,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredStudentList.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (ctx, index) {
                          final student = _filteredStudentList[index];
                          final userId = student['user_id'] as int;
                          return Card(
                            elevation: 0,
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                student['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              subtitle: Text(
                                student['email'],
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              value: _selectedStudents[userId] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedStudents[userId] = value ?? false;
                                });
                              },
                              activeColor: Color.fromARGB(255, 10, 128, 120),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
