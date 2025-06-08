class MovieModel {
  String? status;
  String? message;
  List<Movie>? data;

  MovieModel({this.status, this.message, this.data});

  MovieModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Movie>[];
      json['data'].forEach((v) {
        data!.add(Movie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Movie {
  int? idMovie;
  String? title;
  String? sinopsis;
  String? genre;
  String? duration;
  String? releaseDate;
  String? posterUrl;

  Movie({
    this.idMovie,
    this.title,
    this.sinopsis,
    this.genre,
    this.duration,
    this.releaseDate,
    this.posterUrl,
  });

  Movie.fromJson(Map<String, dynamic> json) {
    idMovie = json['idMovie'];
    title = json['title'];
    sinopsis = json['sinopsis'];
    genre = json['genre'];
    duration = json['duration'];
    releaseDate = json['releaseDate'];
    posterUrl = json['posterUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idMovie'] = idMovie;
    data['title'] = title;
    data['sinopsis'] = sinopsis;
    data['genre'] = genre;
    data['duration'] = duration;
    data['releaseDate'] = releaseDate;
    data['posterUrl'] = posterUrl;
    return data;
  }
}
