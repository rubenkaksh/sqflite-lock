import 'package:dio/dio.dart';
import '../models/photo.dart';
import '../database_service.dart';

class PhotoRepository {
  final DatabaseService _databaseService;
  final Dio _dio;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  PhotoRepository(this._databaseService)
      : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<List<Photo>> fetchAndStorePhotos() async {
    try {
      // Fetch photos from API
      final response = await _dio.get('/photos');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<Photo> photos =
            jsonList.map((json) => Photo.fromJson(json)).toList();

        // Convert photos to list of maps for bulk insert
        final List<Map<String, dynamic>> photoMaps =
            photos.map((photo) => photo.toJson()).toList();


        final startTime = DateTime.now();
        // Store photos in local database using bulk insert
        await _databaseService.bulkInsert('photos', photoMaps);
        final endTime = DateTime.now();

        print('Time to download ===========>');
        print(endTime.difference(startTime).inMilliseconds);
        return photos;
      } else {
        throw Exception('Failed to load photos');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching photos: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching photos: $e');
    }
  }

  Future<List<Photo>> getLocalPhotos() async {
    return await _databaseService.getAllPhotos();
  }

  Future<void> clearLocalPhotos() async {
    await _databaseService.deleteAllPhotos();
  }
}
