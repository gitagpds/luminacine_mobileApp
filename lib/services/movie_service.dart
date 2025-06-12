import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/movie_model.dart';

class MovieService {
  static const baseUrl =
      "https://luminacine-be-901699795850.us-central1.run.app";

  // ✅ GET /movies
  static Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse("$baseUrl/movies"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return MovieModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load movies");
    }
  }

  // ✅ GET /movies/:id
  static Future<Movie> getMovieById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/movies/$id"));
    final body = jsonDecode(response.body);
    return Movie.fromJson(body['data']);
  }

  // ✅ PUT /movies/:id
  static Future<void> updateMovie(
      int id, Map<String, dynamic> updatedPayload) async {
    final response = await http.put(
      Uri.parse("$baseUrl/movies/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedPayload),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update movie.");
    }
  }

  // (Opsional) ✅ POST /movies - create movie biasa
  static Future<Movie> createMovie(Map<String, dynamic> moviePayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/movies"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(moviePayload),
    );
    final body = jsonDecode(response.body);
    return Movie.fromJson(body['data']);
  }

  // ✅ DELETE /movies/:id
  static Future<void> deleteMovie(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/movies/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete movie.");
    }
  }

  // (Opsional) ✅ POST /movies - create movie dengan upload poster multipart
  static Future<Movie> uploadMovieWithPoster({
    required Map<String, String> fields,
    required File posterFile,
  }) async {
    final uri = Uri.parse("$baseUrl/movies");
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    request.files.add(
      await http.MultipartFile.fromPath(
        'poster',
        posterFile.path,
        contentType: MediaType('image', 'jpeg'), // atau 'png' tergantung file
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final body = jsonDecode(respStr);
      return Movie.fromJson(body['data']);
    } else {
      throw Exception("Failed to upload movie with poster");
    }
  }
}
