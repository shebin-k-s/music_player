import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:music_player/api/model.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = 'https://saavn.dev/api/search';
  }

  Future<List<Song>> getSongData(String query) async {
    try {
      final response = await _dio.get('/songs', queryParameters: {'query': query});
      
      if (response.data['success']) {
        final results = response.data['data']['results'] as List;
        print(results);
        return results.map((songData) => Song.fromJson(songData)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
