import 'dart:convert';
import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:spring_admin/providers/app_user_manager.dart';
import 'package:spring_admin/utils/constants/server_endpoints.dart';

class CapturedImagesScreen extends StatefulWidget {
  final String userId;

  const CapturedImagesScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<CapturedImagesScreen> createState() => _CapturedImagesScreenState();
}

class _CapturedImagesScreenState extends State<CapturedImagesScreen> {
  bool isLoadingListOfImages = true;
  List<String> listOfImages = [];
  List<File> loadedImages = [];

  @override
  void initState() {
    super.initState();
    _getListOfImages();
  }

  Future<void> _getListOfImages() async {
    try {
      final response = await http.MultipartRequest('GET', Uri.parse(ServerEndpoints.listOfImages()));
      response.fields['user_id'] = widget.userId;
      final responseData = await response.send();
      if (responseData.statusCode == 200) {
        final responseBody = await responseData.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        setState(() {
          listOfImages = List<String>.from(jsonResponse);
          isLoadingListOfImages = false;
        });
        for (var image in listOfImages) {
          await _getImage(image);
        }
      } else {
        setState(() {
          isLoadingListOfImages = false;
        });
        _showErrorDialog('Failed to load images');
      }
    } catch (e) {
      setState(() {
        isLoadingListOfImages = false;
      });
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  Future<void> _getImage(String imageUrl) async {
    try {
      final request = http.MultipartRequest('GET', Uri.parse(ServerEndpoints.getImage()));
      request.fields['path'] = imageUrl;
      request.headers['api-key'] = Provider.of<AppUserManager>(context, listen: false).appUserToken;

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final directory = await Directory.systemTemp.createTemp();
        final file = File('${directory.path}/${imageUrl.split('/').last}');
        await file.writeAsBytes(bytes);
        setState(() {
          loadedImages.add(file);
        });
      } else {
        _showErrorDialog('Failed to load image: $imageUrl');
      }
    } catch (e) {
      _showErrorDialog('Error loading image: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Images'),
      ),
      body: isLoadingListOfImages
          ? const Center(child: CircularProgressIndicator())
          : listOfImages.isEmpty
              ? const Center(child: Text('No images found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: loadedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(loadedImages[index]),
                          );
                        },
                      ),
                    ),
                    if (loadedImages.length < listOfImages.length)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(
                              'Loading images... ${loadedImages.length} of ${listOfImages.length} loaded',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}