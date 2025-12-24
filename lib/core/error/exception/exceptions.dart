class NetworkException implements Exception{
  final String message;
  NetworkException([this.message = "Network Exception occurred"]);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = "Server Exception occurred"]);
  
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = "Cache Exception ocurred"]);
}