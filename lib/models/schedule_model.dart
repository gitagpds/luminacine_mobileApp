import 'package:flutter/foundation.dart';

class ScheduleModel {
  String? status;
  String? message;
  List<Schedule>? data;

  ScheduleModel({this.status, this.message, this.data});

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Schedule>[];
      json['data'].forEach((v) {
        data!.add(Schedule.fromJson(v));
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

class Schedule {
  int? idSchedule;
  int? idMovie;
  String? cinemaName;
  String? studio;
  String? date;
  String? time;
  int? price;

  Schedule({
    this.idSchedule,
    this.idMovie,
    this.cinemaName,
    this.studio,
    this.date,
    this.time,
    this.price,
  });

  Schedule.fromJson(Map<String, dynamic> json) {
    debugPrint('DATA JSON YANG DITERIMA Schedule.fromJson: $json');
    idSchedule = json['id_schedule'];
    idMovie = json['id_movie'];
    cinemaName = json['cinema_name'];
    studio = json['studio'];
    date = json['date'];
    time = json['time'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idSchedule'] = idSchedule;
    data['idMovie'] = idMovie;
    data['cinemaName'] = cinemaName;
    data['studio'] = studio;
    data['date'] = date;
    data['time'] = time;
    data['price'] = price;
    return data;
  }
}
