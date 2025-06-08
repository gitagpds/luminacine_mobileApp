class BookingModel {
  String? status;
  String? message;
  List<Booking>? data;

  BookingModel({this.status, this.message, this.data});

  BookingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Booking>[];
      json['data'].forEach((v) {
        data!.add(Booking.fromJson(v));
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

class Booking {
  int? idBooking;
  int? idUser;
  int? idSchedule;
  int? totalPrice;

  Booking({
    this.idBooking,
    this.idUser,
    this.idSchedule,
    this.totalPrice,
  });

  Booking.fromJson(Map<String, dynamic> json) {
    idBooking = json['idBooking'];
    idUser = json['idUser'];
    idSchedule = json['idSchedule'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idBooking'] = idBooking;
    data['idUser'] = idUser;
    data['idSchedule'] = idSchedule;
    data['totalPrice'] = totalPrice;
    return data;
  }
}
