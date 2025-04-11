import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:Deals/login/api_service.dart';
import 'package:http_parser/http_parser.dart';

class ImageService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found'
        };
      }

      final uri = Uri.parse('$baseUrl/upload/profile-image');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file to request
      final fileExtension = imageFile.path.split('.').last;
      final mimeType = 'image/${fileExtension == 'jpg' ? 'jpeg' : fileExtension}';
      
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = {
          'success': true,
          'imageUrl': Uri.parse(responseData).toString(),
        };
        return data;
      } else {
        return {
          'success': false,
          'message': 'Failed to upload image. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading image: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> uploadItemImage(File imageFile) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found'
        };
      }

      final uri = Uri.parse('$baseUrl/upload/item-image');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file to request
      final fileExtension = imageFile.path.split('.').last;
      final mimeType = 'image/${fileExtension == 'jpg' ? 'jpeg' : fileExtension}';
      
      request.files.add(await http.MultipartFile.fromPath(
        'itemImage',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = {
          'success': true,
          'imageUrl': Uri.parse(responseData).toString(),
        };
        return data;
      } else {
        return {
          'success': false,
          'message': 'Failed to upload image. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading image: ${e.toString()}'
      };
    }
  }
}