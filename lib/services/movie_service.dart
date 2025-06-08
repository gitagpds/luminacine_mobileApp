import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieService {
  static const baseUrl = "https://luminacine-be-901699795850.us-central1.run.app";

  static Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse("$baseUrl/movies"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return MovieModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load movies");
    }
  }

  static Future<Movie> getMovieById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/movies/$id"));
    final body = jsonDecode(response.body);
    return Movie.fromJson(body['data']);
  }
}