import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'dart:typed_data';

class DataCaching {
  final cache = DefaultCacheManager();
  List<String> cachedData = [];
  final Function setStateCallback;

  DataCaching(this.setStateCallback);

  // Method to remove the cached data
  Future<void> clearCachedData() async {
    await cache.removeFile('api_data');
    setStateCallback(() {
      cachedData.clear();
    });
  }

  // Method to clear the memory cache
  Future<void> clearMemoryCache() async {
    await cache.emptyCache();
  }

  // Method to clear the disk cache
  Future<void> clearDiskCache() async {
    await cache.emptyCache().then((_) => cache.emptyCache());
  }

  // Method to add JSON data to the cache
  Future<void> addToCache(String filename, List<dynamic> data) async {
    final jsonData = json.encode(data);
    await cache.putFile(filename, Uint8List.fromList(jsonData.codeUnits));
  }

  // Method to retrieve JSON data from the cache
  Future<List<dynamic>> getFromCache(String filename) async {
    try {
      FileInfo? fileInfo = await cache.getFileFromCache(filename);
      if (fileInfo != null && fileInfo.file != null) {
        String fileContent = await fileInfo.file!.readAsString();
        List<dynamic> jsonData = json.decode(fileContent);
        return jsonData;
      } else {
        return [];
      }
    } catch (e) {
      print('Error retrieving data from cache: $e');
      return [];
    }
  }
}

