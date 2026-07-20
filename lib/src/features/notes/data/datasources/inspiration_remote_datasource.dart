import 'package:dio/dio.dart';

class InspirationRemoteDataSource {
  InspirationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> fetchInspirationQuote() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://dummyjson.com/quotes/random',
    );

    final data = response.data;
    if (data == null) {
      return 'Write it down before it fades away.';
    }

    final quote = data['quote'] as String?;
    final author = data['author'] as String?;

    if (quote == null || quote.trim().isEmpty) {
      return 'Write it down before it fades away.';
    }

    if (author == null || author.trim().isEmpty) {
      return quote;
    }

    return '"$quote"\n— $author';
  }
}
